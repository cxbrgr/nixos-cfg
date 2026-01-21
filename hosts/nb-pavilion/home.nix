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
    ../../modules/git.nix
    ../../modules/fish.nix
    ../../modules/starship
    ../../modules/zoxide.nix
    ../../modules/atuin.nix
    ../../modules/direnv.nix
  ];

  home.username = user.name;
  home.homeDirectory = "/home/${user.name}";
  
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}