# NixOS Updating & Rebuilding

## Cheat Sheet

### Rebuild & Apply

| Command | What it does |
|---------|-------------|
| `just switch` | Rebuild and activate from current `flake.lock` (no version changes) |
| `just reload` | Same as `switch` but offline (uses local store only) |
| `just switch-ii` | Switch + reload Illogical Impulse UI / Hyprland |
| `just switch-dry` | Dry run — show what would change without applying |
| `just build` | Build the configuration without activating it |

### Update Inputs

| Command | What it does |
|---------|-------------|
| `just update` | Update all flake inputs, rebuild, and show diff |
| `just update-input nixpkgs` | Update a single flake input (e.g. `nixpkgs`) |
| `just flake-lock-status` | Show pinned revisions and their age |

### Maintenance

| Command | What it does |
|---------|-------------|
| `just gc` | Delete old generations and run garbage collection |
| `just generations` | List all system generations |
| `just rollback` | Roll back to the previous system generation |

### Raw Nix (for edge cases)

```bash
# Rebuild a specific host without nh
sudo nixos-rebuild switch --flake .#wrkstn

# Update only flake.lock without rebuilding
nix flake update

# Show what a specific input is pinned to
nix flake metadata --json | jq '.locks.nodes.nixpkgs.locked.rev'

# Remote deployment
nixos-rebuild switch --target-host user@10.10.10.x --use-remote-sudo --flake .#hostname
```

---

## How Updating Works

### flake.lock Is the Source of Truth

Every nix package in this configuration is pinned to an exact git revision via `flake.lock`. When you run `just switch`, nix reads the lock file, resolves every package to a specific store path, and builds the system. **No network requests are made to check for newer versions** — the lock file is the single source of truth.

This means:
- `just switch` is **idempotent** — running it twice produces the same system
- `just switch` on two different machines with the same `flake.lock` produces the same system
- Package versions only change when `flake.lock` changes

### switch vs update

| | `just switch` | `just update` |
|-|--------------|---------------|
| Updates `flake.lock`? | No | Yes |
| Changes package versions? | No | Yes (if upstream has new commits) |
| Requires network? | Only to fetch missing store paths | Yes, to query upstream repos |
| Safe to run anytime? | Yes | Mostly — review the diff it shows |

`just update` runs `nh os test . --update`, which first calls `nix flake update` (rewrites `flake.lock` to latest revisions), then rebuilds and shows a diff of what changed.

### What Is Deterministic

**Fully deterministic (pinned by flake.lock):**
- All packages from `nixpkgs` — everything declared in `packages-common.nix`, `packages-wrkstn.nix`, `packages-hmsrvr.nix`, `packages-nb-pavilion.nix`
- System services and configuration (boot, networking, drivers, systemd units)
- Home Manager dotfiles and program configuration
- All flake inputs that use `follows = "nixpkgs"` (`home-manager`, `illogical-flake`) — these are locked to the same nixpkgs revision

The same `flake.lock` will always produce the same `/nix/store` paths. This is the core guarantee of nix.

**Not deterministic (external to nix):**

| Source | Why | How it updates |
|--------|-----|----------------|
| **Flatpak packages** | Fetched from Flathub at install time, not pinned to a nix store path | Auto-updates monthly via systemd timer; versions depend on what Flathub serves |
| **Docker containers** | Images pulled from registries based on tags (e.g. `latest`), not content-addressed | `docker compose pull` or on `up` if image is missing |
| **AppImages / nix-ld binaries** | Run via `nix-ld` dynamic linker shim, not in the nix store | Manually managed by the user |
| **Git submodules** (`sources/`) | Local checkout, not tracked by `flake.lock` for content | `git submodule update --remote` to pull upstream changes |
| **Application state** | Databases, caches, browser profiles, etc. in `$HOME` | Not managed by nix |

### The nixos-unstable Channel

This configuration tracks `nixos-unstable`:

```nix
nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
```

This is a rolling branch — there are no versioned releases. Packages land here after passing Hydra CI, but there's no manual curation like the stable channel. Running `just update` pulls the latest commit from this branch.

If you need to pin to a specific known-good revision after a broken update:

```bash
nix flake update nixpkgs --override-input nixpkgs github:nixos/nixpkgs/<commit-sha>
just switch
```

### Flake Input Relationships

```
nixpkgs (nixos-unstable)
  |
  |-- follows --> home-manager     (always same nixpkgs)
  |-- follows --> illogical-flake  (always same nixpkgs)
  |
nix-flatpak                        (independent nixpkgs, but only provides a module)
dotfiles-fork                      (local git submodule, not a flake)
```

Because `home-manager` and `illogical-flake` use `follows = "nixpkgs"`, they are guaranteed to evaluate against the same package set. There can never be a version mismatch between system packages and home-manager packages.

`dotfiles-fork` is a local submodule. To update it:

```bash
cd sources/chr-ber-dots-hyprland
git pull origin main
cd ../..
just switch
```

### Generations and Rollback

Every `just switch` creates a new **system generation** — a complete snapshot of the system configuration. Previous generations are preserved and selectable from the bootloader.

Automatic cleanup is configured in `modules/nix-gc.nix`:
- Runs weekly
- Deletes generations older than 90 days

To manually manage generations:

```bash
just generations              # List all generations
just rollback                 # Activate the previous generation
sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5  # Keep only last 5
just gc                       # Clean up unreferenced store paths
```

You can also select any previous generation from the GRUB/systemd-boot menu at boot time — useful if a bad update makes the system unbootable.
