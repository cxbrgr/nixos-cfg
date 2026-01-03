# NixOS Configuration - AI Agent Instructions

## Architecture Overview
This is a NixOS flake-based system configuration managing multiple hosts (wrkstn, hmsrvr) with integrated Home Manager. The structure separates system-level configurations (boot, hardware, services) from user-level (packages, dotfiles, shell).

Key components:
- `flake.nix`: Defines nixosConfigurations for each host, importing their respective `hosts/*/configuration.nix`
- `hosts/*/configuration.nix`: System config (bootloader, hardware, services, networking)
- `hosts/*/home.nix`: User config (packages, session variables, file symlinks) - imports modular home modules
- `modules/`: Reusable Nix modules (packages-common.nix for shared home packages, packages-{host}.nix for host-specific, git.nix, zsh.nix, etc.)
- `nixos/`: Legacy or alternative config structure (similar to hosts/wrkstn/)

## Critical Workflows
- **Apply system changes**: `sudo nixos-rebuild switch --flake .#wrkstn` (replace wrkstn with actual hostname)
- **Test changes without switching**: `sudo nixos-rebuild test --flake .#wrkstn`
- **Dry run build**: `sudo nixos-rebuild dry-build --flake .#wrkstn`
- **Check flake validity**: `nix flake check`
- **Update flake inputs**: `nix flake update`
- **Evaluate home packages**: `nix eval --json .#homeConfigurations.wrkstn.config.home.packages --apply 'pkgs: map (p: p.name) pkgs' | nix run nixpkgs#jq -- -r '.[]' | sort`

Shell aliases in `modules/zsh.nix` provide shortcuts like `flake-rebuild`, `flake-drybuild`, `flake-list-home-pkgs` (lists home packages with proper formatting).

## Project Conventions
- **Package lists**: Use `with pkgs; [ pkg1 pkg2 ]` syntax for readability
- **Module structure**: Each module is a function `{ pkgs, lib, ... }: { ... }` returning an attrset
- **Comments**: Use `#` for inline comments, descriptive headers with `==========================================`
- **Hardware configs**: Auto-generated `hardware-configuration.nix` files - do not edit manually
- **State versions**: Set `system.stateVersion` and `home.stateVersion` to current NixOS version (e.g., "25.11")

## Integration Patterns
- **Home Manager integration**: Imported via `inputs.home-manager.nixosModules.default` in system configs
- **Unfree packages**: Enable with `nixpkgs.config.allowUnfree = true;`
- **Fonts**: Install via `fonts.packages = with pkgs; [ ... ];` in system config
- **Services**: Enable via `services.<name>.enable = true;` with nested options
- **User setup**: Define users in `users.users.<username> = { ... };` with groups like "wheel", "networkmanager"

## Key Files to Reference
- `flake.nix`: Entry point and host definitions
- `hosts/wrkstn/configuration.nix`: Example system config with Nvidia, Hyprland, Steam
- `modules/packages-common.nix`: Shared home package management pattern
- `modules/packages-wrkstn.nix`: Host-specific packages (e.g., media apps)
- `modules/zsh.nix`: Shell configuration with aliases and init scripts
- `scripts/create-nixos-symlinks.bash`: Legacy symlink setup (may be outdated)

## Common Pitfalls
- Hostname in flake outputs must match `networking.hostName` in config
- After system switch, reload Hyprland with `hyprctl reload` if WM changes
- Home Manager changes require system rebuild since it's integrated
- Flake paths use relative `.` or absolute `~/nixos-cfg`