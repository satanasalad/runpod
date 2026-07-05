#!/bin/bash
set -e # Прерывать выполнение при любой ошибке

echo "[INFO] Starting Tailscale daemon..."
tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055 &
sleep 3

if [ -n "$TS_AUTHKEY" ]; then
    echo "[INFO] Connecting to Tailscale network..."
    tailscale up --authkey="$TS_AUTHKEY" --accept-routes=false
else
    echo "[WARNING] TS_AUTHKEY is not set. Tailscale might not route properly."
fi

echo "[INFO] Starting Ollama server..."
export OLLAMA_HOST=0.0.0.0:11434
ollama serve &
sleep 5

# Путь, куда Ollama складывает манифесты созданных моделей
MANIFEST_DIR="/root/.ollama/models/manifests/registry.ollama.ai/library"

echo "[INFO] Checking models initialization..."

# 1. Сборка Gemma 4
if [ ! -f "$MANIFEST_DIR/gemma4" ]; then
    echo "[INFO] Downloading and creating Gemma 4 (31B Q4)..."
    wget -O gemma-4-31b-q4_k_m.gguf "https://huggingface.co/Dev-Louislu/gemma-4-31B-Q4_K_M-GGUF/resolve/main/gemma-4-31b-q4_k_m.gguf"
    ollama create gemma4 -f ./gemma4.modelfile
    rm gemma-4-31b-q4_k_m.gguf
    echo "[SUCCESS] Gemma 4 created successfully."
fi

# 2. Сборка Qwen 3.6
if [ ! -f "$MANIFEST_DIR/qwen36" ]; then
    echo "[INFO] Downloading and creating Qwen 3.6 (27B Q4)..."
    wget -O qwen3.6-27b-q4_k_m.gguf "https://huggingface.co/sm54/Qwen3.6-27B-Q4_K_M-GGUF/resolve/main/qwen3.6-27b-q4_k_m.gguf"
    ollama create qwen36 -f ./qwen36.modelfile
    rm qwen3.6-27b-q4_k_m.gguf
    echo "[SUCCESS] Qwen 3.6 created successfully."
fi

# 3. Сборка Fable Coder
if [ ! -f "$MANIFEST_DIR/fable-coder" ]; then
    echo "[INFO] Downloading and creating Fable Coder..."
    wget -O gemma-4-31b-fable-coder-i1-gguf.gguf "https://huggingface.co/mradermacher/Gemma-4-31B-Fable-Coder-i1-GGUF/resolve/main/Gemma-4-31B-Fable-Coder.i1-Q4_K_M.gguf"
    ollama create fable-coder -f ./fable.modelfile
    rm gemma-4-31b-fable-coder-i1-gguf.gguf
    echo "[SUCCESS] Fable Coder created successfully."
fi

echo "[READY] All models loaded. Server is fully operational."

# Удерживаем контейнер активным
wait
