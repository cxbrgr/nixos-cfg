default: switch

# NixOS Management
reload:
    nh os switch . --offline

switch:
    nh os switch .

switch-ii:
    qs -c $qsConfig kill 2>/dev/null || true
    nh os switch .
    (qs -c $qsConfig >/dev/null 2>&1 &)
    hyprctl reload && hyprctl reload

reload-ii:
    qs -c $qsConfig kill 2>/dev/null || true
    (qs -c $qsConfig >/dev/null 2>&1 &)
    hyprctl reload && hyprctl reload

switch-dry:
    nh os switch --dry .

build:
    nh os build .

update:
    nh os test . --update --diff always

update-input INPUT:
    nix flake update {{INPUT}}

flake-lock-status:
    nix flake metadata

generations:
    sudo nix-env --list-generations -p /nix/var/nix/profiles/system

rollback:
    sudo nixos-rebuild switch --rollback

gc:
    sudo nix-collect-garbage -d && nix-collect-garbage -d

update-sources:
    git submodule update --init --recursive --remote

# Docker
docker-image-prune:
    docker image prune -f

# Media Stack Management
media-up:
    docker compose -f docker/media-srvr/docker-compose.yml up -d

media-down:
    docker compose -f docker/media-srvr/docker-compose.yml down

media-logs:
    docker compose -f docker/media-srvr/docker-compose.yml logs -f

media-init:
    sudo bash docker/media-srvr/init-media-dirs.sh

media-configure:
    nix-shell -p python3 python3Packages.requests --run "python3 docker/media-srvr/configure-media-stack.py"

# AdGuard Home Management
adguard-up:
    docker compose -f docker/adguard-home/docker-compose.yml up -d

adguard-down:
    docker compose -f docker/adguard-home/docker-compose.yml down

adguard-logs:
    docker compose -f docker/adguard-home/docker-compose.yml logs -f

# Ollama WebUI Management
ollama-webui-up:
    docker compose -f docker/ollama-webui/docker-compose.yml up -d

ollama-webui-down:
    docker compose -f docker/ollama-webui/docker-compose.yml down

ollama-webui-logs:
    docker compose -f docker/ollama-webui/docker-compose.yml logs -f

# Home Assistant Management
home-assistant-up:
    docker compose -f docker/home-assistant/docker-compose.yml up -d

home-assistant-down:
    docker compose -f docker/home-assistant/docker-compose.yml down

home-assistant-restart:
    docker compose -f docker/home-assistant/docker-compose.yml restart

home-assistant-logs:
    docker compose -f docker/home-assistant/docker-compose.yml logs -f

# Proxy Stack Management
proxy-up:
    docker compose -f docker/proxy/docker-compose.yml up -d

proxy-down:
    docker compose -f docker/proxy/docker-compose.yml down

proxy-logs:
    docker compose -f docker/proxy/docker-compose.yml logs -f

proxy-reload:
    docker exec proxy-nginx nginx -s reload

# System Management
list-partitions:
    lsblk -o NAME,PATH,SIZE,TYPE,FSTYPE,LABEL,MOUNTPOINT,MODEL

list-disks:
    sudo fdisk -l

network:
    nmtui
