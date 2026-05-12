# Hermes

Voice-first personal assistant. Pipecat agent → Gemini Live → LiveKit Cloud → PWA frontend.

Phase 1 = MVP: talk to Hermes from phone or browser, journal, basic skills.
Phase 2 (later) = WhatsApp + email read-only ingestion + proactive nudges.

## Layout

```
docker/hermes/
├── docker-compose.yml
├── .env.example          → copy to .env on hmsrvr (next to compose file)
├── agent/                → Python / Pipecat / Gemini Live agent
└── frontend/             → Next.js PWA voice client

/mnt/hmsrvr/data/docker/hermes/    (on hmsrvr: /data/docker/hermes/)
└── workspace/            → Hermes's "home" — identity, soul, memory, journal, skills
```

The agent container mounts `workspace/` and reads/writes it as Hermes lives.

## First bring-up

1. **Get API keys**
   - LiveKit Cloud: https://livekit.io → new project → copy URL + API key + secret
   - Gemini: https://aistudio.google.com/apikey

2. **Copy the compose dir to hmsrvr** (one-time, can also rsync from this repo):
   ```bash
   ssh hmsrvr "sudo mkdir -p /data/docker/hermes"
   rsync -av --exclude node_modules --exclude .next \
     /home/chrisleebear/nixos-cfg/docker/hermes/ \
     hmsrvr:/data/docker/hermes/
   ```

3. **Create `.env` on hmsrvr** (don't commit it):
   ```bash
   ssh hmsrvr
   cd /data/docker/hermes
   sudo cp .env.example .env
   sudo nano .env   # fill in the three LiveKit values + Gemini key
   ```

4. **Bring up the stack on hmsrvr**:
   ```bash
   sudo docker compose up -d --build
   sudo docker compose logs -f hermes-agent
   ```

5. **Open the PWA**: `http://hmsrvr.lan:3737` from desktop, or from phone on the same wifi. The browser will ask for mic permission. Tap the mic in the control bar, say hi.

   To install on phone home screen (PWA): open in Chrome/Safari, Share → Add to Home Screen.

## Iterating

The agent's identity, memory, and skills live entirely in `workspace/` on hmsrvr (mounted from `/data/docker/hermes/workspace/`). Edit those files and the agent picks them up on next session (system prompt is built at startup).

Code changes to `agent/` or `frontend/` require a rebuild:
```bash
sudo docker compose up -d --build hermes-agent
sudo docker compose up -d --build hermes-frontend
```

## Troubleshooting

- **Agent won't connect**: check `LIVEKIT_URL` is the `wss://` URL from LiveKit Cloud (not `https://`).
- **No voice response**: check `GEMINI_API_KEY` is valid; check `docker compose logs hermes-agent` for Gemini errors. The `gemini-2.0-flash-exp` model may be rate-limited on the free tier — switch to `gemini-2.0-flash-live-001` if needed.
- **Mic blocked**: browsers require HTTPS for mic on non-localhost. From phone, either (a) use it on the same wifi so `http://hmsrvr.lan:3737` counts as same-origin localhost-equivalent (it doesn't in most browsers — see next), or (b) put a reverse proxy with a real cert in front. Quickest hack for testing: open `http://hmsrvr.lan:3737` on the desktop, it works there. For phone, plan to add the existing nginx-proxy + cert.
- **Pipecat version drift**: Pipecat's Gemini Live API has changed names a few times. If imports fail, check `pip show pipecat-ai` inside the container and adjust `agent.py` imports.

## Phase 2 plan (not implemented)

- WhatsApp ingestion via `mautrix-whatsapp` + small Matrix homeserver (Conduit), read-only
- Email via IMAP read-only
- Privacy filter at ingest layer
- Split agent: ingest-agent (no tools) → coach-agent (sanitized summaries only)
- Notifications via ntfy → phone push
- Social-graph last-contact tracker
- Heartbeat scheduler (cron or APScheduler) pinging the agent on a cadence
