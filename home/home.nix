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
    antigravity       # Google AI IDE

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
  # SYSTEMD SERVICES
  # ==========================================
  # This makes Waybar start automatically and restart if it crashes
  systemd.user.services.waybar = {
    Unit = {
      Description = "Waybar status bar";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.waybar}/bin/waybar";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
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
  # TERMINAL (Kitty)
  # ==========================================
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha"; # Built-in via Home Manager!
    
    font = {
      name = "FiraCode Nerd Font";
      size = 12;
    };
    
    settings = {
      # Window padding (So text isn't glued to the edge)
      window_padding_width = 10;
      
      # Transparency (Optional - remove if you want solid background)
      background_opacity = "0.9";
      
      # Bell
      enable_audio_bell = false;
    };
  };

# ==========================================
  # SHELL (Zsh + Oh My Posh)
  # ==========================================
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Oh My Posh Init
    initConfig = ''
      eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${config.home.homeDirectory}/dotfiles/home/p10k.omp.json)"
    '';
    
    # Aliases (Shortcuts)
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch --flake ~/dotfiles#nixos";
      c = "clear";
      g = "git";
      # Add this so 'gs' is git status (optional)
      gs = "git status";
      flake-update = "~/dotfiles/scripts/update.sh";
      flake-rebuild = "sudo nixos-rebuild switch --flake ~/dotfiles#nixos";
    };
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