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

# 2. Чистая установка Ollama (скачиваем стабильный бинарник напрямую в системную папку)
RUN curl -L https://ollama.com/download/ollama-linux-amd64 -o /usr/bin/ollama && \
    chmod +x /usr/bin/ollama

WORKDIR /app

# Копируем только конфиги и скрипт
COPY gemma4.modelfile qwen36.modelfile fable.modelfile start.sh ./
RUN chmod +x start.sh

EXPOSE 11434

CMD ["./start.sh"]
