{ 
  pkgs,
  lib,
  ... 
}:
{
  home.packages = with pkgs; [
    # ==========================================
    # CLI Tools - Truly Common (Server + Desktop)
    # ==========================================

    # -- Archives --
    zip               # Compressor/archiver for creating and modifying zipfiles
    unzip             # Decompressor for zip files

    # -- Search & Navigation --
    ripgrep           # Line-oriented search tool (rg) - faster than grep
    fzf               # General-purpose command-line fuzzy finder
    fd                # Simple, fast and user-friendly alternative to find
    eza               # Modern ls replacement with icons and colors

    # -- Process & System --
    htop              # Interactive process viewer
    btop              # Resource monitor with graphs (prettier htop)
    psmisc            # Utilities for process management (killall, fuser, pstree)
    pciutils          # Utilities for PCI devices (lspci)

    # -- Development CLI --
    gh                # GitHub CLI - manage PRs, issues, repos from terminal
    lazygit           # Simple terminal UI for git commands
    jq                # Lightweight command-line JSON processor
    just              # Command-line task runner (like make but simpler)
    direnv            # Directory-based environment variable management

    # -- Nix --
    nh                # Nix CLI helper - prettier nixos-rebuild

    # -- Logs & Files --
    lnav              # Advanced log file navigator with syntax highlighting
    inotify-tools     # Monitor and act upon filesystem events (inotifywait)
  ];
}