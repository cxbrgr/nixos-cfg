# Hermes — Plan & Context

> Read this first if you're a new Claude session picking up Hermes. Pair it with `README.md` (operational bring-up) and `/mnt/hmsrvr/data/docker/hermes/workspace/` (the agent's "soul" files).

## What this is

A voice-first personal assistant for Chris. Phase 1 MVP: tap mic, talk to it, it journals and runs simple skills. Phase 2: read-only ingestion of WhatsApp + email, proactive nudges ("you haven't texted X in 3 days"), social-graph awareness, weekly reviews.

Hermes is the **successor to "Claw"** (an older file-based Claude-Code-style agent that lived in `/mnt/hmsrvr/data/docker/openclaw/workspace/`). Claw is barely used now but the SOUL.md, USER.md, and nutrition skills were good — Hermes inherits them. **Openclaw is to be left untouched.** We copied what we needed.

## Decisions (locked, don't relitigate)

| Question | Choice | Why |
|---|---|---|
| Voice surface | One device (phone *or* wrkstn browser), not multi-room. Wake word optional. Push-to-talk OK. | Chris wanted minimum-viable, not a smart-home install |
| Brain | **Gemini Live** (cloud API) | Native voice-in/voice-out in one stream — much simpler than Claude + separate STT/TTS. Chris likes Gemini's conversational style |
| LLM hosting | Cloud API for now | Local ollama deferred — even with the 24GB GPU on wrkstn, local LLMs aren't as fluid for coaching |
| Voice frontend stack | **LiveKit + Pipecat** | "Snappy forth-and-back" needs streaming pipeline, barge-in. Not Open WebUI (record-then-send). Not HA Assist (built for home automation, not conversation) |
| LiveKit deployment | **LiveKit Cloud** | Zero infra, free tier covers MVP, works through NAT. Self-host later if needed |
| Host | **hmsrvr** | Always-on, has Docker + the workspace pattern + all existing services. wrkstn powers off |
| Write authority | None in P1 | No sending emails, no posting. Read-and-suggest only |
| Message ingestion | **Deferred to P2** | Beeper isn't used anymore. P2 will use mautrix-whatsapp + tiny Matrix homeserver for WhatsApp, IMAP for email |

## Architecture

```
phone / wrkstn browser
        │
        │ WebRTC (audio + control)
        ▼
   LiveKit Cloud  ◀──── WebRTC ────  hermes-agent (Pipecat, Python)
                                          │
                                          │ persistent bidi audio stream
                                          ▼
                                    Gemini Live (Google AI)
                                          │
                                          │ function calls
                                          ▼
                                    /workspace/  ← files = memory
```

Single Pipecat process. Gemini Live does STT+LLM+TTS in one streaming session. Tools registered with Gemini are workspace-file operations (read/append to memory files, read skills, search).

## File map

### Repo (`~/nixos-cfg/docker/hermes/`)

```
plan.md                 ← this file
README.md               ← operational bring-up
docker-compose.yml      ← two services: hermes-agent + hermes-frontend
.env.example            ← copy to .env, fill in secrets
.env                    ← NOT in repo (gitignored or local-only); has API keys

agent/                  ← Pipecat agent (Python)
├── Dockerfile
├── pyproject.toml
├── agent.py            ← entry point; builds LLM, transport, pipeline
└── tools.py            ← system prompt builder + function tool handlers

frontend/               ← Next.js PWA voice client
├── Dockerfile
├── package.json
├── next.config.mjs
├── tsconfig.json
├── .dockerignore
├── app/
│   ├── layout.tsx
│   ├── page.tsx        ← <LiveKitRoom> + voice assistant UI
│   ├── globals.css
│   └── api/token/route.ts   ← mints LiveKit JWT for browser
└── public/manifest.json     ← PWA basics
```

### Runtime (on hmsrvr: `/data/docker/hermes/workspace/` — via sshfs from wrkstn: `/mnt/hmsrvr/data/docker/hermes/workspace/`)

```
SOUL.md          ← persona / values (copied from openclaw, light voice-mode additions)
IDENTITY.md      ← name, predecessor, vibe (new for Hermes)
USER.md          ← about Chris (copied verbatim from openclaw)
MEMORY.md        ← curated long-term memory (fresh, seeded with inherited project facts)
AGENTS.md        ← workspace operating manual (adapted for voice mode)
TOOLS.md         ← local-env notes (voice stack, hosts, tools list)
HEARTBEAT.md     ← placeholder for P2 scheduler

memory/          ← daily log files YYYY-MM-DD.md, written by append_today()
journal/         ← reserved for structured check-ins (daily-checkin skill)

skills/
├── daily-checkin/SKILL.md        ← morning + evening 2-min flows (new)
├── weekly-review/SKILL.md        ← Friday review (new)
├── log-thought/SKILL.md          ← capture-and-classify brain dumps (new)
├── nutrition-meal-plan/          ← inherited from openclaw
├── nutrition-recipe-discovery/   ← inherited
└── nutrition-shopping-push/      ← inherited
```

## What's done ✅

- [x] Architecture chosen and locked (see decisions table)
- [x] Workspace seed files written, openclaw left intact
- [x] 3 inherited skills copied (nutrition-*)
- [x] 3 new MVP skills written (daily-checkin, weekly-review, log-thought)
- [x] Agent code: Dockerfile, pyproject.toml, agent.py, tools.py
- [x] Tools registered with Gemini: `list_skills`, `read_skill`, `read_file`, `append_today`, `read_today`, `read_yesterday`, `update_memory_index`, `recall`
- [x] System prompt builder concatenates SOUL+IDENTITY+USER+MEMORY+AGENTS + skill index + voice rules
- [x] Frontend: Next.js + LiveKit React components + token API route + PWA manifest
- [x] docker-compose.yml — frontend on host port 3737, agent talks to LiveKit Cloud
- [x] .env.example with all required variables
- [x] README.md with bring-up instructions
- [x] Pipecat 1.1 import paths corrected (see "Watch-points" below)

## What's not done — Phase 1 remaining 🚧

- [ ] **First successful conversation.** As of this writing, the agent was hitting `ModuleNotFoundError` on Pipecat 1.1 — paths fixed in code, needs a rebuild and another run. Likely additional shim issues will surface on first contact (Pipecat 1.x API surface vs what `agent.py` assumes).
- [ ] **Greet-on-join.** When the user joins the room, Hermes should speak first ("Hey Chris, what's on your mind?"). Currently the user has to speak first. `inference_on_context_initialization=True` is the default on `GeminiLiveLLMService` — but no initial user-turn frame is queued. Investigate Pipecat 1.x patterns for sending an initial bot turn.
- [ ] **Phone access.** Browsers require HTTPS for `getUserMedia` on non-localhost. Desktop on `hmsrvr.lan:3737` works. For phone, route through the existing nginx-proxy with a cert. Stack already runs `docker/proxy` — add a vhost for `hermes.<domain>` pointing to `hermes-frontend:3000`.
- [ ] **Wake-word** (nice-to-have). Picovoice Porcupine in the browser would let the page listen passively. Skip until basic conversation feels solid.
- [ ] **Voice picked / tested.** Default is `Puck`. Worth A/B-ing Charon, Kore, Aoede, Fenrir to find what Chris likes. Tweak via `GEMINI_VOICE` in `.env`.
- [ ] **Greeting reads yesterday's note.** When opening morning conversations, Hermes should call `read_yesterday()` before greeting. Currently no system-prompt nudge encourages this — daily-checkin skill mentions it but the model needs reminding. Consider adding a "session-start" hook that pre-fetches and prepends today/yesterday to context.

## What's not done — Phase 2 (deferred) 🔮

- [ ] **WhatsApp ingestion.** Stand up mautrix-whatsapp + a tiny Matrix homeserver (Conduit or Dendrite). Read-only. Hermes reads via Matrix Client-Server API.
- [ ] **Email ingestion.** IMAP read-only, label/folder filtering.
- [ ] **Privacy filter layer.** Config file declaring which contacts/domains/labels Hermes *never* sees. Applied at ingest, not at agent.
- [ ] **Two-agent split for prompt-injection safety.** Ingest-agent (no tools, just summarizes) feeds coach-agent (no raw message text). Avoids the lethal trifecta.
- [ ] **Notifications.** ntfy → phone push. Also a "speak it out loud through Hermes if Chris is at the computer" path.
- [ ] **Social-graph last-contact tracker.** Per-tier nag thresholds (close friends: 7 days, acquaintances: 30 days).
- [ ] **Heartbeat scheduler.** APScheduler or cron firing periodic "check this" prompts at the agent. Tracked state in `memory/heartbeat-state.json` (pattern from openclaw).
- [ ] **Habits / streaks.** Voice-driven habit logging.

## Environment & secrets

Required in `/home/chrisleebear/nixos-cfg/docker/hermes/.env` on hmsrvr (auto-loaded by `docker compose` from the compose file's directory):

```bash
LIVEKIT_URL=wss://<project>.livekit.cloud
LIVEKIT_API_KEY=APIxxx
LIVEKIT_API_SECRET=xxx
LIVEKIT_ROOM=hermes-main

GEMINI_API_KEY=AIzaxxx
GEMINI_VOICE=Puck                                              # optional override
GEMINI_MODEL=models/gemini-2.5-flash-native-audio-preview-12-2025   # SDK current default
GEMINI_TEMPERATURE=0.7                                         # optional override
LOG_LEVEL=INFO                                                 # optional
```

API key sources:
- LiveKit Cloud: https://livekit.io → project → keys
- Gemini: https://aistudio.google.com/apikey

Chris already has both keys and the .env populated as of last session.

## How it runs

On hmsrvr, from `~/nixos-cfg/docker/hermes/` (Chris is in the `docker` group — **no sudo**):

```bash
docker compose up -d --build
docker compose logs -f hermes-agent
```

Frontend: `http://hmsrvr.lan:3737` from a desktop browser. Mic permission required. Tap the mic in the LiveKit control bar.

Iteration:
- Workspace file edits (SOUL.md, skills, etc.) → take effect on next session (system prompt rebuilt at agent startup; restart the agent container to reload)
- Agent code (`agent/*.py`) → `docker compose up -d --build hermes-agent`
- Frontend code → `docker compose up -d --build hermes-frontend`

## Known issues & watch-points ⚠️

### Pipecat API drift

Pipecat had a major 0.0.x → 1.x rename that hit us already:

- `pipecat.services.gemini_multimodal_live.gemini` → `pipecat.services.google.gemini_live.llm`
- `GeminiMultimodalLiveLLMService` → `GeminiLiveLLMService`
- `pipecat.transports.services.livekit` → `pipecat.transports.livekit.transport`

Already fixed in `agent.py`. If new errors appear, the discovery pattern is:

```bash
docker compose run --rm --no-deps --entrypoint sh hermes-agent \
  -c "ls /usr/local/lib/python3.12/site-packages/pipecat/services/ && \
      find /usr/local/lib/python3.12/site-packages/pipecat -type d -iname '*<thing>*'"
```

`GeminiLiveLLMService.__init__` signature has deprecation warnings: `model`, `voice_id`, `params` are deprecated in favor of `settings=GeminiLiveLLMService.Settings(...)`. Still functional but expect noise in logs. Migrate when convenient.

### HTTPS for phone mic

`getUserMedia` requires HTTPS on non-localhost origins. Phone-from-LAN over plain HTTP will fail silently or refuse mic access. Plan: reverse-proxy through the existing `docker/proxy` (nginx-proxy + acme-companion) with a real cert under `hermes.<existing-domain>`.

### Workspace path vs. compose path

The compose mounts the host path `/data/docker/hermes/workspace`. On wrkstn (via sshfs), the same content is at `/mnt/hmsrvr/data/docker/hermes/workspace`. When editing workspace files from wrkstn, use the `/mnt/...` path. Inside the agent container, it's `/workspace`.

### Default voice

Pipecat 1.1's `GeminiLiveLLMService` defaults `voice_id` to `"Charon"`. Our code overrides to `"Puck"` from env. If a voice name is rejected by Gemini, the agent crashes at session start — easy to spot.

### .gitignore

The user removed the `.env`-ignoring block I added from `.gitignore`. He has his own approach to secret-file handling. **Do not re-add it without asking.**

## User context

- **Chris** (chrisleebear, alias cxbrgr — but always say "Chris"). Vienna, Europe/Vienna. German-Austrian locale, English UI.
- Wants casual "two-besties" warmth, not corporate AI tone. Honest but gentle.
- Member of `docker` and `wheel` groups on both hosts → **do NOT prefix sudo to docker / docker compose commands**, you'll get rightly called out.
- Both hosts run NixOS; full system config in `~/nixos-cfg`. Apply changes with `just switch` (uses `nh os switch`).
- Has GPU on wrkstn (Ollama running) but we're not using it for Hermes P1 — cloud only.
- Health context (informs nutrition skills if they get used): psoriasis + weak immune system → anti-inflammatory diet focus. Cuisines: Italian, Indian, Korean, Japanese.

## Voice-mode rules (re-stated for emphasis)

These are encoded in SOUL.md, AGENTS.md, and `tools.py`'s system prompt builder. If the agent starts ignoring them, check those files.

- **No markdown in spoken output.** Asterisks and bullets get read aloud.
- **Short by default.** One or two sentences. Expand on request.
- **One question at a time.**
- **Silence is fine.**
- **Barge-in friendly.** If interrupted, pick up the new thread.

---

_Last updated: 2026-05-12. After Hermes is talking and looping, update the "what's done" section and prune the Phase-1 remaining list._
