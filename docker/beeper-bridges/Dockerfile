# Dockerfile
FROM debian:bookworm-slim

# Install dependencies https://github.com/beeper/bridge-manager
RUN apt-get update && apt-get install -y \
    curl \
    python3 \
    python3-venv \
    ffmpeg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /usr/local/bin/bbctl https://github.com/beeper/bridge-manager/releases/latest/download/bbctl-linux-amd64 \
    && chmod +x /usr/local/bin/bbctl

# Set data directory to a volume mount point
ENV XDG_DATA_HOME=/data

WORKDIR /app
ENTRYPOINT ["bbctl"]