---
name: pwa-build
description: "Когда нужно превратить веб-приложение в PWA — manifest, service worker, иконки, installability. Также когда хотят поставить веб-приложение на телефон без App Store."
---

# PWA Build — веб-приложение в устанавливаемое на телефон

## Когда использовать

- «Хочу поставить на телефон без App Store»
- «Сделай PWA», «добавь manifest»
- Обход ограничений нативной сборки (нет кабеля, старый Xcode)
- Быстрый MVP до публикации в сторе

## Инструкции

### Шаг 1: manifest.json

Файл `public/manifest.json` — используй шаблон из `tools/manifest-template.json`.
Обязательные поля: name, short_name, start_url, display: standalone, icons (192 + 512).

### Шаг 2: Meta-теги в `<head>`

```html
<link rel="manifest" href="/manifest.json">
<meta name="theme-color" content="{{THEME_COLOR}}">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<link rel="apple-touch-icon" href="/icons/icon-192.png">
```

### Шаг 3: Service Worker

Используй `tools/sw-template.js`. Стратегии:
- Cache First → статика (CSS, JS, шрифты)
- Network First → API, HTML
- Stale While Revalidate → изображения

Регистрация: `navigator.serviceWorker.register('/sw.js')`

### Шаг 4: Иконки

Из PNG 1024x1024 → `python3 tools/icons.py --input icon.png --output public/icons/`

### Шаг 5: Тест

iPhone: Safari → «На экран «Домой»». Android: Chrome → «Установить».

## Ограничения iOS — краткая шпаргалка

| Фича | iOS PWA | Android PWA |
|------|---------|-------------|
| Пуш-уведомления | ⚠️ 16.4+ | ✅ |
| Акселерометр (счёт повторений) | ✅ + permission | ✅ |
| Proximity sensor | ❌ | ❌ |
| Вибрация | ❌ | ✅ |
| Screen Wake Lock | ✅ 16.4+ | ✅ |
| Офлайн (SW) | ✅ | ✅ |
| SW умирает без визита | 3 дня | нет |

→ Полные решения и код: **`tools/limitations-workarounds.md`**

## tools/ — что есть

| Файл | Назначение |
|------|-----------|
| `manifest-template.json` | Шаблон manifest.json |
| `sw-template.js` | Service Worker (Cache First / Network First) |
| `devicemotion.js` | Счёт повторений через акселерометр + iOS permission |
| `wakelock.js` | Экран не гаснет во время тренировки |
| `offline-sync.js` | Очередь записей при отсутствии сети → Supabase |
| `limitations-workarounds.md` | Полная таблица + код обходов |

## Когда нужен Capacitor вместо PWA

- Proximity sensor (нос к экрану = 1 повторение)
- Haptic feedback на iOS
- Background processing
- Bluetooth (фитнес-трекеры)

→ Используй скилл `capacitor-build`
