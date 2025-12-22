{ config, pkgs, ... }:

{
  # ==========================================
  # USER INFO
  # ==========================================
  home.username = "chrisleebear";
  home.homeDirectory = "/home/chrisleebear";

  # ==========================================
  # SYSTEM STATE VERSION
  # ==========================================
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;

  # ==========================================
  # ENABLE THE THEME MODULES
  # ==========================================
  illogical-impulse = {
    enable = true;
    dotfiles = {
      kitty.enable = true;
      fish.enable = true;
      starship.enable = true;
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
