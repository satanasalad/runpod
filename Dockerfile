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

RUN curl -fsSL https://tailscale.com/install.sh | sh

WORKDIR /app

COPY gemma4.modelfile qwen36.modelfile fable.modelfile start.sh ./
RUN chmod +x start.sh

EXPOSE 11434

CMD ["./start.sh"]
