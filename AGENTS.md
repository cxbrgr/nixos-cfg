# AGENTS.md

This file serves as the **Single Source of Truth (SSOT)** for AI coding agents (including **Antigravity**, **Claude Code**, **OpenAI / ChatGPT / Aider**, and **Cursor**) working in this repository.

---

## 1. Project Overview & Architecture

This is a flake-based **NixOS configuration** managing multiple hosts with integrated **Home Manager** and custom Hyprland/desktop modules.

### Hosts
| Host | Role / Characteristics |
|------|------------------------|
| `wrkstn` | Workstation — AMD/NVIDIA, Hyprland + GNOME, Docker, Steam |
| `hmsrvr` | Home server — Headless, ZFS storage pool, media stack |
| `nb-pavilion` | Laptop — Intel/NVIDIA hybrid, GNOME, multi-user (`chrisleebear` + `mehri`) |

### Key Repository Layout
- `flake.nix` — Flake entry point defining all host outputs, user maps, and inputs.
- `hosts/<hostname>/` — System configuration (`configuration.nix`), user environment (`home.nix`), and hardware specs (`hardware-configuration.nix`).
- `modules/` — Reusable NixOS and Home Manager custom modules (e.g. `options.custom.<name>`).
- `docker/` — Container compositions (media stack, AdGuard, Ollama, reverse proxies).
- `sources/` — Git submodules (e.g. Hyprland configuration forks).
- `justfile` — Command runner for building, testing, updating, and switching configurations.

---

## 2. Multi-Agent Setup & Strategy

To support multiple AI agents (**Antigravity**, **Claude Code**, **OpenAI / ChatGPT**, etc.) simultaneously without duplication:

1. **`AGENTS.md` as Core Standard**: All general guidelines, architecture summaries, build commands, and code rules reside here.
2. **Tool-Specific Compatibility Pointer**:
   - **Claude Code**: Uses `CLAUDE.md` containing `@AGENTS.md` to automatically import this specification into Claude's context.
   - **Antigravity**: Automatically reads `AGENTS.md` at repository root.
3. **Agent Capability Matrix**:

| Feature / Tool | Antigravity | Claude Code | OpenAI / General LLMs |
|----------------|-------------|-------------|-----------------------|
| Primary Rule File | `AGENTS.md` | `CLAUDE.md` (`@AGENTS.md`) | `AGENTS.md` |
| Planning Mode | Native Artifacts (`implementation_plan.md`, `task.md`) | Plan mode | System prompt / Chat plan |
| Subagents | Native (`invoke_subagent`, `research`, `self`) | Task subagents | Multi-agent workflows |
| Execution Sandbox | Linux Bash tool with user approval | Bash tool | Terminal execution |

---

## 3. Important First Steps for Antigravity

When Antigravity initiates a session on this codebase, follow these steps:

1. **Read Project Context**:
   - Inspect `flake.nix` and `hosts/` to understand the affected host before modifying any Nix code.
2. **Safety & Verification First**:
   - **Never run `just switch` without a dry run or user confirmation.**
   - Use `just switch-dry` or `just build` to validate flake syntax and derivation evaluation.
   - Format modified `.nix` files using `nixfmt-rfc-style`.
3. **Task & Planning Workflow**:
   - For multi-step or complex structural changes (e.g., adding a host, refactoring a module, updating flake inputs), use **Planning Mode**:
     - Create `implementation_plan.md` detailing affected files, risk factors, and verification steps.
     - Create `task.md` to track progress step-by-step.
   - Use subagents (`research` subagent) for deep codebase searches or evaluating external Nix flakes without cluttering the primary context.
4. **Empirical Verification**:
   - After code changes, verify using `nix build` or `just build`.
   - Check journal logs (`journalctl -u <service>`) or Hyprland state (`hyprctl`) when inspecting runtime issues.

---

## 4. Key Build & Maintenance Commands

| Action | Command | Purpose |
|--------|---------|---------|
| Dry Run Build | `just switch-dry` | Test flake evaluation without applying changes |
| Apply Config | `just switch` | Build and switch active system configuration (`nh os switch`) |
| Offline Switch | `just reload` | Switch config without updating flake inputs |
| Switch + Hyprland UI | `just switch-ii` | Apply config and reload Illogical Impulse Hyprland UI |
| Build Derivation | `just build` | Build system closure without activating |
| Flake Update | `just update` | Update `flake.lock` and rebuild with diff |
| Remote Deploy | `nixos-rebuild switch --target-host user@x.x.x.x --use-remote-sudo --flake .#<host>` | Deploy config to remote host |

---

## 5. Code Conventions & Standards

### Nix Module Structure
```nix
{ pkgs, lib, config, ... }:
{
  # Module configuration
}
```

### Custom Options Pattern
```nix
options.custom.<featureName> = {
  enable = lib.mkEnableOption "Enable <featureName> module";
};

config = lib.mkIf config.custom.<featureName>.enable {
  # Implementation
};
```

### Directives & Safety Rules
- **State Version**: Do NOT change `system.stateVersion` or `home.stateVersion` (currently `"25.11"`).
- **Hostnames**: `networking.hostName` must exactly match the attribute name in `flake.nix`.
- **Formatting**: Always format Nix files with `nixfmt-rfc-style`.
- **Hardware Config**: Do not edit `hosts/<hostname>/hardware-configuration.nix` manually unless adjusting filesystem options.
