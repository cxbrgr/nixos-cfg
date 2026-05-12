FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

RUN apt-get update && apt-get install -y --no-install-recommends \
      ffmpeg \
      libsndfile1 \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml ./
RUN pip install --upgrade pip \
    && pip install \
        "pipecat-ai[google,livekit,silero]>=0.0.55" \
        "livekit-api>=0.7.0" \
        "python-dotenv>=1.0.0" \
        "loguru>=0.7.0"

COPY agent.py tools.py ./

CMD ["python", "-u", "agent.py"]
