FROM nvidia/cuda:12.2.2-runtime-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive

# Системные утилиты
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    iptables \
    sudo \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# Установка Tailscale и Ollama
RUN curl -fsSL https://tailscale.com/install.sh | sh
RUN curl -fsSL https://ollama.com/install.sh | sh

WORKDIR /app

# Копируем Modelfiles и скрипт запуска
COPY gemma4.modelfile qwen36.modelfile fable.modelfile start.sh ./
RUN chmod +x start.sh

# Скачиваем тяжелые GGUF-модели напрямую в слой сборки
RUN wget -O gemma-4-31b-q4_k_m.gguf "https://huggingface.co/Dev-Louislu/gemma-4-31B-Q4_K_M-GGUF/resolve/main/gemma-4-31b-q4_k_m.gguf" && \
    wget -O qwen3.6-27b-q4_k_m.gguf "https://huggingface.co/sm54/Qwen3.6-27B-Q4_K_M-GGUF/resolve/main/qwen3.6-27b-q4_k_m.gguf" && \
    wget -O gemma-4-31b-fable-coder-i1-gguf.gguf "https://huggingface.co/mradermacher/Gemma-4-31B-Fable-Coder-i1-GGUF/resolve/main/Gemma-4-31B-Fable-Coder.i1-Q4_K_M.gguf"

# Трюк: инициализируем модели в Ollama, сохраняя их манифесты в /root/.ollama
RUN ollama serve & \
    sleep 5 && \
    ollama create gemma4 -f ./gemma4.modelfile && \
    ollama create qwen36 -f ./qwen36.modelfile && \
    ollama create fable-coder -f ./fable.modelfile && \
    pkill ollama

# Удаляем исходные тяжелые .gguf файлы после импорта, чтобы не дублировать размер образа
RUN rm *.gguf

EXPOSE 11434

CMD ["./start.sh"]
