{ pkgs, lib, ... }:
{
    home.packages = with pkgs; [
      # ==========================================
      # Personal Apps - Common
      # ==========================================

      # -- Browsers & their Friends --
      google-chrome
      brave

      # -- Development --
      vscode            # Source code editor developed by Microsoft
      jetbrains.rider   # Cross-Platform .NET IDE
      remmina           # Remote Desktop Client
      antigravity       # Google AGI agent
      opencode          # Open source AGI agent
      claude-code       # Anthropic AGI agent
      lazygit           # Git client
      
      # -- System Tools --
      zip               # Compressor/archiver for creating and modifying zipfiles
      unzip             # Decompressor for zip files
      ripgrep           # Line-oriented search tool that recursively searches the current directory
      fzf               # General-purpose command-line fuzzy finder
      htop              # Interactive process viewer
      btop              # A monitor of resources
      psmisc            # Utilities for process management (killall, etc.)
      jq                # Lightweight and flexible command-line JSON processor
      polkit_gnome      # PolicyKit authentication agent
      polkit            # Toolkit for controlling system-wide privileges
      seahorse          # Application for managing encryption keys and passwords in the GNOME Keyring
      zsh               # Z shell
      direnv            # Directory-based environment variable management
      pciutils          # Utilities for PCI devices
      fzf               # General-purpose command-line fuzzy finder
      eza               # ls replacement, gives you directory listings with more information, color, and icons
      fd                # Simple, fast and user-friendly alternative to find
      zoxide            # Replacement for cd, for fast directory navigation
      gh                # GitHub CLI
      lnav              # Log file viewer
    ];
}