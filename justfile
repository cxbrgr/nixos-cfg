default: switch

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

# Media Stack Management
media-up:
    docker compose -f docker/media-srvr/docker-compose.yaml up -d

media-down:
    docker compose -f docker/media-srvr/docker-compose.yaml down

media-logs:
    docker compose -f docker/media-srvr/docker-compose.yaml logs -f

media-init:
    sudo bash docker/media-srvr/init-media-dirs.sh

media-configure:
    nix-shell -p python3 python3Packages.requests --run "python3 docker/media-srvr/configure-media-stack.py"
