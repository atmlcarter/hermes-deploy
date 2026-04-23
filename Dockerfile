# Dockerfile for the Hermes Agent Telegram gateway + keepalive endpoint.
# Build:  docker build -t hermes-deploy .
# Run:    docker run -e TELEGRAM_BOT_TOKEN=... -e ANTHROPIC_API_KEY=... -p 8080:8080 hermes-deploy

FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    HERMES_HOME=/root/.hermes \
    PORT=8080 \
    GATEWAY_ALLOW_ALL_USERS=true

RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates curl build-essential \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone upstream Hermes Agent and install it into the system Python.
RUN git clone --depth 1 https://github.com/NousResearch/hermes-agent.git /app/hermes-agent
WORKDIR /app/hermes-agent
RUN pip install --upgrade pip \
 && pip install -e .

# Configure default model (best-effort; ignored if config schema differs).
RUN mkdir -p "$HERMES_HOME" \
 && hermes config set model.default anthropic/claude-opus-4-5 || true \
 && echo "GATEWAY_ALLOW_ALL_USERS=true" >> "$HERMES_HOME/.env"

WORKDIR /app
COPY keepalive.py /app/keepalive.py

EXPOSE 8080

# Launch keepalive HTTP server alongside the Telegram gateway.
# `exec` on the gateway makes it PID 1's foreground child so signals propagate.
CMD ["sh", "-c", "trap 'kill 0' EXIT INT TERM; python /app/keepalive.py & cd /app/hermes-agent && exec hermes gateway run --accept-hooks"]
