{ pkgs, quickshell, ... }:

{
  home.packages = with pkgs; [
    # ==========================================
    # Personal Apps
    # ==========================================

    # -- Browsers & their Friends --
    google-chrome     # Web browser from Google
    adguardhome       # Network-wide software for blocking ads and tracking

    # -- Development --
    vscode            # Source code editor developed by Microsoft
    jetbrains.rider   # Cross-Platform .NET IDE
    remmina           # Remote Desktop Client
    antigravity       # Agent AGI (Google)

    # -- Media / Office / Social --
    spotify           # Proprietary music streaming service
    discord           # All-in-one voice and text chat for gamers
    obsidian          # Knowledge base that operates on local Markdown files

    # -- System Tools --
    zip               # Compressor/archiver for creating and modifying zipfiles
    unzip             # Decompressor for zip files
    ripgrep           # Line-oriented search tool that recursively searches the current directory
    fzf               # General-purpose command-line fuzzy finder
    htop              # Interactive process viewer
    btop              # A monitor of resources
    polkit_gnome      # PolicyKit authentication agent
    polkit            # Toolkit for controlling system-wide privileges
    seahorse          # Application for managing encryption keys and passwords in the GNOME Keyring

    # ==========================================
    # End-4 Dotfiles Dependencies
    # Dependencies required for the 'dots-hyprland' theme (Quickshell version)
    # ==========================================

    # -- Core Components --
    hyprland          # Dynamic tiling Wayland compositor that manages windows
    
    # Imports the Quickshell wrapper defined in quickshell.nix
    # Wraps the Quickshell binary with necessary Qt dependencies and environment variables
    (import ./quickshell.nix { inherit pkgs quickshell; })
    
    # -- Widgets & System Tools --
    fuzzel            # Application launcher usually started with Super key
    hypridle          # Idle management daemon to handle sleep and screen locking
    hyprlock          # Screen locker for Hyprland
    hyprpicker        # Color picker and screen selection tool
    hyprsunset        # Blue light filter and color temperature adjuster
    wlogout           # Logout menu allowing shutdown, reboot, lock, etc.
    
    # -- Theming Engines --
    matugen           # Material You color generation tool that creates palettes from wallpapers
    dart-sass         # Sass compiler used to compile style sheets for widgets
    imagemagick       # Software suite to create, edit, compose, or convert bitmap images
    swww              # Efficient animated wallpaper daemon for Wayland
    kdePackages.qt6ct # Qt6 configuration tool to apply themes to Qt applications
    kdePackages.qtwayland # Qt6 Wayland platform plugin
    adw-gtk3          # Theme from libadwaita ported to GTK-3 for consistent look
    
    # -- System Utilities --
    wl-clipboard      # Command-line copy/paste utilities for Wayland
    cliphist          # Clipboard history manager that stores copied items
    brightnessctl     # Tool to read and control device brightness
    playerctl         # Command-line utility to control media players
    pavucontrol       # PulseAudio Volume Control GUI for managing audio devices
    networkmanagerapplet # Network Manager icon in the system tray
    libnotify         # Library that sends desktop notifications to a notification daemon
    
    # -- Screenshot Utilities --
    swappy            # Wayland native screenshot editing tool
    grim              # Screenshot utility for Wayland
    slurp             # Select a region in a Wayland compositor
    
    # -- Command Line Tools --
    jq                # Lightweight and flexible command-line JSON processor
    socat             # Multipurpose relay (SOcket CAT) used for IPC handling
    fd                # Simple, fast and user-friendly alternative to 'find'
    starship          # Cross-shell prompt utilized in the terminal
    fish              # Smart and user-friendly command line shell
    
    # -- Terminal Emulators --
    kitty             # GPU-accelerated terminal emulator
    foot              # Fast, lightweight and minimalist Wayland terminal emulator

    # -- Fonts --
    font-awesome                  # Icon set for web and desktop
    fira-code                     # Monospaced font with programming ligatures
    fira-code-symbols             # Symbols for Fira Code
    noto-fonts                    # Google Noto Fonts
    noto-fonts-color-emoji        # Emoji Support
    nerd-fonts.jetbrains-mono     # JetBrains Mono font patched with Nerd Font icons
    nerd-fonts.symbols-only       # Font containing only symbols/icons from Nerd Fonts
    material-symbols              # Material Symbols font from Google
    papirus-icon-theme            # Standard icon theme used by the end-4 config
  ];

  # Enable Fontconfig to discover the installed fonts
  fonts.fontconfig.enable = true;
}