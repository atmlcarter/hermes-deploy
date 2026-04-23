# Hermes Agent — Deployment Wrapper

Thin deploy wrapper around [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) configured to run as a Telegram bot with an HTTP keepalive endpoint suitable for uptime monitors (UptimeRobot, etc.).

## What's in here

| File | Purpose |
|---|---|
| `setup.sh` | Clones the upstream Hermes repo and runs its installer (`setup-hermes.sh`), then sets default model and gateway access. Idempotent. |
| `run.sh` | Starts the keepalive HTTP server + the Hermes Telegram gateway in the same process group. |
| `keepalive.py` | Tiny stdlib HTTP server. Binds to `$PORT` (default 8081) and returns `200 OK` on every request. |
| `.env.example` | Required environment variables. |

## First-time setup

```bash
bash setup.sh
```

This clones `hermes-agent/` into the current directory and installs it (uses `uv`, creates `hermes-agent/venv/`, ~600 MB).

## Required environment variables

| Var | Source |
|---|---|
| `TELEGRAM_BOT_TOKEN` | [@BotFather](https://t.me/BotFather) |
| `ANTHROPIC_API_KEY` | <https://console.anthropic.com/> |

## Running

```bash
bash run.sh
```

The keepalive endpoint is reachable at `http://<host>:$PORT/` and returns `Hermes gateway alive`.

## Deploying on Replit Reserved VM

- Run command: `bash run.sh`
- Build command: (empty — `setup.sh` is run manually once)
- Set `TELEGRAM_BOT_TOKEN` and `ANTHROPIC_API_KEY` as Secrets.

## Locking down access

By default `setup.sh` sets `GATEWAY_ALLOW_ALL_USERS=true` in `~/.hermes/.env`. To restrict to specific Telegram user IDs, edit `~/.hermes/.env`:

```
GATEWAY_ALLOW_ALL_USERS=false
TELEGRAM_ALLOWED_USERS=123456789,987654321
```

Get your Telegram user ID by messaging [@userinfobot](https://t.me/userinfobot).

## Credits

All agent functionality belongs to [Nous Research](https://nousresearch.com). This wrapper just packages a deploy configuration. License: MIT (matches upstream).
