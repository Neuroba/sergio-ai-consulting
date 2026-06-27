# SERGIO — Windows Setup
# Запуск одной командой в PowerShell:
# irm https://neuroba.github.io/sergio-ai-consulting/windows-setup.ps1 | iex
#
# Или скачать и запустить:
# Invoke-WebRequest "https://neuroba.github.io/sergio-ai-consulting/windows-setup.ps1" -OutFile "$env:TEMP\setup.ps1"; Set-ExecutionPolicy Bypass -Scope Process -Force; & "$env:TEMP\setup.ps1"

$ErrorActionPreference = "Continue"
$BASE_URL   = "https://neuroba.github.io/sergio-ai-consulting"
$PROJECTS   = "$env:USERPROFILE\Projects\ClaudeProjects"
$CLAUDE_DIR = "$env:USERPROFILE\.claude"

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   SERGIO — Установка рабочей среды Windows    " -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# ── 1. ПРОГРАММЫ ──────────────────────────────────────────────────────────────
Write-Host "[ 1/6 ] Установка программ..." -ForegroundColor Yellow

function Install-App($id, $name) {
    $exists = winget list --id $id 2>$null | Select-String $id
    if ($exists) {
        Write-Host "   ✓ $name уже установлен" -ForegroundColor Green
    } else {
        Write-Host "   → Устанавливаю $name..." -ForegroundColor Gray
        winget install --id $id --silent --accept-package-agreements --accept-source-agreements 2>$null
        Write-Host "   ✓ $name установлен" -ForegroundColor Green
    }
}

Install-App "Git.Git"                    "Git"
Install-App "OpenJS.NodeJS.LTS"          "Node.js"
Install-App "Python.Python.3.12"         "Python 3.12"
Install-App "Microsoft.VisualStudioCode" "VS Code"

# Обновить PATH
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("PATH","User")

# Claude Code
Write-Host "   → Устанавливаю Claude Code..." -ForegroundColor Gray
npm install -g @anthropic-ai/claude-code 2>&1 | Out-Null
Write-Host "   ✓ Claude Code установлен" -ForegroundColor Green

# ── 2. ПАПКИ ПРОЕКТОВ ─────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[ 2/6 ] Создание структуры папок..." -ForegroundColor Yellow

$folders = @(
    "$PROJECTS\00-Общее",
    "$PROJECTS\01-PicadaRica",
    "$PROJECTS\02-Покерный-клуб",
    "$PROJECTS\03-PushUp-Приложение",
    "$PROJECTS\04-Comida-Smart",
    "$PROJECTS\05-Банк-Аргентина",
    "$PROJECTS\06-AI-для-бизнеса",
    "$PROJECTS\07-Здоровье-и-Эффективность"
)
foreach ($f in $folders) {
    New-Item -ItemType Directory -Force -Path $f | Out-Null
}
Write-Host "   ✓ Структура папок создана: $PROJECTS" -ForegroundColor Green

# ── 3. КЛОНИРОВАНИЕ GITHUB РЕПОЗИТОРИЕВ ───────────────────────────────────────
Write-Host ""
Write-Host "[ 3/6 ] Клонирование проектов с GitHub..." -ForegroundColor Yellow

function Clone-Repo($url, $dest, $name) {
    if (Test-Path "$dest\.git") {
        Write-Host "   ✓ $name уже клонирован" -ForegroundColor Green
        git -C $dest pull origin main 2>$null | Out-Null
    } else {
        Write-Host "   → Клонирую $name..." -ForegroundColor Gray
        git clone $url $dest 2>&1 | Out-Null
        Write-Host "   ✓ $name клонирован" -ForegroundColor Green
    }
}

Clone-Repo "https://github.com/Neuroba/pixel-perfect-clone-59134" `
           "$PROJECTS\03-PushUp-Приложение\pixel-perfect-clone-59134" `
           "PushUp App"

Clone-Repo "https://github.com/Neuroba/picadarica" `
           "$PROJECTS\01-PicadaRica\Сайт" `
           "PicadaRica сайт"

Clone-Repo "https://github.com/Neuroba/sergio-ai-consulting" `
           "$PROJECTS\06-AI-для-бизнеса\site" `
           "AI Consulting сайт"

# ── 4. CLAUDE CONFIG: СКИЛЛЫ ──────────────────────────────────────────────────
Write-Host ""
Write-Host "[ 4/6 ] Установка скиллов Claude..." -ForegroundColor Yellow

New-Item -ItemType Directory -Force -Path "$CLAUDE_DIR\skills" | Out-Null

$SKILLS = @(
    "app-aso", "capacitor-build", "capacitor-ios-sensor",
    "context-scan", "daily-goals", "deploy-netlify",
    "excel-model", "open-parallel-windows", "pwa-build",
    "rioplatense-copy", "sales-funnel", "site-from-ref",
    "skill-creator", "ui-designer", "unit-economics"
)

foreach ($skill in $SKILLS) {
    $skill_dir = "$CLAUDE_DIR\skills\$skill"
    New-Item -ItemType Directory -Force -Path $skill_dir | Out-Null
    try {
        $url = "$BASE_URL/skills/$skill/SKILL.md"
        Invoke-WebRequest $url -OutFile "$skill_dir\SKILL.md" -UseBasicParsing -TimeoutSec 10 2>$null
        Write-Host "   ✓ /$skill" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠ /$skill (не загрузился)" -ForegroundColor DarkYellow
    }
}

# ── 5. CLAUDE MEMORY ──────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[ 5/6 ] Настройка памяти Claude..." -ForegroundColor Yellow

# Путь memory для Windows
$win_path = $PROJECTS -replace "\\", "/" -replace ":", ""
$win_path = $win_path.TrimStart("/")
$encoded  = "/$win_path" -replace "/", "-"
$encoded  = $encoded.TrimStart("-")
$MEM_DIR  = "$CLAUDE_DIR\projects\$encoded\memory"
New-Item -ItemType Directory -Force -Path $MEM_DIR | Out-Null

# CLAUDE.md в папку Projects
$claude_md_content = @"
## Кто я

Sergio — предприниматель в Буэнос-Айресе, веду 7 проектов параллельно.
Язык работы: русский. Часто пишу с английской раскладкой — декодируй.

## Проекты

| # | Проект | Суть |
|---|--------|------|
| 01 | PicadaRica | Premium beef jerky, маржа ~60% |
| 02 | Покерный клуб | Members-only, Пн/Чт/Сб |
| 03 | PushUp App | Фитнес-приложение, React+Supabase+Capacitor |
| 04 | Comida Smart | Мобильные гастро-модули |
| 05 | Freedom Finance | Партнёрство с FRHC, Аргентина |
| 06 | AI для бизнеса | B2B настройка ИИ |
| 07 | Я | Здоровье, энергия, личные цели |

## Рабочие предпочтения

- Язык: русский (рабочий)
- Цифры: реалистичные, не оптимистичные
- Ответы: коротко, по делу
- Действия: делай сам, не спрашивай разрешения на каждый шаг

## На этом компьютере (Windows)

- Проекты: %USERPROFILE%\Projects\ClaudeProjects
- iOS-сборки: только на Mac (Xcode недоступен)
- Android/Web/Excel: работает здесь
"@

Set-Content -Path "$PROJECTS\CLAUDE.md" -Value $claude_md_content -Encoding UTF8
Write-Host "   ✓ CLAUDE.md создан" -ForegroundColor Green

# MEMORY.md
$memory_index = @"
- [Work style](user_work-style.md) — пошаговые инструкции, один вариант + почему, MVP быстро
- [Project labels](feedback_project-labels.md) — маркировать [PushUp]/[PicadaRica]/etc
- [Open URLs directly](feedback_open-urls-directly.md) — URL открывать через start, не просить копировать
- [Predict problems](feedback_predict-problems.md) — предугадывать проблемы, вопросы о конечных целях
- [Daily report](feedback_daily-report.md) — в конце сессии создавать отчёт в Todoist
- [Windows setup](project_windows-setup.md) — этот компьютер Windows, настройка через neuroba.github.io/sergio-ai-consulting
"@

Set-Content -Path "$MEM_DIR\MEMORY.md" -Value $memory_index -Encoding UTF8
Write-Host "   ✓ Memory структура создана" -ForegroundColor Green

# ── 6. SETTINGS.JSON + ТОКЕНЫ ─────────────────────────────────────────────────
Write-Host ""
Write-Host "[ 6/6 ] Настройка credentials..." -ForegroundColor Yellow
Write-Host ""
Write-Host "   Введи свои токены (Enter = пропустить):" -ForegroundColor White
Write-Host ""

$todoist  = Read-Host "   Todoist API token"
$notion   = Read-Host "   Notion token (ntn_...)"

$settings = @{
    effortLevel = "max"
    language    = "russian"
    mcpServers  = @{}
}

if ($notion) {
    $settings.mcpServers.notion = @{
        command = "npx"
        args    = @("-y", "@notionhq/notion-mcp-server")
        env     = @{
            OPENAPI_MCP_HEADERS = "{`"Authorization`": `"Bearer $notion`", `"Notion-Version`": `"2022-06-28`"}"
        }
    }
    Write-Host "   ✓ Notion MCP настроен" -ForegroundColor Green
}

if ($todoist) {
    $settings.mcpServers.todoist = @{
        command = "npx"
        args    = @("-y", "todoist-mcp")
        env     = @{ TODOIST_API_TOKEN = $todoist }
    }
    Write-Host "   ✓ Todoist MCP настроен" -ForegroundColor Green
}

$settings | ConvertTo-Json -Depth 10 | Set-Content -Path "$CLAUDE_DIR\settings.json" -Encoding UTF8
Write-Host "   ✓ settings.json сохранён" -ForegroundColor Green

# VS Code расширения (те же что на Mac)
Write-Host ""
Write-Host "   Устанавливаю VS Code расширения..." -ForegroundColor Gray
$exts = @(
    "anthropic.claude-code",
    "github.vscode-github-actions",
    "mechatroner.rainbow-csv",
    "ms-python.debugpy",
    "ms-python.python",
    "ms-python.vscode-pylance",
    "ms-python.vscode-python-envs",
    "ms-vscode.powershell",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss"
)
foreach ($ext in $exts) {
    Write-Host "   → $ext" -ForegroundColor Gray
    code --install-extension $ext --force 2>&1 | Out-Null
}
Write-Host "   ✓ VS Code расширения установлены" -ForegroundColor Green

# VS Code settings.json (такой же как на Mac)
Write-Host "   Создаю VS Code settings.json..." -ForegroundColor Gray
$vscode_user = "$env:APPDATA\Code\User"
New-Item -ItemType Directory -Force -Path $vscode_user | Out-Null
$vscode_settings = @"
{
    "claudeCode.preferredLocation": "panel",
    "claudeCode.useTerminal": true,
    "window.restoreWindows": "all",
    "workbench.startupEditor": "none",
    "editor.fontFamily": "'JetBrains Mono', 'Cascadia Code', Consolas, monospace",
    "editor.fontSize": 14,
    "editor.lineHeight": 1.6,
    "editor.minimap.enabled": false,
    "editor.renderWhitespace": "none",
    "terminal.integrated.fontFamily": "'JetBrains Mono', Consolas, monospace",
    "terminal.integrated.fontSize": 13,
    "workbench.colorTheme": "Default Dark Modern",
    "files.autoSave": "onFocusChange",
    "explorer.confirmDelete": false,
    "explorer.confirmDragAndDrop": false,
    "workbench.statusBar.visible": true
}
"@
Set-Content -Path "$vscode_user\settings.json" -Value $vscode_settings -Encoding UTF8
Write-Host "   ✓ VS Code settings.json создан" -ForegroundColor Green

# Горячая клавиша: Ctrl+Shift+A → открыть Claude
$vscode_keys = @"
[
    {
        "key": "ctrl+shift+a",
        "command": "claude.openInPanel"
    },
    {
        "key": "ctrl+shift+a",
        "command": "workbench.view.extension.claude-code-panel",
        "when": "!claudeCodePanelOpen"
    }
]
"@
Set-Content -Path "$vscode_user\keybindings.json" -Value $vscode_keys -Encoding UTF8
Write-Host "   ✓ Горячая клавиша Ctrl+Shift+A → Claude" -ForegroundColor Green

# PushUp: npm install
Write-Host ""
Write-Host "   Устанавливаю зависимости PushUp..." -ForegroundColor Gray
$pushup = "$PROJECTS\03-PushUp-Приложение\pixel-perfect-clone-59134"
if (Test-Path $pushup) {
    Set-Location $pushup
    npm install 2>&1 | Out-Null
    Write-Host "   ✓ PushUp npm install готов" -ForegroundColor Green
}

# ── ИТОГ ──────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   ✅  Установка завершена!                     " -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host " Проекты:    $PROJECTS" -ForegroundColor White
Write-Host " Claude cfg: $CLAUDE_DIR" -ForegroundColor White
Write-Host " Сайт:       https://neuroba.github.io/sergio-ai-consulting" -ForegroundColor White
Write-Host ""
Write-Host " Следующие шаги:" -ForegroundColor Yellow
Write-Host "   1. code $PROJECTS    (открыть VS Code)" -ForegroundColor Gray
Write-Host "   2. claude             (запустить Claude Code)" -ForegroundColor Gray
Write-Host "   3. Claude знает все проекты и скиллы" -ForegroundColor Gray
Write-Host ""
Write-Host " iOS сборки — только на Mac (Xcode)" -ForegroundColor DarkYellow
Write-Host " Android / Web / Excel — работает здесь" -ForegroundColor DarkGreen
Write-Host ""

# Открыть VS Code и запустить claude
$open = Read-Host "Открыть VS Code прямо сейчас? (Y/n)"
if ($open -ne "n" -and $open -ne "N") {
    Start-Process "code" "$PROJECTS"
    Write-Host ""
    Write-Host " Запусти Claude Code командой: claude" -ForegroundColor Cyan
}
