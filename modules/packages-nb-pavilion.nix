{ 
  pkgs,
  lib,
  ... 
}:
{
  home.packages = with pkgs; [
    # ==========================================
    # Desktop Apps - nb-pavilion (Business/Study)
    # ==========================================

    # -- Browsers --
    google-chrome     # Google's proprietary browser
    brave             # Privacy-focused Chromium fork with built-in ad blocking
    vivaldi           # Power-user browser with vertical tabs, split-screen, gestures

    # -- Development (GUI) --
    vscode            # Source code editor by Microsoft
    antigravity       # Google AGI coding agent

    # -- Media / Office / Social --
    obsidian          # Knowledge base on local Markdown files

    # -- Audio --
    spotify           # Music streaming service

    # -- Desktop Utilities --
    polkit_gnome      # PolicyKit authentication agent (GUI password prompts)
    polkit            # Toolkit for controlling system-wide privileges
    seahorse          # GNOME keyring manager for encryption keys and passwords
    gnome-decoder     # QR code decoder
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
    ];
    
    remotes = lib.mkOptionDefault [{
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }];
  };
}
