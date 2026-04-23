#!/usr/bin/env bash
# Idempotent setup: clones NousResearch/hermes-agent (if missing) and installs it.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -d "hermes-agent" ]; then
  echo "==> Cloning NousResearch/hermes-agent"
  git clone --depth 1 https://github.com/NousResearch/hermes-agent.git
fi

cd hermes-agent

if [ ! -d "venv" ]; then
  echo "==> Running upstream setup-hermes.sh"
  bash setup-hermes.sh
fi

echo "==> Configuring default model"
./venv/bin/hermes config set model.default anthropic/claude-opus-4-5 || true

mkdir -p "$HOME/.hermes"
if ! grep -q "^GATEWAY_ALLOW_ALL_USERS=" "$HOME/.hermes/.env" 2>/dev/null; then
  echo "GATEWAY_ALLOW_ALL_USERS=true" >> "$HOME/.hermes/.env"
fi

echo "==> Done. Required env vars: TELEGRAM_BOT_TOKEN, ANTHROPIC_API_KEY"
echo "==> Start with:  bash run.sh"
