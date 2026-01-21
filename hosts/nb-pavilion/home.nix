user:
{ 
  pkgs,
  nix-flatpak,
  ... 
}:
{
  imports = [
    nix-flatpak.homeManagerModules.nix-flatpak
    ../../modules/packages-common.nix
    ../../modules/packages-nb-pavilion.nix
    ../../modules/ghostty.nix
    ../../modules/kitty.nix
    ../../modules/zoxide.nix
    ../../modules/git.nix
    ../../modules/fish.nix
    ../../modules/starship
    ../../modules/atuin.nix
    ../../modules/direnv.nix
  ];

  home.username = user.name;
  home.homeDirectory = "/home/${user.name}";
  
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    gnomeExtensions.appindicator            # System tray icons for apps like Discord, Slack
    gnomeExtensions.dash-to-dock            # macOS-style dock
    gnomeExtensions.caffeine                # Prevent screen from sleeping (useful for presentations)
    gnomeExtensions.clipboard-indicator     # Clipboard history manager
  ];
}