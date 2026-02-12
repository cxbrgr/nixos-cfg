# NixOS System Configuration

> **Important:** This is my personal NixOS configuration repository. It is intended as a reference only and is not designed to be cloned and used directly. Your hardware, preferences, and requirements will differ.

---

## Directory Structure

```text
nixos-cfg/
├── hosts/                     # Per-host configurations
│   ├── hmsrvr/                # Home server (headless)
│   │   ├── configuration.nix  # System: boot, services, networking
│   │   ├── hardware-config... # Auto-generated hardware config
│   │   └── home.nix           # User environment: shell, tools
│   └── wrkstn/                # Workstation (desktop)
│       ├── configuration.nix  # System: drivers, display, audio
│       ├── hardware-config... # Auto-generated hardware config
│       └── home.nix           # User environment: apps, dotfiles
├── modules/                   # Reusable NixOS and Home Manager modules
├── docker/                    # Docker compose files
├── scripts/                   # Utility scripts
├── sources/                   # Git submodules (external dependencies)
├── flake.nix                  # Flake entry point
├── flake.lock                 # Pinned dependency versions
└── justfile                   # Task runner commands
```

---

## Quick Start

Apply configuration changes:

```bash
just switch
```

Apply configuration changes and reload Illogical ImpulseUI:

```bash
just switch-ii
```

Update flake inputs and rebuild:

```bash
just update
```

---

## Bootstrap a New System

### Clone with Submodules

```bash
git clone --recurse-submodules git@github.com:cxbrgr/nixos-cfg.git ~/nixos-cfg
```

Or if already cloned without submodules:

```bash
git submodule update --init --recursive
```

### First Build

```bash
cd ~/nixos-cfg
sudo nixos-rebuild switch --flake .#hostname
```

Replace `hostname` with `wrkstn` or `hmsrvr`.

---

## Architecture Overview

### Flakes (`flake.nix`)

- Single entry point for all configurations
- Pins dependencies via `flake.lock` for reproducible builds
- Defines system configurations for each host

### System Configuration (`hosts/*/configuration.nix`)

Manages system-level concerns (requires root):
- Bootloader and kernel
- Hardware drivers (GPU, audio, networking)
- System services (Docker, SSH, display manager)
- Users and groups

### Home Manager (`hosts/*/home.nix` and `modules/`)

Manages user environment (user-space only):
- Shell configuration (Fish, Starship, Zoxide)
- Applications (browsers, editors, tools)
- Dotfiles and theming

---

## Remote Deployment

Deploy to a remote host:

```bash
nixos-rebuild switch \
    --target-host user@10.10.10.x \
    --use-remote-sudo \
    --flake .#hostname
```

---

## Common Operations

### Dry Build (Test Without Applying)

```bash
nixos-rebuild dry-build --flake .#hostname
```

### Garbage Collection

```bash
sudo nix-collect-garbage -d
```

### Repair via Live ISO

Boot the live ISO, mount partitions to `/mnt`, then:

```bash
nixos-enter
cd /path/to/nixos-cfg
nixos-rebuild switch --flake .#hostname
```

---

## Hosts

| Host          | Description                          |
|---------------|--------------------------------------|
| `wrkstn`      | Workstation with Hyprland desktop    |
| `hmsrvr`      | Home server (headless)        |
| `nb-pavilion` | Notebook with Gnome desktop          |
---

## Key Modules

| Module              | Purpose                              |
|---------------------|--------------------------------------|
| `fish.nix`          | Fish shell with aliases and functions |
| `starship/`         | Prompt theming via TOML configs      |
| `ghostty.nix`       | Terminal emulator configuration      |
| `packages-common.nix` | CLI tools shared across hosts      |
| `packages-wrkstn.nix` | Desktop applications (workstation) |
| `sshfs-mounts.nix`  | Network mounts via SSHFS             |
| `docker.nix`        | Docker and container runtime         |
| `fonts.nix`         | System fonts (Nerd Fonts, etc.)      |
