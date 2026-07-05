FROM nvidia/cuda:12.2.2-runtime-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive

# Установка системных зависимостей (включая zstd для Ollama)
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    iptables \
    sudo \
    ca-certificates \
    git \
    zstd \
    && rm -rf /var/lib/apt/lists/*

# Официальная установка Ollama в систему
RUN curl -fsSL https://ollama.com/install.sh | sh

# Установка Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

WORKDIR /app

# Копируем файлы конфигурации моделей и скрипт запуска
COPY gemma4.modelfile qwen36.modelfile fable.modelfile start.sh ./
RUN chmod +x start.sh

# Открываем порт Ollama наружу
EXPOSE 11434

CMD ["./start.sh"]
