#!/usr/bin/env bash
# Runs the keepalive HTTP server alongside the Hermes Telegram gateway.
# Both processes are tied together so a stop signal kills them as a group.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

trap 'kill 0' EXIT INT TERM

python keepalive.py &
cd hermes-agent
exec ./venv/bin/hermes gateway run --accept-hooks
