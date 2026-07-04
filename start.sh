#!/bin/bash

# 1. Сеть
tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055 &
sleep 2

if [ -n "$TS_AUTHKEY" ]; then
    tailscale up --authkey=$TS_AUTHKEY --accept-routes=false
fi

# 2. Запуск Ollama в фоне
export OLLAMA_HOST=0.0.0.0:11434
ollama serve &
sleep 5

# 3. Проверка: если модели еще не созданы (первый запуск), скачиваем и регистрируем их
if [ ! -f "/root/.ollama/models/manifests/registry.ollama.ai/library/gemma4" ]; then
    echo "First run detected. Downloading models inside RunPod NVMe (this will be fast)..."
    
    wget -O gemma-4-31b-q4_k_m.gguf "https://huggingface.co/Dev-Louislu/gemma-4-31B-Q4_K_M-GGUF/resolve/main/gemma-4-31b-q4_k_m.gguf"
    ollama create gemma4 -f ./gemma4.modelfile
    rm gemma-4-31b-q4_k_m.gguf

    wget -O qwen3.6-27b-q4_k_m.gguf "https://huggingface.co/sm54/Qwen3.6-27B-Q4_K_M-GGUF/resolve/main/qwen3.6-27b-q4_k_m.gguf"
    ollama create qwen36 -f ./qwen36.modelfile
    rm qwen3.6-27b-q4_k_m.gguf

    wget -O gemma-4-31b-fable-coder-i1-gguf.gguf "https://huggingface.co/mradermacher/Gemma-4-31B-Fable-Coder-i1-GGUF/resolve/main/Gemma-4-31B-Fable-Coder.i1-Q4_K_M.gguf"
    ollama create fable-coder -f ./fable.modelfile
    rm gemma-4-31b-fable-coder-i1-gguf.gguf
fi

# Держим контейнер активным
wait
