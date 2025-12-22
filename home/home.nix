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
    # Main config is now imported via flake.nix -> modules/default.nix
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

}