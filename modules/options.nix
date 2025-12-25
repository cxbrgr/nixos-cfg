{ config, pkgs, lib, illogical-impulse-dotfiles, ... }:
with lib;
let
in
{
  options.illogical-impulse = {
    enable = mkEnableOption "Enable illogical-impulse";
    hyprland = {
      monitor = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ",preferred,auto,1" ];
        description = "Monitor preferences for Hyprland";
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.hyprland;
        description = "Hyprland package";
      };
      xdgPortalPackage = lib.mkOption {
        type = lib.types.package;
        default = pkgs.xdg-desktop-portal-hyprland;
        description = "xdg-desktop-portal package for Hyprland";
      };
      ozoneWayland.enable = lib.mkEnableOption "Set NIXOS_OZONE_WL=1";
    };

    dotfiles = {
      kitty.enable = mkEnableOption "Enable illogical-impulse kitty";
      fish.enable = mkEnableOption "Enable illogical-impulse fish";
      starship.enable = mkEnableOption "Enable illogical-impulse starship";
    };

    theme = {
      cursor = {
        theme = lib.mkOption {
          type = lib.types.str;
          default = "Bibata-Modern-Ice";
          description = "Cursor theme name";
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.bibata-cursors;
          description = "Cursor theme package";
        };
      };
    };
  };

  config = mkMerge [
    (mkIf (config.illogical-impulse.enable) {
      xdg.configFile."Kvantum/Colloid".source = "${illogical-impulse-dotfiles}/dots/.config/Kvantum/Colloid";
      xdg.configFile."matugen".source = "${illogical-impulse-dotfiles}/dots/.config/matugen";
      xdg.configFile."mpv/mpv.conf".source = "${illogical-impulse-dotfiles}/dots/.config/mpv/mpv.conf";
    })
    (mkIf (config.illogical-impulse.enable && config.illogical-impulse.dotfiles.kitty.enable) {
      xdg.configFile."kitty".source = "${illogical-impulse-dotfiles}/dots/.config/kitty";
      home.packages = [ pkgs.kitty ];
    })
    (mkIf (config.illogical-impulse.enable && config.illogical-impulse.dotfiles.starship.enable) {
      xdg.configFile."starship.toml".source = "${illogical-impulse-dotfiles}/dots/.config/starship.toml";
      home.packages = [ pkgs.starship ];
    })
    (mkIf (config.illogical-impulse.enable && config.illogical-impulse.dotfiles.fish.enable) {
      xdg.configFile."fish/config.fish".source = lib.mkForce "${illogical-impulse-dotfiles}/dots/.config/fish/config.fish";
      home.packages = [ pkgs.fish ];
    })
  ];
}