# AI Consulting Site — Документация

**Live:** https://sergio-ai-consulting.netlify.app  
**Deploy:** `npx netlify-cli deploy --prod --site 2e671e36-a750-4604-b687-6f06c36415d2 --dir .`  
**Файлы:** `index.html` (main), `admin.html` (CRM), `netlify.toml`

---

## Воронка (порядок секций)

```
HERO → PAIN → SOLUTION → CASES → HOW → PRICING → FAQ → CTA
```

| # | Секция | HTML ID | Цель в воронке |
|---|--------|---------|----------------|
| 1 | Hero | `#hero` (нет id, просто первая) | Захват внимания, главная проблема |
| 2 | Pain | нет id | Усиление боли, узнавание |
| 3 | Solution | нет id | Как я решаю, value stream схема |
| 4 | **Cases** | `#cases` | Доказательство — 4 кейса с кодом, мокапами, CTA |
| 5 | How it works | `#how` | Процесс: аудит → внедрение → результаты |
| 6 | Pricing | нет id | Тарифы + Personal OS бесплатно в Аудит |
| 7 | FAQ | нет id | Снятие возражений |
| 8 | CTA | `#cta` | Финальный призыв к действию |

---

## Блок кейсов (`#cases`)

Один блок — 4 таба. Каждый таб = отдельный `case-panel`.

| Таб | id панели | Цвет (`--tc`) | Иконка |
|-----|-----------|---------------|--------|
| PushUp App | `#panel-pushup` | `#22d3ee` | `solar:dumbbell-bold-duotone` |
| PicadaRica | `#panel-picadarica` | `#f43f5e` | `solar:fire-bold-duotone` |
| AI Consulting | `#panel-consulting` | `#818cf8` | `solar:cpu-bolt-bold-duotone` |
| AI Personal OS | `#panel-personal` | `#f59e0b` | `solar:brain-bold-duotone` |

**Структура каждой панели:**
```
case-panel
├── grid lg:grid-cols-2
│   ├── Left: cp-tag chips | h3 | cp-metric (×3) | before/after grid | cp-built-row (×3)
│   └── Right: device/code mockup (phone/telegram/browser/notion)
└── panel-cta-bar (CTA с ключевым числом → WhatsApp)
```

**CSS классы кейсов:**
- `.case-tab-btn` — кнопка таба, `--tc` = accent color
- `.case-panel` — контент таба (`.hidden` = скрыт)
- `.cp-tag` — чип технологии (`--cc` bg, `--ct` color)
- `.cp-metric` — большое число (`--mc` color)
- `.cp-row.cp-bad` / `.cp-row.cp-good` — строки до/после
- `.cp-built-row` — что построено
- `.cp-code` + `.cp-code-bar` — окно с кодом
- `.panel-cta-bar` — CTA полоска внизу панели

---

## Иконки

Все иконки: **Solar Bold Duotone** через Iconify web component.  
CDN: `https://cdn.jsdelivr.net/npm/iconify-icon@2.1.0/dist/iconify-icon.min.js`  
Формат: `<iconify-icon icon="solar:NAME-bold-duotone">`

**Анимации иконок:**
| Класс | Движение |
|-------|---------|
| `.i-spin` | Вращение 18s |
| `.i-spin-r` | Обратное 7s |
| `.i-float` | Вверх-вниз 3s |
| `.i-pulse` | Масштаб 2.5s |
| `.i-zap` | Вспышка 3.5s |
| `.i-rocket` | Полёт с наклоном |
| `.i-flicker` | Мерцание + skew |
| `.i-beat` | Пульс ×2 |
| `.i-scan` | Движение по диагонали |
| `.i-write` | Покачивание |
| `.i-drop` | Вниз-вверх |

---

## Мультиязычность (i18n)

**Языки:** EN (по умолчанию) / ES (аргентинский, rioplatense) / RU

**Как работает:**
```js
const T = {en:{...}, es:{...}, ru:{...}};
function setLang(l) { curLang = l; ... }
```

**Добавить новый ключ:**
1. Добавить `data-i18n="NEW_KEY"` на элемент
2. В объекте `T` добавить в каждый язык: `"NEW_KEY": "текст"`

**Группы ключей:**
- `nav.*` — навигация
- `hero.*` — hero секция
- `pain.*` — pain points
- `vs.*` — value stream (solution)
- `proof.*` — (устарело, удалено)
- `cases.*` — кейсы (c1-c4: h/b1-4/a1-4/w1-3)
- `pcta.*` — CTA в панелях кейсов
- `how.*` — как работает
- `price.*` — цены (ps = Personal OS bonus)
- `faq.*` — FAQ
- `cta.*` — финальный CTA
- `ps.*` — Personal System (удалено как секция, остался в price.ps)

---

## Цветовая система

```css
/* Основные акценты */
--neon-cyan: #22d3ee      /* PushUp, Solutions */
--accent: #6366f1         /* Основной акцент (indigo) */
--accent-light: #818cf8   /* Consulting case */
--neon-red: #f43f5e       /* PicadaRica */
--neon-green: #22c55e     /* Успех, результаты */
--neon-purple: #a855f7    /* Второй акцент */
--amber: #f59e0b          /* Personal OS, бесплатное */
```

**Glass morphism:**
- `.glass` — лёгкий (backdrop-blur:12px)
- `.glass-strong` — плотный (backdrop-blur:32px, для карточек)

---

## Как изменять отдельные блоки

### Добавить/изменить кейс

1. Добавить таб-кнопку в `#case-tabs` (копируй существующую, меняй `data-tab`, `--tc`, иконку)
2. Добавить панель `id="panel-NEWNAME"` с классом `.case-panel.hidden`
3. Добавить i18n ключи в T объект (en/es/ru)
4. JS переключения подхватит автоматически

### Изменить цену

Найти `<!-- ═══ PRICING ═══ -->` → 4 карточки с `.glass-strong`

### Изменить FAQ

Найти `<!-- ═══ FAQ ═══ -->` → аккордеон с `faq.q1`...`faq.q5`

### Изменить hero stats

Найти 4 `.hud-card.glass-strong` в hero → `data-target` = число, `data-suffix` = суффикс

### Изменить контакты

`href="https://wa.me/5491140466022"` — WhatsApp (глобально заменить на новый номер)  
`href="https://www.linkedin.com/in/sergei-zubov"` — LinkedIn

---

## Деплой

```bash
cd site
npx netlify-cli deploy --prod --site 2e671e36-a750-4604-b687-6f06c36415d2 --dir .
```

Site ID: `2e671e36-a750-4604-b687-6f06c36415d2`  
Netlify project: `sergio-ai-consulting`

---

## Personal OS — УТП

**Позиция в воронке:** Pricing (Audit tier) — строка с 🎁  
**Ключ:** `price.ps`  
**Содержание:** Notion workspace + Todoist setup + Health log — бесплатно навсегда  
**Подробности:** `07-Personal-System/README.md`

Не создавать отдельную секцию — Personal OS это:
1. 4-й кейс в табах (показывает ЧТО это)
2. Строка 🎁 в Pricing / Audit (показывает ЧТО КЛИЕНТ ПОЛУЧАЕТ)
