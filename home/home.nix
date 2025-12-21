{ config, pkgs, quickshell, ... }:

{
  # ==========================================
  # USER INFO
  # ==========================================
  home.username = "chrisleebear";
  home.homeDirectory = "/home/chrisleebear";

  # ==========================================
  # IMPORTS (The "Table of Contents")
  # ==========================================
  imports = [
    # ./shell.nix   # (Uncomment when you populate this file)
    # ./theme.nix   # (Uncomment when you populate this file)
    ./apps.nix      # <--- All your packages are now inside here
  ];

  # ==========================================
  # SYSTEM STATE VERSION
  # ==========================================
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;

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
    initContent = ''
      eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${config.home.homeDirectory}/dotfiles/home/p10k.omp.json)"
    '';
    
    # Aliases (Shortcuts)
    shellAliases = {
      ll = "ls -l";
      c = "clear";
      g = "git";
      gs = "git status";
      flake-update = "~/dotfiles/scripts/update.sh";
      flake-rebuild = "sudo nixos-rebuild switch --flake ~/dotfiles#nixos";
      flake-drybuild = "sudo nixos-rebuild dry-build --flake ~/dotfiles#nixos";
    };
  };

# ==========================================
  # CONFIG LINKS (End-4 Dotfiles Configuration)
  # Mapping configuration files from ./dotfiles-end4 to ~/.config/
  # ==========================================
  xdg.configFile = {
    "Kvantum".source = ./dotfiles-end4/Kvantum;
    "fish".source = ./dotfiles-end4/fish;
    "fontconfig/fonts.conf".source = ./dotfiles-end4/fontconfig/fonts.conf;
    "foot".source = ./dotfiles-end4/foot;
    "fuzzel".source = ./dotfiles-end4/fuzzel;
    "hypr".source = ./dotfiles-end4/hypr;
    "kde-material-you-colors".source = ./dotfiles-end4/kde-material-you-colors;
    "kitty".source = ./dotfiles-end4/kitty;
    "matugen".source = ./dotfiles-end4/matugen;
    "mpv".source = ./dotfiles-end4/mpv;
    "quickshell".source = ./dotfiles-end4/quickshell;
    "wlogout".source = ./dotfiles-end4/wlogout;
    "xdg-desktop-portal".source = ./dotfiles-end4/xdg-desktop-portal;
    "zshrc.d".source = ./dotfiles-end4/zshrc.d;
    
    "chrome-flags.conf".source = ./dotfiles-end4/chrome-flags.conf;
    "code-flags.conf".source = ./dotfiles-end4/code-flags.conf;
    "darklyrc".source = ./dotfiles-end4/darklyrc;
    "dolphinrc".source = ./dotfiles-end4/dolphinrc;
    "kdeglobals".source = ./dotfiles-end4/kdeglobals;
    "konsolerc".source = ./dotfiles-end4/konsolerc;
    "starship.toml".source = ./dotfiles-end4/starship.toml;
    "thorium-flags.conf".source = ./dotfiles-end4/thorium-flags.conf;
  };
}