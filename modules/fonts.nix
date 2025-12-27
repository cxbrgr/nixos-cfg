{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.illogical-impulse;
  nurPkgs = inputs.nur.legacyPackages.${pkgs.system};
  customPkgs = import ../pkgs { inherit pkgs; };
in
{
  config = lib.mkIf cfg.enable {
    # Enable Fontconfig to discover the installed fonts
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      # --- Nerd Fonts ---
      nerd-fonts.caskaydia-cove
      nerd-fonts.fantasque-sans-mono
      nerd-fonts.jetbrains-mono     # JetBrains Mono font patched with Nerd Font icons
      nerd-fonts.mononoki
      nerd-fonts.space-mono
      nerd-fonts.symbols-only       # Font containing only symbols/icons from Nerd Fonts
      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-mono

      # --- Standard Fonts ---
      fira-code                     # Monospaced font with programming ligatures
      fira-code-symbols             # Symbols for Fira Code
      hanken-grotesk                # Font used in Quickshell/matugen
      noto-fonts                    # Google Noto Fonts
      noto-fonts-color-emoji        # Emoji Support
      nurPkgs.repos.skiletro.gabarito
      rubik                         # Font used in Hyprland/Quickshell

      # --- Icons & Themes ---
      font-awesome                  # Icon set for web and desktop
      material-symbols              # Material Symbols font from Google
      papirus-icon-theme            # Standard icon theme used by the end-4 config
    ];
  };
}