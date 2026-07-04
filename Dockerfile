FROM nvidia/cuda:12.2.2-runtime-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    iptables \
    sudo \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# 1. Установка Tailscale через официальный скрипт
RUN curl -fsSL https://tailscale.com/install.sh | sh

# 2. Установка Ollama с флагом игнорирования инициализации GPU/сервиса
ENV OLLAMA_SKIP_STARTING_SERVICE=1
RUN curl -fsSL https://ollama.com/install.sh | sh

WORKDIR /app

# Копируем конфиги и скрипт запуска
COPY gemma4.modelfile qwen36.modelfile fable.modelfile start.sh ./
RUN chmod +x start.sh

EXPOSE 11434

CMD ["./start.sh"]
