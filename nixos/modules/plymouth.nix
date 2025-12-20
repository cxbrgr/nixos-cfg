{ config, pkgs, ... }:

{
  boot.plymouth = {
    enable = true;
    theme = "catppuccin-macchiato";
    themePackages = with pkgs; [
      # Catppuccin Theme
      (catppuccin-plymouth.override {
        variant = "macchiato";
      })
      # Breeze Theme
      kdePackages.breeze-plymouth
    ];
  };

  # Ensure the console resolution is high enough for the splash screen
  boot.loader.systemd-boot.consoleMode = "max";
}
