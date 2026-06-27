---
name: capacitor-build
description: "Когда нужно собрать Capacitor iOS приложение на MacBook Air 2015 (Xcode 14.2, macOS 12 Monterey). Учитывает ограничения: iOS 17 на iPhone, pymobiledevice3, облачная сборка через Codemagic."
---

# Capacitor Build — iOS сборка с ограниченного Mac

## Когда использовать

- Сборка Capacitor-приложения для iOS
- Деплой на iPhone 12 Pro (iOS 17.6.1) с MacBook Air 2015
- «Собери приложение», «запусти на айфоне»

## Ограничения (зашиты в железо)

| Параметр | Значение | Последствие |
|----------|---------|-------------|
| macOS | 12.7.6 Monterey | Максимальный Xcode: 14.2 |
| Xcode | 14.2 | Деплоит до iOS 16.2 |
| iPhone | 12 Pro, iOS 17.6.1 | Xcode 14.2 НЕ МОЖЕТ деплоить |
| RAM | 4 GB | Эмулятор iOS не поднимется |
| bun | ~/.bun/bin/bun | npx недоступен, используй `bun x` |

## Инструкции

### Путь A: Локальная сборка + pymobiledevice3

Работает ТОЛЬКО с рабочим Lightning-кабелем.

```bash
# 1. Сборка веб-части
cd /путь/к/проекту
~/.bun/bin/bun run build

# 2. Синхронизация Capacitor
~/.bun/bin/bun x cap sync ios

# 3. Убедись что capacitor.config.ts НЕ содержит server.url (закомментируй для прод)

# 4. Открой в Xcode
~/.bun/bin/bun x cap open ios

# 5. В Xcode: подпись через Personal Team (бесплатный Apple ID)
# Xcode → Signing & Capabilities → Team → выбери Personal Team

# 6. Деплой через pymobiledevice3 (для iOS 17+)
pymobiledevice3 usbmux list  # проверь что iPhone виден
# Затем через Xcode Build → Run (если подпись прошла)
```

### Путь B: Облачная сборка (Codemagic) — рекомендуемый

Обходит ВСЕ ограничения Mac. Бесплатно: 500 минут/месяц.

```bash
# 1. Push код в GitHub
git add -A && git commit -m "Build" && git push

# 2. Зайди на codemagic.io → Add application → выбери репо

# 3. Настрой workflow:
#    - Xcode version: Latest (15+)
#    - Build: bun install && bun run build && bun x cap sync ios
#    - Signing: Manual (или automatic с Apple ID)
#    - Artifact: .ipa файл

# 4. Скачай .ipa → установи через pymobiledevice3:
pymobiledevice3 apps install /путь/к/app.ipa
```

### Путь C: PWA (обходной)

Если нужен быстрый тест без нативной сборки — используй скилл `pwa-build`.
Proximity sensor НЕ будет работать, но весь остальной UI — да.

## Подготовка capacitor.config.ts для продакшена

```typescript
const config: CapacitorConfig = {
  appId: "com.pushup.app",
  appName: "PushUp",
  webDir: ".output/public",
  // ЗАКОММЕНТИРОВАТЬ для продакшена:
  // server: { url: "http://192.168.1.62:8080", cleartext: true },
  ios: { scheme: "PushUp" },
};
```

## Подпись (бесплатный Apple ID)

- Personal Team → приложение работает 7 дней, потом переподпись
- Максимум 3 устройства, 10 app IDs
- Нет push-уведомлений, нет App Store
- Достаточно для тестирования и демо

## Чек-лист перед сборкой

- [ ] `server.url` закомментирован в capacitor.config.ts
- [ ] `bun run build` прошёл без ошибок
- [ ] `bun x cap sync ios` выполнен
- [ ] objectVersion в project.pbxproj = 56 (для Xcode 14.2)
- [ ] iPhone подключён рабочим кабелем + «Доверять»
