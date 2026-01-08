{
  config,
  pkgs,
  usr,
  ...
}:
{
  imports = [
    ../../modules/packages-common.nix
    ../../modules/packages-hmsrvr.nix
    ../../modules/git.nix
    ../../modules/fish.nix
    ../../modules/starship
    ../../modules/zoxide.nix
    ../../modules/atuin.nix
    ../../modules/direnv.nix
  ];

  home.username = usr.name;
  home.homeDirectory = "/home/${usr.name}";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    eza
    bat
    fd
    ripgrep
    fastfetch
    htop
    ncdu
  ];

  programs.home-manager.enable = true;
}
