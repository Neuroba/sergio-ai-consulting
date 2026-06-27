#!/usr/bin/env python3
"""
Windows Agent — управление Windows через Telegram.
Только от твоего chat_id. Запуск: python agent.py
"""
import json, os, subprocess, sys, time, threading
from pathlib import Path
from urllib import request as ur

# ─── КОНФИГ ───────────────────────────────────────────────────────────────────
CONFIG    = Path(__file__).parent / 'config.json'
_cfg      = json.loads(CONFIG.read_text()) if CONFIG.exists() else {}
BOT_TOKEN = _cfg.get('bot_token', '')
PROJECTS  = Path.home() / 'Projects' / 'ClaudeProjects'
LOG       = Path(__file__).parent / 'agent.log'

def load_cfg():
    if CONFIG.exists():
        return json.loads(CONFIG.read_text())
    return {}

def save_cfg(d):
    CONFIG.write_text(json.dumps(d, indent=2))

# ─── TELEGRAM ─────────────────────────────────────────────────────────────────
BASE = f'https://api.telegram.org/bot{BOT_TOKEN}'
_offset = 0

def tg(method, data=None):
    try:
        body = json.dumps(data or {}).encode()
        req  = ur.Request(f'{BASE}/{method}', data=body,
                          headers={'Content-Type': 'application/json'})
        with ur.urlopen(req, timeout=15) as r:
            return json.loads(r.read())
    except Exception as e:
        log(f'TG error: {e}')
        return None

def send(chat_id, text):
    tg('sendMessage', {'chat_id': chat_id, 'text': text, 'parse_mode': 'HTML'})

def get_updates():
    global _offset
    r = tg('getUpdates', {'offset': _offset, 'timeout': 5, 'limit': 20})
    if r and r.get('ok') and r.get('result'):
        upds = r['result']
        if upds:
            _offset = upds[-1]['update_id'] + 1
        return upds
    return []

# ─── ЛОГГЕР ───────────────────────────────────────────────────────────────────
def log(msg):
    ts = time.strftime('%H:%M:%S')
    line = f'[{ts}] {msg}'
    print(line)
    try:
        with open(LOG, 'a', encoding='utf-8') as f:
            f.write(line + '\n')
    except:
        pass

# ─── КОМАНДЫ ──────────────────────────────────────────────────────────────────
def run(cmd, cwd=None, timeout=60):
    try:
        r = subprocess.run(
            cmd, shell=True, cwd=cwd,
            capture_output=True, text=True, timeout=timeout,
            encoding='utf-8', errors='replace'
        )
        out = (r.stdout + r.stderr).strip()
        return out[:1500] if out else '(нет вывода)', r.returncode == 0
    except subprocess.TimeoutExpired:
        return '⏱ Таймаут', False
    except Exception as e:
        return str(e), False

def find_project(name):
    """Найти папку проекта по ключевому слову"""
    name = name.lower()
    mapping = {
        'pushup': PROJECTS / '03-PushUp-Приложение' / 'pixel-perfect-clone-59134',
        'picada': PROJECTS / '01-PicadaRica' / 'Сайт',
        'ai':     PROJECTS / '06-AI-для-бизнеса' / 'site',
    }
    for k, v in mapping.items():
        if k in name:
            return v
    return None

HELP_TEXT = """⬡ <b>Windows Agent — команды:</b>

/status — состояние агента и системы
/ls — список проектов
/pull — git pull всех проектов
/pull pushup — git pull конкретного проекта
/npm — npm install в PushUp
/dev — запустить npm run dev (PushUp)
/stop — остановить dev сервер
/code — открыть VS Code
/claude — как запустить Claude Code
/help — эта справка

<i>Все команды выполняются на Windows-компе.</i>"""

def handle(chat_id, text):
    text = text.strip()
    cmd  = text.split()[0].lower().lstrip('/')
    args = text.split()[1:] if len(text.split()) > 1 else []

    if cmd in ('start', 'hello', 'привет'):
        send(chat_id, '✅ <b>Windows Agent активен!</b>\nКомпьютер онлайн и готов к работе.\n\n' + HELP_TEXT)

    elif cmd == 'help':
        send(chat_id, HELP_TEXT)

    elif cmd == 'status':
        py, _   = run('python --version')
        node, _ = run('node --version')
        npm, _  = run('npm --version')
        git, _  = run('git --version')
        disk, _ = run('wmic logicaldisk get size,freespace,caption')
        send(chat_id,
            f'🖥 <b>Windows Agent — статус</b>\n\n'
            f'🐍 {py}\n📦 node {node}\n📦 npm {npm}\n🔧 {git}\n\n'
            f'📁 Проекты: {PROJECTS}\n'
            f'💾 Диски:\n<code>{disk[:300]}</code>'
        )

    elif cmd == 'ls':
        if PROJECTS.exists():
            dirs = [d.name for d in sorted(PROJECTS.iterdir()) if d.is_dir()]
            send(chat_id, '📁 <b>Проекты:</b>\n' + '\n'.join(f'  • {d}' for d in dirs))
        else:
            send(chat_id, f'⚠️ Папка не найдена: {PROJECTS}')

    elif cmd == 'pull':
        target = args[0] if args else None
        if target:
            path = find_project(target)
            if not path or not path.exists():
                send(chat_id, f'⚠️ Проект не найден: {target}')
                return
            send(chat_id, f'🔄 git pull → {path.name}...')
            out, ok = run('git pull', cwd=str(path))
            send(chat_id, f'{"✅" if ok else "❌"} <code>{out}</code>')
        else:
            # Все проекты с .git
            repos = [d for d in PROJECTS.rglob('.git') if d.is_dir()]
            if not repos:
                send(chat_id, '⚠️ Git-репозитории не найдены')
                return
            send(chat_id, f'🔄 git pull в {len(repos)} репозиториях...')
            results = []
            for r in repos:
                path = r.parent
                out, ok = run('git pull', cwd=str(path), timeout=30)
                icon = '✅' if ok else '❌'
                results.append(f'{icon} {path.name}: {out.splitlines()[0] if out else "ok"}')
            send(chat_id, '\n'.join(results[:15]))

    elif cmd == 'npm':
        path = find_project('pushup')
        if not path or not path.exists():
            send(chat_id, '⚠️ PushUp не найден')
            return
        send(chat_id, '📦 npm install... (может занять 2-3 мин)')
        out, ok = run('npm install', cwd=str(path), timeout=180)
        send(chat_id, f'{"✅" if ok else "❌"} npm install\n<code>{out[-500:]}</code>')

    elif cmd == 'dev':
        path = find_project('pushup')
        if not path or not path.exists():
            send(chat_id, '⚠️ PushUp не найден')
            return
        send(chat_id, '🚀 Запускаю npm run dev...')
        def _run_dev():
            subprocess.Popen('npm run dev', shell=True, cwd=str(path))
        threading.Thread(target=_run_dev, daemon=True).start()
        time.sleep(3)
        send(chat_id, '✅ Dev сервер запущен → http://localhost:5173')

    elif cmd == 'stop':
        run('taskkill /F /IM node.exe')
        send(chat_id, '🛑 Node.js процессы остановлены')

    elif cmd == 'code':
        subprocess.Popen(f'code "{PROJECTS}"', shell=True)
        send(chat_id, f'✅ VS Code открывается → {PROJECTS}')

    elif cmd == 'claude':
        send(chat_id,
            '⬡ <b>Claude Code:</b>\n\n'
            '1. Открой терминал в VS Code (Ctrl+`)\n'
            '2. Напиши: <code>claude</code>\n'
            '3. При первом запуске откроется браузер → войди в аккаунт\n\n'
            'Или открой PowerShell и запусти: <code>claude</code>'
        )

    else:
        send(chat_id, f'❓ Неизвестная команда: /{cmd}\n\nНапиши /help')

# ─── ГЛАВНЫЙ ЦИКЛ ─────────────────────────────────────────────────────────────
def main():
    cfg = load_cfg()
    owner_id = cfg.get('owner_id')

    log('🚀 Windows Agent запущен')

    # Проверить соединение
    me = tg('getMe')
    if not me or not me.get('ok'):
        log('❌ Нет соединения с Telegram')
        sys.exit(1)
    log(f'✅ Бот: @{me["result"]["username"]}')

    if not owner_id:
        log('⚠️  owner_id не задан. Напиши /start боту @PicadaRicaProduccionBot — ID сохранится автоматически.')

    while True:
        try:
            for upd in get_updates():
                msg = upd.get('message', {})
                if not msg:
                    continue

                chat_id = msg.get('chat', {}).get('id')
                text    = msg.get('text', '').strip()
                frm     = msg.get('from', {})

                if not chat_id or not text:
                    continue

                # Первое сообщение — запомнить owner
                if not owner_id:
                    owner_id = chat_id
                    cfg['owner_id'] = owner_id
                    save_cfg(cfg)
                    log(f'✅ owner_id сохранён: {owner_id}')
                    send(chat_id,
                        f'🔐 <b>Доступ разрешён!</b>\n'
                        f'Windows Agent привязан к твоему аккаунту.\n\n' + HELP_TEXT)
                    continue

                # Только от owner
                if chat_id != owner_id:
                    log(f'🚫 Отклонён: {chat_id} ({frm.get("username")})')
                    continue

                log(f'← {text[:60]}')
                handle(chat_id, text)

        except KeyboardInterrupt:
            log('🛑 Агент остановлен')
            break
        except Exception as e:
            log(f'Error: {e}')

        time.sleep(2)

if __name__ == '__main__':
    main()
