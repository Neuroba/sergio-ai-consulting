---
name: capacitor-ios-sensor
description: "Когда нужно создать или отладить нативный iOS-плагин для Capacitor 8+ с доступом к датчикам (proximity, accelerometer, motion). Включает правильный паттерн для call.resolve(), диагностику зависания Promise, simulate-метод для тестирования."
---

# Capacitor iOS Sensor Plugin

## Когда использовать

- Датчик приближения (proximity sensor) не работает в Capacitor-приложении
- JS Promise из нативного плагина зависает (never resolves)
- Нужно тестировать нативный датчик без физического движения
- "start() зависает", "сенсор не работает", "starting и ничего"

## Ключевые правила Capacitor 8 iOS

### 1. call.resolve() — синхронно, UIDevice — на main thread

Capacitor 8 вызывает плагины на **bridge thread** (НЕ main thread).
`UIDevice.isProximityMonitoringEnabled` setter вызывает `UIApplication.setProximityEventsEnabled`
который имеет `assertBarrierOnQueue` — требует main run loop thread → SIGTRAP если вызвать с bridge.

```swift
// ❌ НЕПРАВИЛЬНО — Promise зависнет (call освобождается до async)
@objc func start(_ call: CAPPluginCall) {
    DispatchQueue.main.async {
        call.resolve(["result": true])
    }
}

// ❌ НЕПРАВИЛЬНО — SIGTRAP crash (UIDevice на bridge thread)
@objc func start(_ call: CAPPluginCall) {
    UIDevice.current.isProximityMonitoringEnabled = true  // crash!
    call.resolve([...])
}

// ✅ ПРАВИЛЬНО — resolve синхронно, UIDevice на main thread отдельно
@objc func start(_ call: CAPPluginCall) {
    call.resolve(["proximityEnabled": true, "initialNear": false])
    DispatchQueue.main.async {
        UIDevice.current.isProximityMonitoringEnabled = true
        UIApplication.shared.isIdleTimerDisabled = true
        NotificationCenter.default.addObserver(...)
    }
}
```

### 2. addListener — ТОЛЬКО через registerPlugin(), не через Plugins.ProximitySensor

`window.Capacitor.Plugins.ProximitySensor` — raw native proxy.
При вызове `addListener("sensorRaw", cb)` eventName передаётся как nil в нативный
`CAPPlugin.addEventListener:listener:` → `NSDictionary` crash "key cannot be nil".

`registerPlugin("ProximitySensor")` создаёт JS proxy с правильным wrapper:
eventName оборачивается в `{ eventName: "sensorRaw" }` перед отправкой в native.

```ts
// ❌ НЕПРАВИЛЬНО — addListener crash SIGABRT
const plugin = (window as any).Capacitor.Plugins.ProximitySensor;
plugin.addListener("sensorRaw", cb);  // nil key → crash

// ✅ ПРАВИЛЬНО — registerPlugin добавляет правильный wrapper
const plugin = (window as any).Capacitor.registerPlugin("ProximitySensor");
plugin.addListener("sensorRaw", cb);  // { eventName: "sensorRaw" } → OK
```

НЕ использовать `import { registerPlugin } from "@capacitor/core"` (статик импорт крашит при загрузке)
и НЕ `import("@capacitor/core")` (динамик импорт зависает в WKWebView).
Только `window.Capacitor.registerPlugin` — без импортов.

### 3. call.keepAlive = true — ТОЛЬКО для streaming (не для Promise)

`keepAlive = true` предназначен для `addListener` (многократные события).
Для обычного `start()` → НЕ использовать. Может сломать Promise resolution.

### 4. Диагностический паттерн — минимальный start()

Если Promise зависает — сначала сделать минимальный resolve:
```swift
@objc func start(_ call: CAPPluginCall) {
    call.resolve(["test": "ok"])  // Ничего больше
}
```
- Если работает → проблема в UIDevice/UIApplication строках → добавлять по одной
- Если не работает → проблема в Capacitor bridge (plugin name mismatch, registration)

### 5. simulate() метод — обязателен для тестирования

Всегда добавлять в plugin:
```swift
CAPPluginMethod(name: "simulate", returnType: CAPPluginReturnPromise),

@objc func simulate(_ call: CAPPluginCall) {
    let near = call.getBool("near") ?? false
    handleProximityState(near: near)  // тот же метод что и реальный датчик
    call.resolve(["simulated": near])
}
```

## Архитектура proximity sensor

```
┌──────────────────────────────────────────────────────┐
│                   iOS Device                         │
│                                                      │
│  UIDevice.proximityStateDidChangeNotification        │
│         ↓                                            │
│  Swift Plugin (ProximitySensorPlugin)                │
│  - Счёт репов ЗДЕСЬ, не в JS                        │
│  - Emit repCompleted только при NEAR→FAR             │
│  - 120ms delay перед notify (WKWebView просыпается)  │
│         ↓                                            │
│  Capacitor Bridge                                    │
│         ↓                                            │
│  JS / React (WKWebView)                              │
│  - Получает только repCompleted события             │
│  - sensorRaw для диагностики                        │
└──────────────────────────────────────────────────────┘
```

**Почему счёт в Swift:** когда лицо близко к датчику, экран гаснет → WKWebView
suspended → JS не выполняется. Notification в Swift продолжает работать.

## Альтернативы proximity sensor

| Метод | Надёжность | Сложность | Экран |
|-------|-----------|-----------|-------|
| Proximity (UIDevice) | Средняя (проблемы в WKWebView) | Средняя | Выключается |
| Accelerometer (CMMotionManager) | Высокая | Средняя | Включён |
| Camera + CoreML | Максимальная | Высокая | Включён |

**Акселерометр для отжиманий:**
- Телефон лежит экраном вверх под грудью
- Отслеживать Z-ось (вертикаль)
- Порог: изменение > 0.4g считается репом
- Использует `@capacitor-community/motion` или кастомный CMMotionManager plugin

## Debug page pattern

Всегда иметь `/debug` роут с:
1. Кнопки NEAR / FAR для ручного simulate()
2. AUTO TEST кнопка (7 шагов → должно дать 3 репа)
3. Вывод sensorRaw событий в реальном времени
4. Результат start() с timeout 8s

## Checklist при отладке

- [ ] `isAvailable()` работает → bridge найден
- [ ] Минимальный `start()` (только resolve) работает → bridge routing OK
- [ ] `start()` с UIDevice работает → threading OK
- [ ] sensorRaw события приходят → notification fires
- [ ] repCompleted события приходят → счёт работает
- [ ] При физическом покрытии → сценарий реального использования

## Связанные скилы

- `capacitor-build` — сборка и деплой на iPhone через Codemagic
