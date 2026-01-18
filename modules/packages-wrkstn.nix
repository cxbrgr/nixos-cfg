{ 
  pkgs,
  lib,
  ... 
}:
{
  home.packages = with pkgs; [
    # ==========================================
    # Desktop Apps - Workstation Only
    # ==========================================

    # -- Browsers --
    google-chrome     # Google's proprietary browser
    brave             # Privacy-focused Chromium fork with built-in ad blocking
    nyxt              # Infinitely extensible browser via Common Lisp (Emacs of browsers)
    vivaldi           # Power-user browser with vertical tabs, split-screen, gestures
    qutebrowser       # Keyboard-driven browser with Vim-like bindings

    # -- Development (GUI) --
    vscode            # Source code editor by Microsoft
    jetbrains.rider   # Cross-platform .NET IDE
    remmina           # Remote desktop client (RDP, VNC, SSH)
    antigravity       # Google AGI coding agent
    opencode          # Open source AGI coding agent
    claude-code       # Anthropic AGI coding agent

    # -- Media / Office / Social --
    discord           # Voice and text chat for communities
    obsidian          # Knowledge base on local Markdown files

    # -- Audio --
    spotify           # Music streaming service
    alsa-scarlett-gui # GUI for Focusrite Scarlett audio interfaces
    playerctl         # Command-line tool for controlling media players
    bitwig-studio     # Digital audio workstation (DAW)
    reaper            # Lightweight DAW, good for mastering
    qpwgraph          # Visual patchbay for PipeWire audio routing

    # -- Desktop Utilities --
    polkit_gnome      # PolicyKit authentication agent (GUI password prompts)
    polkit            # Toolkit for controlling system-wide privileges
    seahorse          # GNOME keyring manager for encryption keys and passwords
    gnome-decoder     # QR code decoder
    # scrcpy wrapped to work properly on Hyprland (forces X11 + OpenGL)
    (pkgs.writeShellScriptBin "scrcpy" ''
      export SDL_VIDEODRIVER=x11
      exec ${pkgs.scrcpy}/bin/scrcpy --render-driver=opengl "$@"
    '')
  ];

  services.flatpak = {
    enable = true;
    # unmanaged and managed can coexist
    uninstallUnmanaged = false; 
    # cleanup unused flatpaks
    uninstallUnused = false;

    # do not update on app startup
    update.onActivation = false;
    # regularly auto update flatpaks
    update.auto = {
      enable = true;
      onCalendar = "monthly";
    };

    packages = [
      "io.github.kolunmi.Bazaar"                    # package manager
      "com.github.IsmaelMartinez.teams_for_linux"   # wrk chat
      "org.signal.Signal"                           # instant messanger
      # run for data access outside of flat container: 
      # flatpak override --user --filesystem=/home/chrisleebear/data/songs eu.usdx.UltraStarDeluxe
      "eu.usdx.UltraStarDeluxe"                     # karoake
    ];
    
    remotes = lib.mkOptionDefault [{
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }];
  };
}