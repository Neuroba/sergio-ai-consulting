---
name: site-from-ref
description: "Когда пользователь даёт ссылку на Framer, Webflow, Dribbble или скриншот сайта и просит сделать похожий. Конвертация дизайн-референса в статический HTML/CSS/JS сайт с Tailwind, готовый к деплою на Netlify."
---

# Site from Reference — сайт по референсу

## Когда использовать

- Пользователь скидывает ссылку на Framer/Webflow/Dribbble
- Говорит «сделай как этот сайт», «хочу похожий», «вот референс»
- Скидывает скриншот дизайна
- Нужен новый сайт для проекта (не PicadaRica)

## Инструкции

### Шаг 1: Получи референс

Источники:
- **Framer** — `framer.com/templates/...` или готовый сайт на `.framer.app`
- **Webflow** — `webflow.com/templates/...` или сайт на `.webflow.io`
- **Dribbble** — `dribbble.com/shots/...` (UI концепты, нет кода)
- **Скриншот** — пользователь кидает картинку

Действия:
1. Открой ссылку через WebFetch — вытащи структуру, секции, цвета, шрифты
2. Для Dribbble — анализируй визуал, опиши layout словами
3. Для скриншотов — Read файл, опиши что видишь

### Шаг 2: Извлеки дизайн-систему

Из референса определи:
- **Палитра:** 3-5 цветов (primary, secondary, accent, bg, text)
- **Шрифты:** заголовки (serif/sans), текст (sans), Google Fonts
- **Сетка:** max-width, колонки, gap
- **Компоненты:** hero, cards, accordion, pricing, testimonials, footer
- **Анимации:** scroll-reveal, hover-effects, parallax, particles

Запиши в `design-tokens` формате:

```javascript
tailwind.config = {
  theme: {
    extend: {
      colors: {
        primary: '#...',
        secondary: '#...',
        accent: '#...',
        bg: '#...',
        text: '#...',
      },
      fontFamily: {
        heading: ['"Font Name"', 'serif'],
        body: ['"Font Name"', 'sans-serif'],
      }
    }
  }
}
```

### Шаг 3: Собери сайт

Стек (фиксированный — MacBook Air 2015 с 4GB RAM):
- **HTML** — один файл, semantic markup
- **Tailwind CSS** — CDN (`cdn.tailwindcss.com`), кастомный конфиг через `<script>`
- **Lucide Icons** — CDN (`unpkg.com/lucide@latest`)
- **Google Fonts** — preconnect + link
- **Vanilla JS** — scroll-reveal, accordion, mobile menu, language switcher
- **Никаких фреймворков** — ни React, ни Vue, ни npm

Структура файла:
```
<head>
  meta charset, viewport, title, description
  Google Fonts preconnect + link
  Tailwind CDN <script>
  Lucide CDN <script>
  tailwind.config <script> с кастомными цветами/шрифтами
  <style> для анимаций, которые Tailwind не покрывает
</head>
<body>
  header (sticky, nav, lang switcher, mobile menu)
  hero section
  content sections
  CTA section
  footer
  <script> для интерактива
</body>
```

### Шаг 4: Анимации

Используй CSS-first подход (загрузи `tools/animations.css` как базу):

| Эффект | Реализация |
|--------|-----------|
| Scroll reveal | IntersectionObserver + `.reveal` class |
| Hover lift | `transition: transform 0.3s; :hover translateY(-4px)` |
| Button shine | `::after` pseudo + gradient translateX |
| Accordion | max-height transition + JS toggle |
| Particles | Canvas 2D (опционально, для hero) |
| Parallax | scroll listener + translateY (для декоративных элементов) |
| Kinetic text | staggered IntersectionObserver с delay |

### Шаг 5: Мультиязычность (если нужно)

Паттерн PicadaRica:
- `data-lang="es|ru|en"` на каждом текстовом элементе
- `class="hidden"` для неактивных языков
- JS функция `setLang(lang)` переключает `.hidden`
- По умолчанию `es` (Аргентина)

### Шаг 6: Деплой

1. Сохрани в папку проекта: `ClaudeProjects/<project>/Сайт/index.html`
2. Если нужен Netlify — используй скилл `deploy-netlify` или ручной деплой

## Чек-лист качества

- [ ] Mobile-first: тестируй на 375px ширины
- [ ] `<meta viewport>` есть
- [ ] Все ссылки target="_blank" для внешних
- [ ] Изображения с `loading="lazy"` и `onerror` fallback
- [ ] Шрифты с `display=swap`
- [ ] `prefers-reduced-motion` для анимаций
- [ ] WhatsApp ссылки: `https://wa.me/НОМЕР`
- [ ] Нет console.log в продакшене
- [ ] favicon (хотя бы SVG inline)

## Ограничения (MacBook Air 2015)

- Никакого npm/webpack/vite — только CDN
- Тяжёлые JS-библиотеки (Three.js, GSAP) — избегать
- Видео-фоны — нет (4GB RAM)
- Максимум canvas particles в hero, и то с frame skip
