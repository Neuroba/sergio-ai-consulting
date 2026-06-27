# Установка Windows Agent на этот компьютер
# Запуск: irm https://neuroba.github.io/sergio-ai-consulting/install-agent.ps1 | iex

$AGENT_DIR = "$env:USERPROFILE\agent"
$AGENT_URL = "https://raw.githubusercontent.com/Neuroba/sergio-ai-consulting/main/windows-agent/agent.py"

Write-Host ""
Write-Host "=== Windows Agent Setup ===" -ForegroundColor Cyan
Write-Host ""

# Создать папку
New-Item -ItemType Directory -Force -Path $AGENT_DIR | Out-Null

# Скачать agent.py
Write-Host "Скачиваю агента..." -ForegroundColor Yellow
Invoke-WebRequest $AGENT_URL -OutFile "$AGENT_DIR\agent.py" -UseBasicParsing
Write-Host "✓ agent.py скачан" -ForegroundColor Green

# Токен — скопируй с http://192.168.1.62:8765/tokens
Write-Host ""
Write-Host " Открой в браузере: http://192.168.1.62:8765/tokens" -ForegroundColor Cyan
$token = Read-Host " Вставь Bot Token"

$config = @{
    bot_token = $token
    owner_id  = $null
}
$config | ConvertTo-Json | Set-Content -Path "$AGENT_DIR\config.json" -Encoding UTF8
Write-Host "✓ config.json создан" -ForegroundColor Green

# Создать запускатор
$RUN_BAT = @"
@echo off
cd /d %USERPROFILE%\agent
python agent.py
pause
"@
Set-Content -Path "$AGENT_DIR\start-agent.bat" -Value $RUN_BAT

# Ярлык на рабочем столе
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Windows Agent.lnk")
$Shortcut.TargetPath = "$AGENT_DIR\start-agent.bat"
$Shortcut.WorkingDirectory = $AGENT_DIR
$Shortcut.WindowStyle = 1
$Shortcut.Save()

Write-Host ""
Write-Host "=============================" -ForegroundColor Cyan
Write-Host " ✅ Агент установлен!         " -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""
Write-Host " Файлы:  $AGENT_DIR" -ForegroundColor White
Write-Host ""
Write-Host " Следующий шаг:" -ForegroundColor Yellow
Write-Host "   1. Запусти 'Windows Agent' с рабочего стола" -ForegroundColor Gray
Write-Host "   2. Напиши /start боту @PicadaRicaProduccionBot в Telegram" -ForegroundColor Gray
Write-Host "   3. Агент привяжется к твоему аккаунту и будет слушать команды" -ForegroundColor Gray
Write-Host ""

# Запустить агента сразу
$start = Read-Host "Запустить агента прямо сейчас? (Y/n)"
if ($start -ne "n" -and $start -ne "N") {
    Start-Process "$AGENT_DIR\start-agent.bat"
    Write-Host ""
    Write-Host " Напиши /start боту @PicadaRicaProduccionBot в Telegram!" -ForegroundColor Cyan
}
