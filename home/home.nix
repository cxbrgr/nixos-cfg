{ config, pkgs, ... }:

{
  # User Info
  home.username = "chrisleebear";
  home.homeDirectory = "/home/chrisleebear";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # Moved from configuration.nix
    spotify
    discord
    obsidian

    # Tools
    zip
    unzip
    ripgrep # Better grep
  ];

  # Basic Git Setup (Managed by code now!)
  programs.git = {
    enable = true;
    userName = "chr-ber"; # Change to your actual name
    userEmail = "christopher.alexander.berger@gmail.com"; # Change this
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # ==========================================
  # CONFIG FILE MANAGEMENT
  # ==========================================

  # Link Hyprland Config
  xdg.configFile."hypr/hyprland.conf".source = ../hypr/hyprland.conf;
  xdg.configFile."hypr/hyprpaper.conf".source = ../hypr/hyprpaper.conf;

  # Link Waybar (The whole folder)
  xdg.configFile."waybar".source = ../waybar;

  # (Optional) Link Oh My Posh config if you downloaded one
  # xdg.configFile."oh-my-posh/config.json".source = ../scripts/theme.json;
}
