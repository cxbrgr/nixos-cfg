{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # ==========================================
    # Personal Apps
    # ==========================================

    # -- Browsers & their Friends --
    google-chrome
    adguardhome     # Network-wide Ad Blocker

    # -- Development --
    vscode            # Code Editor
    jetbrains.rider   # IDE
    remmina           # Remote Desktop Client
    antigravity       # Agent AGI (Google)

    # -- Media / Office / Social --
    spotify           # Music Streaming Service
    discord           # Voice and Text Chat
    obsidian          # Knowledge Base and Note Taking

    # -- System Tools --
    zip               # Compression Utility
    unzip             # Decompression Utility
    ripgrep           # Fast Grep Alternative for Searching
    fzf               # Command Line Fuzzy Finder
    htop              # Interactive Process Viewer
    btop              # Modern Resource Monitor
    polkit_gnome      # Authentication Agent (Pop-ups for sudo)
    polkit            # Authentication Agent
    seahorse          # GNOME Keyring Manager (Password GUI)

    # ==========================================
    # ML4W Dotfiles Dependencies
    # https://mylinuxforwork.github.io/dotfiles/getting-started/overview
    # ==========================================

    # -- Desktop Environment --
    waybar                 # Status Bar for Wayland
    rofi                   # Application Launcher and Menu
    wlogout                # Wayland Logout Menu
    swaynotificationcenter # Notification Daemon
    libnotify              # Library to send notifications
    hyprpaper              # Wallpaper Utility
    hyprlock               # Screen Locker
    hypridle               # Idle Management Daemon
    
    # -- File Management (ML4W Standard) --
    xfce.thunar            # File Manager
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    file-roller            # Archive Manager (GUI for zip/unzip)

    # -- Theming & Look --
    nwg-look               # GTK3 Settings Editor for Wayland
    nwg-dock-hyprland      # GTK-based Dock for Hyprland
    waypaper               # GUI Wallpaper Setter
    swww                   # Animated Wallpaper Daemon
    mpv                    # Video Player (used for video wallpapers)
    catppuccin-gtk         # GTK Theme
    papirus-icon-theme     # Icon Theme
    bibata-cursors         # Cursor Theme
    hyprpolkitagent        # Polkit Agent for Hyprland
    pywal                  # Pywal (Color palette generator)
    
    # -- Qt Theming (Qt5 & Qt6) --
    libsForQt5.qt5ct       # Qt5 Settings
    kdePackages.qt6ct      # Qt6 Settings (New Standard)
    libsForQt5.qtstyleplugin-kvantum # SVG-based Theme Engine for Qt

    # -- Terminal & Shell --
    kitty                  # GPU-accelerated Terminal Emulator
    alacritty              # Lightweight Terminal Backup
    fastfetch              # System Information Fetcher
    eza                    # Modern Replacement for 'ls'
    zsh                    # Z Shell
    oh-my-posh             # Prompt Theme Engine

    # -- Utilities --
    networkmanagerapplet   # Network Manager Tray Icon
    pavucontrol            # PulseAudio Volume Control GUI
    blueman                # Bluetooth Manager
    cliphist               # Clipboard History Manager
    wl-clipboard           # Wayland Clipboard Utilities
    brightnessctl          # Screen Brightness Control
    playerctl              # Command-line Media Player Controller
    bc                     # Calculator (Required for many ML4W scripts)
    socat                  # Socket utility (Required for Waybar IPC)

    # -- Screenshotting --
    grim                   # Grab Images from Wayland Compositor
    slurp                  # Select Region for Screenshots
    swappy                 # Wayland Screenshot Editor

    # -- Script Dependencies --
    gcc                    # GNU Compiler Collection
    jq                     # Command-line JSON Processor
    imagemagick            # Image Manipulation Tool
    
    # -- Python Environment --
    # Required for ML4W python scripts
    (python3.withPackages (ps: with ps; [ 
      screeninfo 
      pygobject3 
      pycairo 
      requests
    ]))

    # -- Fonts --
    font-awesome          # Icon Font
    fira-code             # Monospace Font with Ligatures
    fira-code-symbols     # Symbols for Fira Code
    noto-fonts            # Google Noto Fonts
    noto-fonts-color-emoji      # Emoji Support
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  # Enable Fontconfig to discover the installed fonts
  fonts.fontconfig.enable = true;
}