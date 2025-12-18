{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # ==========================================
    # Personal Apps
    # ==========================================

    # -- Browsers --
    google-chrome

    # -- Development --
    vscode            # Code Editor
    jetbrains.rider   # IDE
    remmina           # Remote Desktop Client

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
    polkit            # Authentication Agent (Pop-ups for sudo)
    seahorse          # GNOME Keyring Manager (Password GUI)

    # ==========================================
    # ML4W Dotfiles Dependencies
    # https://mylinuxforwork.github.io/dotfiles/getting-started/overview
    # https://github.com/mylinuxforwork/dotfiles/blob/1164-nix/setup/nix/flake.nix
    # ==========================================

    # -- Desktop Environment --
    waybar                 # Status Bar for Wayland
    rofi           # Application Launcher and Menu
    wlogout                # Wayland Logout Menu
    swaynotificationcenter # Notification Daemon
    libnotify              # Library to send notifications
    hyprpaper              # Wallpaper Utility
    hyprlock               # Screen Locker
    hypridle               # Idle Management Daemon

    # -- Theming & Look --
    nwg-look               # GTK3 Settings Editor for Wayland
    nwg-dock-hyprland      # GTK-based Dock for Hyprland
    waypaper               # GUI Wallpaper Setter
    swww                   # Animated Wallpaper Daemon
    mpv                    # Video Player (used for video wallpapers)
    catppuccin-gtk         # GTK Theme
    papirus-icon-theme     # Icon Theme
    bibata-cursors         # Cursor Theme

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