# Hermes Setup Analysis — Revised

## What You Designed vs What Got Built

### The Original Design (from plan.md)

```
Phone/Browser  →  LiveKit (pipes)  →  Pipecat (orchestrator)  →  Hermes (brain)
                                             ↕                        ↕
                                      Deepgram (STT)           /workspace/
                                      Cartesia (TTS)         SOUL, memory, skills
```

**Hermes = the brain.** A separate service owning the system prompt, identity files, memory, tools, and the LLM API call. From Pipecat's perspective, it's "just an HTTP endpoint that takes text and returns text." Each layer swappable independently.

### What Actually Got Built

```
Phone/Browser  →  LiveKit Cloud  →  Pipecat + Gemini Live (all-in-one)
                                          ↕
                                    /workspace/ (custom file tools)
```

Gemini Live collapsed STT + LLM + TTS into one stream inside Pipecat. The "brain" logic (system prompt builder, 8 file tools, memory/skills access) was reimplemented inline in `agent.py` + `tools.py`. There is no separate Hermes brain service — the layers fused.

> [!IMPORTANT]
> This means you're running a **custom Pipecat agent with Hermes-like features baked in**, not the official Hermes Agent as the brain. The original layered design was never realized.

---

## How to Get Back to the Original Design

The official `nousresearch/hermes-agent` exposes an **OpenAI-compatible API server** on port `8642`. Pipecat has `OpenAILLMService` with `base_url` override. These two fit together perfectly.

### Target Architecture

```
Phone/Browser → LiveKit Cloud → Pipecat (orchestrator)
                                    ↕
                              Deepgram (STT) 
                                    ↓
                              Hermes Agent (brain) ← OpenAI-compatible API on :8642
                                    ↓               ← owns SOUL.md, memory, skills, tools
                              Cartesia/ElevenLabs (TTS)
                                    ↓
                              LiveKit (audio out)
```

### What Each Container Does

| Container | Image | Role | Ports |
|---|---|---|---|
| `hermes-brain` | `nousresearch/hermes-agent:latest` | Gateway + API server + dashboard | `8642` (API), `9119` (dashboard) |
| `hermes-pipecat` | Custom (your `agent/Dockerfile`) | Voice orchestrator: STT → Hermes API → TTS → LiveKit | none (internal) |
| `hermes-frontend` | Custom (your `frontend/`) | PWA voice client | `3737` |

### The Pipecat Agent Becomes Thin

Instead of Gemini Live (all-in-one), the Pipecat agent uses separate services:

```python
from pipecat.services.deepgram import DeepgramSTTService
from pipecat.services.openai import OpenAILLMService      # ← talks to Hermes
from pipecat.services.cartesia import CartesiaTTSService   # or ElevenLabs
from pipecat.processors.aggregators import LLMContextAggregator

stt = DeepgramSTTService(api_key=DEEPGRAM_KEY)

# Hermes as the brain — OpenAI-compatible endpoint
llm = OpenAILLMService(
    api_key=HERMES_API_KEY,                    # API_SERVER_KEY from Hermes
    base_url="http://hermes-brain:8642/v1",    # internal Docker network
    settings=OpenAILLMService.Settings(
        model="hermes-agent",
    ),
)

tts = CartesiaTTSService(api_key=CARTESIA_KEY, voice_id="...")

context_aggregator = llm.create_context_aggregator()

pipeline = Pipeline([
    transport.input(),             # LiveKit audio in
    stt,                           # Deepgram → text
    context_aggregator.user(),     # collect user context
    llm,                           # Hermes brain (text in → text out)
    tts,                           # Cartesia → audio
    transport.output(),            # LiveKit audio out
    context_aggregator.assistant() # collect assistant context
])
```

### What You Get for Free

By running the official Hermes Agent as the brain:

| Feature | Details |
|---|---|
| **🖥️ Dashboard** | Web UI on `:9119` — status, sessions, config editor, API keys, logs, analytics, cron, skills |
| **🧠 Full tool ecosystem** | Terminal, file ops, web search, browser automation, memory, delegation, code execution |
| **💬 Messaging** | Telegram, Discord, Slack, WhatsApp, Signal, SMS, Email, Matrix — same brain, different surfaces |
| **⏰ Cron jobs** | Scheduled agent tasks with delivery targets |
| **📊 Analytics** | Token usage, cost tracking, per-model breakdown |
| **🔧 Skills catalog** | Official + community skills, toggle from dashboard |
| **🧩 MCP integration** | Connect any MCP server for external tools |
| **💾 Session history** | SQLite with FTS5 search across all conversations |
| **🔄 Memory** | MEMORY.md + USER.md + external memory providers |
| **👤 SOUL.md** | Same persona/identity system you already use |

### What You Trade

| Tradeoff | Impact |
|---|---|
| **Latency** | Gemini Live (current) does STT+LLM+TTS in one streaming session — very low latency. The layered approach adds round-trips: Deepgram → Hermes API → Cartesia. Expect ~200-500ms more. |
| **Barge-in quality** | Gemini Live handles interruption natively in the stream. With separate services, Pipecat's VAD + pipeline cancellation handles it — works but slightly less fluid. |
| **Streaming feel** | Gemini Live streams audio tokens directly. Layered approach: text tokens stream from Hermes, then TTS generates audio chunks — still streaming but one extra hop. |
| **Extra API costs** | Deepgram STT + Cartesia/ElevenLabs TTS are paid services (Deepgram has generous free tier; Cartesia ~$0.015/min). |
| **Complexity** | 3 containers instead of 2. More API keys to manage. |

> [!TIP]
> The design note you quoted already acknowledged this tradeoff: _"If you go Gemini Live, both STT and TTS collapse into the LLM and you skip Deepgram/Cartesia entirely — fewer moving parts, but you lose the ability to swap the brain."_ You're currently on the Gemini Live path. Moving to the layered path restores brain-swappability and unlocks the full Hermes ecosystem.

---

## Docker Compose — Target State

```yaml
services:
  # === THE BRAIN ===
  hermes-brain:
    image: nousresearch/hermes-agent:latest
    container_name: hermes-brain
    restart: unless-stopped
    command: gateway run
    ports:
      - "8642:8642"   # API server (OpenAI-compatible)
      - "9119:9119"   # Dashboard
    volumes:
      - /data/docker/hermes/hermes-data:/opt/data
    environment:
      - HERMES_DASHBOARD=1
      - API_SERVER_ENABLED=true
      - API_SERVER_HOST=0.0.0.0
      - API_SERVER_KEY=${HERMES_API_KEY}
      - TZ=Europe/Vienna
    networks:
      - hermes-net
    deploy:
      resources:
        limits:
          memory: 4G
          cpus: "2.0"

  # === THE ORCHESTRATOR ===
  hermes-pipecat:
    build: ./agent
    image: hermes-pipecat:latest
    container_name: hermes-pipecat
    restart: unless-stopped
    environment:
      - LIVEKIT_URL=${LIVEKIT_URL}
      - LIVEKIT_API_KEY=${LIVEKIT_API_KEY}
      - LIVEKIT_API_SECRET=${LIVEKIT_API_SECRET}
      - LIVEKIT_ROOM=${LIVEKIT_ROOM:-hermes-main}
      - HERMES_API_URL=http://hermes-brain:8642/v1
      - HERMES_API_KEY=${HERMES_API_KEY}
      - DEEPGRAM_API_KEY=${DEEPGRAM_API_KEY}
      - CARTESIA_API_KEY=${CARTESIA_API_KEY}
      - CARTESIA_VOICE_ID=${CARTESIA_VOICE_ID}
      - TZ=Europe/Vienna
    networks:
      - hermes-net

  # === THE FRONTEND ===
  hermes-frontend:
    build: ./frontend
    image: hermes-frontend:latest
    container_name: hermes-frontend
    restart: unless-stopped
    ports:
      - "3737:3000"
    environment:
      - LIVEKIT_URL=${LIVEKIT_URL}
      - LIVEKIT_API_KEY=${LIVEKIT_API_KEY}
      - LIVEKIT_API_SECRET=${LIVEKIT_API_SECRET}
      - LIVEKIT_ROOM=${LIVEKIT_ROOM:-hermes-main}
      - TZ=Europe/Vienna
    networks:
      - hermes-net

networks:
  hermes-net:
    driver: bridge
```

---

## Migration Path

### Step 1: Stand Up Hermes Brain (can do now, non-breaking)

```bash
# Create data dir
mkdir -p /data/docker/hermes/hermes-data

# Run setup wizard to configure API keys
docker run -it --rm \
  -v /data/docker/hermes/hermes-data:/opt/data \
  nousresearch/hermes-agent setup

# Start gateway + dashboard
docker run -d \
  --name hermes-brain \
  --restart unless-stopped \
  -v /data/docker/hermes/hermes-data:/opt/data \
  -p 8642:8642 \
  -p 9119:9119 \
  -e HERMES_DASHBOARD=1 \
  -e API_SERVER_ENABLED=true \
  -e API_SERVER_HOST=0.0.0.0 \
  -e API_SERVER_KEY=$(openssl rand -hex 32) \
  nousresearch/hermes-agent gateway run
```

This gives you the dashboard immediately at `http://hmsrvr.lan:9119` and an API endpoint at `http://hmsrvr.lan:8642/v1` — without touching your existing voice setup.

### Step 2: Copy Your Workspace Files Into Hermes

Copy `SOUL.md`, `IDENTITY.md`, `USER.md`, `MEMORY.md`, skills, etc. from `/data/docker/hermes/workspace/` into `/data/docker/hermes/hermes-data/` (mapping to Hermes's directory structure).

### Step 3: Rewrite the Pipecat Agent (Thin Orchestrator)

Replace `GeminiLiveLLMService` with `OpenAILLMService` + `DeepgramSTTService` + `CartesiaTTSService`. Remove `tools.py` entirely — Hermes owns all tools now.

### Step 4: Merge Into docker-compose.yml

Add the `hermes-brain` service and update `hermes-pipecat` (renamed from `hermes-agent`).

---

## Open Questions

> [!IMPORTANT]
> **Latency vs Features**: Are you willing to accept ~200-500ms extra latency (from the separate STT/TTS services) in exchange for the full Hermes ecosystem? Or would you prefer to keep Gemini Live for voice and run Hermes alongside as a text-only brain?

> [!IMPORTANT]
> **STT/TTS providers**: If going layered:
> - **STT**: Deepgram (best streaming, generous free tier) or Google Cloud STT?
> - **TTS**: Cartesia (lowest latency, ~$0.015/min), ElevenLabs (best voice quality, ~$0.18/min), or Edge TTS (free but lower quality)?

> [!IMPORTANT]
> **Hybrid option**: You could also keep Gemini Live for voice AND run Hermes as a sidecar for text channels (Telegram, dashboard, cron). The voice agent and text agent would share workspace files but not session history. Is that acceptable?
