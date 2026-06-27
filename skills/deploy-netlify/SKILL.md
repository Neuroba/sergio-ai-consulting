---
name: deploy-netlify
description: "Когда нужно задеплоить статический сайт или PWA на Netlify — создание репо, push, настройка домена, редиректы."
---

# Deploy Netlify — деплой сайта на Netlify

## Когда использовать

- «Задеплой на Netlify», «выложи сайт»
- Готовый HTML/CSS/JS нужно опубликовать
- Настройка кастомного домена на Netlify
- SPA-редиректы (все пути → index.html)

## Инструкции

### Шаг 1: Подготовь файлы

Для статического сайта: убедись что `index.html` в корне папки.
Для SPA (React/Vue): добавь `public/_redirects`:
```
/*    /index.html   200
```

### Шаг 2: Git-репозиторий

```bash
cd /путь/к/проекту
git init && git add -A && git commit -m "Initial deploy"
gh repo create <имя> --public --source=. --push
```

### Шаг 3: Деплой

**Вариант A — через GitHub (автодеплой):**
1. Зайди на app.netlify.com → New site → Import from Git
2. Выбери репо → Build command пустой → Publish directory: `.` или `dist/`
3. Deploy → готово, URL: `<имя>.netlify.app`

**Вариант B — Netlify CLI (ручной):**
```bash
npm i -g netlify-cli
netlify deploy --prod --dir=.
```

**Вариант C — Drag & drop:**
Зайди на app.netlify.com/drop → перетяни папку с файлами

### Шаг 4: Кастомный домен (опционально)

1. Netlify → Site settings → Domain management → Add custom domain
2. В DNS провайдере: CNAME запись `www` → `<сайт>.netlify.app`
3. Для apex домена: A запись → IP Netlify (104.198.14.52)
4. SSL включится автоматически (Let's Encrypt)

## Принципы

- Для одностраничных HTML (как PicadaRica) — build command не нужен
- Для Vite/React проектов: build command `npm run build`, publish dir `dist/`
- `_redirects` файл — в `public/` (Vite) или корне (статический)
- Netlify бесплатный план: 100GB bandwidth, 300 минут сборки
