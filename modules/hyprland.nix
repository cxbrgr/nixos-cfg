illogical-impulse-dotfiles: inputs: { config, lib, pkgs, ... }:
let
  hypr = config.illogical-impulse.hyprland.package;
  hypr-xdg = config.illogical-impulse.hyprland.xdgPortalPackage;

  enabled = config.illogical-impulse.enable;
  hyprlandConf = config.illogical-impulse.hyprland;
  dotfiles = illogical-impulse-dotfiles;
in
{
  config = lib.mkIf enabled {
    home.packages = with pkgs; [
      hyprpicker
      hyprlock
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        env = [
          "NIXOS_OZONE_WL, 1"
          "GIO_EXTRA_MODULES, ${pkgs.gvfs}/lib/gio/modules"
        ];
        
        # See https://wiki.hypr.land/Configuring/Monitors/
        monitor = [
          "DP-4, 3440x1440@100.00, 0x0, 1"
          "HDMI-A-2, 2560x1440@75.00, 3440x0, 1.066667"
        ];

        workspace = [
          "1, monitor:DP-4"
          "2, monitor:DP-4"
          "3, monitor:DP-4"
          "4, monitor:DP-4"
          "5, monitor:DP-4"

          "6, monitor:HDMI-A-2"
          "7, monitor:HDMI-A-2"
          "8, monitor:HDMI-A-2"
          "9, monitor:HDMI-A-2"
          "10, monitor:HDMI-A-2"
        ];
      };

      # Sourcing External Config Files from the Flake Input
      extraConfig = ''
        # Source the config from the "dotfiles" input
        # Note: The path inside the repo is .config/hypr/...
        source=${dotfiles}/.config/hypr/hyprland/execs.conf
        source=${dotfiles}/.config/hypr/hyprland/general.conf
        source=${dotfiles}/.config/hypr/hyprland/rules.conf
        source=${dotfiles}/.config/hypr/hyprland/colors.conf
        source=${dotfiles}/.config/hypr/hyprland/keybinds.conf
        
        # Custom configs (you can override these locally if you want)
        source=${dotfiles}/.config/hypr/custom/env.conf
        source=${dotfiles}/.config/hypr/custom/execs.conf
        source=${dotfiles}/.config/hypr/custom/general.conf
        source=${dotfiles}/.config/hypr/custom/rules.conf
        source=${dotfiles}/.config/hypr/custom/keybinds.conf
      '';
    };
  
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
        };

        listener = [
          {
            timeout = 120; # 120
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 600; # 10mins
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 900; # 15mins
            on-timeout = "systemctl suspend || loginctl suspend";
          }
        ];
      };
    };

    xdg.configFile."hypr/hyprland/scripts".source =         "${illogical-impulse-dotfiles}/.config/hypr/hyprland/scripts";
    xdg.configFile."hypr/hyprland/execs.conf".source =      "${illogical-impulse-dotfiles}/.config/hypr/hyprland/execs.conf";
    xdg.configFile."hypr/hyprland/general.conf".source =    "${illogical-impulse-dotfiles}/.config/hypr/hyprland/general.conf";
    xdg.configFile."hypr/hyprland/rules.conf".source =      "${illogical-impulse-dotfiles}/.config/hypr/hyprland/rules.conf";
    xdg.configFile."hypr/hyprland/keybinds.conf".source =   "${illogical-impulse-dotfiles}/.config/hypr/hyprland/keybinds.conf";

    xdg.configFile."hypr/hyprlock".source =                 "${illogical-impulse-dotfiles}/.config/hypr/hyprlock";
    xdg.configFile."hypr/shaders".source =                  "${illogical-impulse-dotfiles}/.config/hypr/shaders";
    xdg.configFile."hypr/custom".source =                   "${illogical-impulse-dotfiles}/.config/hypr/custom";
  };
}