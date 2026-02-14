# Media Server Stack

Docker Compose stack running on `hmsrvr` for automated media management via Usenet.

## Stack Overview

| Service | Role | Port | Internal URL | Connects to |
|---------|------|------|--------------|-------------|
| Jellyfin | Media player | 10108 | `jellyfin.hmsrvr.lan` | — |
| Jellyseerr | Request management | 10107 | `jellyseerr.hmsrvr.lan` | Jellyfin, Sonarr, Radarr |
| Prowlarr | Indexer manager | 10101 | `prowlarr.hmsrvr.lan` | Sonarr, Radarr |
| Sonarr | TV series manager | 10102 | `sonarr.hmsrvr.lan` | SABnzbd / qBittorrent |
| Radarr | Movie manager | 10103 | `radarr.hmsrvr.lan` | SABnzbd / qBittorrent |
| Bazarr | Subtitle manager | 10104 | `bazarr.hmsrvr.lan` | Sonarr, Radarr |
| SABnzbd | Usenet download client | 10106 | `sabnzbd.hmsrvr.lan` | — |
| qBittorrent | Torrent download client | 10110 | — | — |

External access (HTTPS) is available for Jellyfin at `watch.stream.cxbrgr.com` and Jellyseerr at `search.stream.cxbrgr.com`.

## Prerequisites

### Directory Structure

All services share a common `/data` mount to enable atomic moves (hardlinks) instead of slow copy+delete operations. The layout:

```
/data
├── usenet
│   ├── complete
│   │   ├── movies
│   │   ├── tv
│   │   └── mixed
│   └── incomplete
├── media
│   ├── movies
│   ├── tv
│   ├── mixed
│   └── music
└── docker
    ├── prowlarr
    ├── sonarr
    ├── radarr
    ├── bazarr
    ├── sabnzbd
    └── jellyfin
```

All directories must be owned by `1000:100` (matching the `PUID`/`PGID` used by containers):

```bash
chown -R 1000:100 /data/usenet /data/media /data/docker
```

### Starting the Stack

```bash
cd docker/media-srvr
docker compose up -d
```

## Initial Configuration

Configure services in the order below. Each step builds on the previous one since services need to reference each other via API keys.

### Step 1 — SABnzbd

Open `sabnzbd.hmsrvr.lan` (or `localhost:10106`).

1. **Complete the setup wizard** — this runs on first launch and generates your API key. Note it down, you will need it for Sonarr and Radarr.
2. **Add your Usenet provider** — go to Config > Servers and add your provider's details:
   - Host, port, SSL toggle
   - Username and password
   - Connection count (check your provider's limit)
3. **Set download directories** — go to Config > Folders:
   - Temporary Download Folder: `/data/usenet/incomplete`
   - Completed Download Folder: `/data/usenet/complete`
4. **Create download categories** — go to Config > Categories and add:
   - Category `movies` — Folder/Path: `/data/usenet/complete/movies`
   - Category `tv` — Folder/Path: `/data/usenet/complete/tv`

These categories are what Sonarr and Radarr will use to sort downloads into the right directories.

### Step 2 — Sonarr (TV Series)

Open `sonarr.hmsrvr.lan` (or `localhost:10102`).

1. **Get the API key** — go to Settings > General and copy the API key. You will need it for Prowlarr and Bazarr.
2. **Add root folder** — go to Settings > Media Management > Root Folders and add:
   - `/data/media/tv`
3. **Add SABnzbd as download client** — go to Settings > Download Clients > Add > SABnzbd:
   - Host: `sabnzbd`
   - Port: `8080`
   - API Key: paste the SABnzbd API key from Step 1
   - Category: `tv`
4. **Configure quality profiles** — go to Settings > Profiles and adjust quality preferences (e.g., prefer 1080p or 2160p, language preferences).

### Step 3 — Radarr (Movies)

Open `radarr.hmsrvr.lan` (or `localhost:10103`).

Configuration mirrors Sonarr with movie-specific values:

1. **Get the API key** — Settings > General.
2. **Add root folder** — Settings > Media Management > Root Folders:
   - `/data/media/movies`
3. **Add SABnzbd as download client** — Settings > Download Clients > Add > SABnzbd:
   - Host: `sabnzbd`
   - Port: `8080`
   - API Key: paste the SABnzbd API key from Step 1
   - Category: `movies`
4. **Configure quality profiles** as desired.

### Step 4 — Prowlarr (Indexer Manager)

Open `prowlarr.hmsrvr.lan` (or `localhost:10101`).

Prowlarr manages your Usenet indexers in one place and syncs them to Sonarr and Radarr automatically.

1. **Get the API key** — Settings > General.
2. **Add Usenet indexers** — go to Indexers > Add and configure your indexer(s) (e.g., NZBgeek, DrunkenSlug, NZBFinder). Each indexer will need its own API key from that provider.
3. **Connect Sonarr** — go to Settings > Apps > Add > Sonarr:
   - Prowlarr Server: `http://prowlarr:9696`
   - Sonarr Server: `http://sonarr:8989`
   - API Key: paste the Sonarr API key from Step 2
   - Sync Level: Full Sync
4. **Connect Radarr** — Settings > Apps > Add > Radarr:
   - Prowlarr Server: `http://prowlarr:9696`
   - Radarr Server: `http://radarr:7878`
   - API Key: paste the Radarr API key from Step 3
   - Sync Level: Full Sync

With Full Sync, any indexer you add to Prowlarr will automatically appear in both Sonarr and Radarr.

### Step 5 — Bazarr (Subtitles)

Open `bazarr.hmsrvr.lan` (or `localhost:10104`).

1. **Connect to Sonarr** — go to Settings > Sonarr:
   - Host: `sonarr`
   - Port: `8989`
   - API Key: paste the Sonarr API key
2. **Connect to Radarr** — go to Settings > Radarr:
   - Host: `radarr`
   - Port: `7878`
   - API Key: paste the Radarr API key
3. **Add subtitle providers** — go to Settings > Providers and enable providers like OpenSubtitles.com (requires a free account).
4. **Configure languages** — go to Settings > Languages and set your preferred subtitle languages.

### Step 6 — Jellyfin (Media Player)

Open `jellyfin.hmsrvr.lan` (or `localhost:10108`).

1. **Complete the setup wizard** — create an admin account on first launch.
2. **Add media libraries**:
   - Movies — content type "Movies", folder `/media/movies`
   - TV Shows — content type "Shows", folder `/media/tv`
3. **Enable hardware transcoding** — go to Dashboard > Playback > Transcoding:
   - Hardware acceleration: Intel QuickSync (QSV)
   - The Intel i5-12400 iGPU is passed through via `/dev/dri`

Note: inside the Jellyfin container, the media path is `/media` (not `/data/media`), because the volume is mounted as `/data/media:/media`.

### Step 7 — Jellyseerr (Request Management)

Open `jellyseerr.hmsrvr.lan` (or `localhost:10107`).

Jellyseerr lets users browse and request movies/shows, which then get sent to Radarr/Sonarr automatically.

1. **Sign in** — use your Jellyfin admin credentials.
2. **Connect Jellyfin** — server URL: `http://jellyfin:8096`, then sync your libraries.
3. **Connect Sonarr** — add as a service:
   - Host: `sonarr`
   - Port: `8989`
   - API Key: paste the Sonarr API key
   - Select the root folder and quality profile
4. **Connect Radarr** — same as above with Radarr's details.
5. **Configure user access** — set up which users can request content and any approval requirements.

## Alternative: Using Torrents Instead of Usenet

The stack is built around Usenet (SABnzbd), but can be adapted to use torrenting instead, or both simultaneously.

### Adding qBittorrent

Add the following service to `docker-compose.yml`:

```yaml
  # Torrent download client
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    environment:
      - PUID=1000
      - PGID=100
      - TZ=Europe/Vienna
      - WEBUI_PORT=8080
    volumes:
      - /data/docker/qbittorrent:/config
      - /data:/data
    ports:
      - 10110:8080
      - 6881:6881
      - 6881:6881/udp
    restart: unless-stopped
```

Create the config directory:

```bash
mkdir -p /data/docker/qbittorrent
chown 1000:100 /data/docker/qbittorrent
```

### Configuring qBittorrent

1. Open `localhost:10110` (default login is `admin` / check container logs for the temporary password).
2. Go to Settings > Downloads:
   - Default Save Path: `/data/torrents/complete`
   - Keep incomplete torrents in: `/data/torrents/incomplete`
3. Add categories (right-click in the sidebar > "New Category"):
   - `movies` — Save path: `/data/torrents/complete/movies`
   - `tv` — Save path: `/data/torrents/complete/tv`

### Connecting to Sonarr and Radarr

In both Sonarr and Radarr, go to Settings > Download Clients > Add > qBittorrent:

- Host: `qbittorrent`
- Port: `8080`
- Username: `admin`
- Password: your qBittorrent password
- Category: `tv` (for Sonarr) or `movies` (for Radarr)

### Indexers for Torrents

Prowlarr supports both Usenet and torrent indexers. Simply add torrent indexers (e.g., 1337x, RARBG, TorrentGalaxy) alongside your Usenet ones — they will automatically sync to Sonarr and Radarr through the existing app connections.

### Running Both

SABnzbd and qBittorrent can run side by side. Sonarr and Radarr support multiple download clients and will use whichever one matches the indexer type (Usenet vs torrent) that found the release.
