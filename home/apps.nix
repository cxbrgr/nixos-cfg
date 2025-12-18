home.packages = with pkgs; [
    # -- ML4W CORE --
    waybar
    rofi-wayland
    dunst                  # Notifications (He might use SwayNC, but Dunst is standard in his v2)
    swaynotificationcenter # He often switches between these two
    libnotify              # Required for sending notifications
    
    # -- WALLPAPER & LOOK --
    swww                   # Wallpaper Daemon
    waypaper               # GUI for wallpapers (Crucial per the issue)
    nwg-look               # GTK Theme selector
    nwg-dock-hyprland      # The dock he uses
    mpv                    # Video background player
    
    # -- TERMINAL & SHELL --
    kitty
    alacritty              # He supports both, good to have just in case
    zsh
    oh-my-posh
    fastfetch              # System info fetcher
    btop                   # System monitor
    
    # -- UTILITIES --
    networkmanagerapplet   # WiFi tray
    pavucontrol            # Audio tray
    cliphist               # Clipboard history
    wl-clipboard           # Clipboard tools
    grim                   # Screenshot
    slurp                  # Screenshot selection
    swappy                 # Screenshot editor
    wlogout                # Logout menu
    imagemagick            # Image manipulation (used by his scripts)
    python3                # Needed for his python scripts
    jq                     # JSON parser (needed for his scripts)
];