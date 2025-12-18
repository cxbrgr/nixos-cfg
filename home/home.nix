{ config, pkgs, ... }:

{
  # ==========================================
  # USER INFO
  # ==========================================
  home.username = "chrisleebear";
  home.homeDirectory = "/home/chrisleebear";

  # ==========================================
  # PACKAGES (User Apps & Tools)
  # ==========================================
  home.packages = with pkgs; [
    # -- SYSTEM TOOLS --
    zip
    unzip
    ripgrep          # Better grep
    remmina          # RDP Client
    polkit_gnome     # Key/Password Guard 
    seahorse         # Password Manager GUI

    # -- THEMING TOOLS --
    catppuccin-gtk   # Window/App Theme
    papirus-icon-theme # Icons
    bibata-cursors   # Cursor
    nwg-look         # GUI to verify themes

    # -- DEVELOPMENT --
    vscode            # Code Editor
    jetbrains.rider   # IDE
    oh-my-posh        # terminal styling

    # -- BROWSERS --
    google-chrome

    # -- SOCIAL / MEDIA --
    spotify
    discord
    obsidian
  ];

  # ==========================================
  # GIT CONFIGURATION
  # ==========================================
  programs.git = {
    enable = true;
    # We use 'extraConfig' to set standard Git values and avoid naming warnings
    settings = {
      user = {
        name = "chr-ber";
        email = "christopher.alexander.berger@gmail.com";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };

  # ==========================================
  # UI THEMING (GTK & CURSOR)
  # ==========================================
  gtk = {
    enable = true;
    
    theme = {
      name = "Catppuccin-Mocha-Standard-Blue-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        tweaks = [ "rimless" "black" ];
        variant = "mocha";
      };
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };
  };

  # Force the cursor theme in other places (like Hyprland)
  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true; # Uncomment if using X11
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  # ==========================================
  # CONFIG FILE MANAGEMENT (Symlinks)
  # ==========================================
  
  # Link Hyprland Config
  xdg.configFile."hypr/hyprland.conf".source = ../hypr/hyprland.conf;
  xdg.configFile."hypr/hyprpaper.conf".source = ../hypr/hyprpaper.conf;

  # Link Waybar (The whole folder)
  xdg.configFile."waybar".source = ../waybar;

  # (Optional) Link Oh My Posh if you have it
  # xdg.configFile."oh-my-posh/config.json".source = ../scripts/theme.json;


  # ==========================================
  # SYSTEM STATE VERSION
  # ==========================================
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}