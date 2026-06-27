# UI Designer — дизайн сайтов и приложений с нуля

## Когда использовать

- «Сделай красивый сайт/лендинг» (без референса — с референсом → `site-from-ref`)
- «Перерисуй/перекраси/переверстай эту страницу»
- «Сделай UI для приложения» (мобильное/веб)
- «Подбери цвета/шрифты/стиль»
- «Сделай дашборд/панель/интерфейс»
- Любая задача где нужен визуальный дизайн без готового референса

## Инструкции

### Шаг 1: Определи тип проекта

| Тип | Стек | Шаблон стилей |
|-----|------|--------------|
| Лендинг B2B | HTML + Tailwind CDN | `tools/styles-b2b.json` |
| Лендинг продукта | HTML + Tailwind CDN | `tools/styles-product.json` |
| Веб-приложение/дашборд | HTML + Tailwind CDN | `tools/styles-dashboard.json` |
| Мобильное приложение | React + Tailwind | `tools/styles-mobile.json` |
| Портфолио/личный | HTML + Tailwind CDN | `tools/styles-personal.json` |

### Шаг 2: Выбери дизайн-систему

Запусти генератор палитры:
```bash
python3 ~/.claude/skills/ui-designer/tools/palette.py --mood "professional" --dark
```

Moods: `professional`, `playful`, `luxury`, `tech`, `warm`, `minimal`, `bold`

### Шаг 3: Примени дизайн-принципы

**Иерархия (самое важное):**
- Один фокусный элемент на экран (H1, CTA, hero image)
- Размер шрифта: H1 48-72px → H2 36-48px → H3 24-30px → body 16-18px
- Контраст: главное яркое, второстепенное приглушённое

**Пространство:**
- Padding секций: 96-128px (py-24 / py-32)
- Gap между карточками: 16-32px
- Max-width контента: 1152-1280px (max-w-6xl / max-w-7xl)
- Текстовые блоки: max-width 640-720px для читаемости

**Цвет (правило 60-30-10):**
- 60% — фон (bg)
- 30% — вторичные элементы (карточки, секции)
- 10% — акцент (CTA, ссылки, метрики)

**Типографика:**
- Заголовки: Inter/Outfit/Plus Jakarta Sans 700-900
- Текст: Inter/DM Sans/Nunito 400-500
- Моноширинный (код): JetBrains Mono/Fira Code
- Line-height: заголовки 1.1-1.2, текст 1.5-1.7

### Шаг 4: Используй компоненты

Загрузи библиотеку: `tools/components.md` — готовые паттерны для:
- Hero (5 вариантов: centered, split, video, gradient, animated)
- Cards (glass, solid, bordered, image-top)
- Navigation (sticky, transparent, hamburger)
- Pricing (3-4 колонки, highlighted tier)
- Testimonials (carousel, grid, single-quote)
- FAQ (accordion, 2-column)
- CTA (centered, split, with-image, sticky-bar)
- Footer (simple, 4-col, dark)

### Шаг 5: Микро-взаимодействия

| Элемент | Эффект | CSS |
|---------|--------|-----|
| Карточка | Lift + glow | `hover:-translate-y-1 hover:shadow-xl transition-all duration-300` |
| Кнопка | Scale + darken | `hover:scale-105 active:scale-95 transition-transform` |
| Ссылка | Underline slide | `relative after:absolute after:bottom-0 after:h-0.5 after:w-0 hover:after:w-full after:transition-all` |
| Секция | Fade in | IntersectionObserver + `opacity-0 translate-y-8 → opacity-100 translate-y-0` |
| Иконка | Rotate/bounce | `hover:rotate-12` или `animate-bounce` |
| Input focus | Ring glow | `focus:ring-2 focus:ring-accent/50 focus:border-accent` |

### Шаг 6: Адаптивность

Breakpoints (mobile-first):
```
Default    = mobile (375px+)
sm: 640px  = large phones
md: 768px  = tablets
lg: 1024px = laptops
xl: 1280px = desktops
```

Паттерны:
- Grid: `grid-cols-1 md:grid-cols-2 lg:grid-cols-3`
- Text: `text-3xl lg:text-5xl`
- Padding: `px-4 md:px-6 lg:px-8`
- Hidden: `hidden md:flex` (nav links), `md:hidden` (hamburger)

## Принципы

- Тёмная тема по умолчанию (2024-2026 тренд, лучше для B2B/tech)
- Glass-morphism для карточек (`backdrop-blur + rgba bg + subtle border`)
- Градиентный текст для акцентов (`bg-gradient-to-r bg-clip-text text-transparent`)
- Минимум цветов — 1 accent + 1-2 нейтральных + 1 success/error
- Шрифт один (Inter покрывает 90% задач)
- Иконки: Lucide (CDN) или emoji (для скорости)
- NO jQuery, NO Bootstrap — только Tailwind CDN + vanilla JS
