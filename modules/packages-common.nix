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

    # -- Files & Network --
    bat               # Cat clone with syntax highlighting and git integration
    wget              # Download files from the web
    dig               # DNS lookup tool
    openssl           # Cryptography toolkit (TLS, certs, hashing)
    
    # -- Process & System --
    htop              # Interactive process viewer
    # btop wrapped so it can dlopen libnvidia-ml.so / librocm_smi64.so from
    # NixOS' driver path (/run/opengl-driver/lib); without this, GPU panel
    # stays empty even though btop is built with BTOP_GPU=ON.
    (btop.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
      postInstall = (old.postInstall or "") + ''
        wrapProgram $out/bin/btop \
          --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib
      '';
    }))
    ncdu              # Disk usage analyzer with ncurses interface
    fastfetch         # Fast system info tool (neofetch replacement)
    psmisc            # Utilities for process management (killall, fuser, pstree)
    pciutils          # Utilities for PCI devices (lspci)

    # -- Development CLI --
    gh                # GitHub CLI - manage PRs, issues, repos from terminal
    lazygit           # Simple terminal UI for git commands
    jq                # Lightweight command-line JSON processor
    just              # Command-line task runner (like make but simpler)
    direnv            # Directory-based environment variable management
    nodejs            # JavaScript runtime (includes npm)

    # -- Nix --
    nh                # Nix CLI helper - prettier nixos-rebuild
    nil               # Nix language server
    nixfmt            # Nix formatter

    # -- Logs & Files --
    lnav              # Advanced log file navigator with syntax highlighting
    inotify-tools     # Monitor and act upon filesystem events (inotifywait)
  ];
}