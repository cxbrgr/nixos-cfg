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

list-partitions:
    lsblk -o NAME,PATH,SIZE,TYPE,FSTYPE,LABEL,MOUNTPOINT,MODEL

list-disks:
    sudo fdisk -l

network:
    nmtui        