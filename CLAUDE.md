# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

Apply configuration changes:
```bash
just switch          # Apply configuration (uses nh os switch)
just reload          # Apply offline (no flake update)
just switch-ii       # Switch + reload Illogical ImpulseUI (Hyprland)
just switch-dry      # Dry run build
just build           # Build only, don't switch
just update          # Update flake inputs + rebuild with diff
```

Remote deployment:
```bash
nixos-rebuild switch --target-host user@10.10.10.x --use-remote-sudo --flake .#hostname
```

## Architecture

This is a flake-based NixOS configuration managing 3 hosts with integrated Home Manager.

### Hosts

| Host | Description |
|------|-------------|
| `wrkstn` | Workstation - AMD/NVIDIA, Hyprland + GNOME, Docker, Steam |
| `hmsrvr` | Home server - headless, ZFS, media stack |
| `nb-pavilion` | Laptop - Intel/NVIDIA hybrid, GNOME, multi-user (chrisleebear + mehri) |

### Structure

- `flake.nix` - Entry point defining all host configurations and inputs
- `hosts/<hostname>/configuration.nix` - System config (boot, hardware, services)
- `hosts/<hostname>/home.nix` - User environment (packages, dotfiles, shell)
- `hosts/<hostname>/hardware-configuration.nix` - Auto-generated, do not edit
- `modules/` - Reusable NixOS and Home Manager modules
- `docker/` - Docker compose files for services (media stack, AdGuard, Ollama, proxy)
- `sources/` - Git submodules (Hyprland dotfiles, illogical-flake fork)

### Key Flake Inputs

- `nixpkgs` - nixos-unstable channel
- `home-manager` - User environment management
- `illogical-flake` - Hyprland UI framework (from soymou/illogical-flake)
- `dotfiles-fork` - Local submodule with Hyprland configs
- `nix-flatpak` - Declarative Flatpak support

### User Configuration

Primary user defined in `flake.nix`:
```nix
usr = { name = "chrisleebear"; fullName = "Chris"; };
```

Multi-user (nb-pavilion) uses `usermap` for additional users with different locales.

## Code Conventions

### Module Structure
```nix
{ pkgs, lib, config, ... }:
{
  # Configuration here
}
```

### Custom Options Pattern
Modules with conditional features use:
```nix
options.custom.<name> = {
  enable = lib.mkEnableOption "Description";
};
config = lib.mkIf config.custom.<name>.enable {
  # Configuration
};
```

### Package Lists
```nix
home.packages = with pkgs; [
  package1
  package2
];
```

### Formatting
- Use `nixfmt-rfc-style` (configured as flake formatter)
- Section headers use `# ==========================================`

## Common Pitfalls

- Hostname in flake outputs must match `networking.hostName` in host config
- Home Manager changes require full system rebuild (integrated mode)
- After WM changes, reload Hyprland with `hyprctl reload`
- `system.stateVersion` and `home.stateVersion` set to "25.11" - don't change without migration
