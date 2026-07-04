#!/bin/bash

# 1. Запуск Tailscale daemon в user-space режиме (чтобы не требовать root-сеть хоста)
tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055 &

# Ожидание инициализации tailscaled
sleep 2

# 2. Авторизация в твоей сети Tailscale через ключ из параметров RunPod
if [ -n "$TS_AUTHKEY" ]; then
    tailscale up --authkey=$TS_AUTHKEY --accept-routes=false
fi

# 3. Запуск Ollama на внешнем интерфейсе для доступа через Tailscale
export OLLAMA_HOST=0.0.0.0:11434
ollama serve &

# Держим контейнер активным
wait
