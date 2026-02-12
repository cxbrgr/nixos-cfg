{
  illogical-flake,
  nix-flatpak,
  usr,
  ...
}:

{
  imports = [
    illogical-flake.homeManagerModules.default
    nix-flatpak.homeManagerModules.nix-flatpak
    ../../modules/packages-common.nix
    ../../modules/packages-wrkstn.nix
    ../../modules/git.nix
    ../../modules/ghostty.nix
    ../../modules/fish.nix
    ../../modules/starship
    ../../modules/direnv.nix
    ../../modules/zoxide.nix
    ../../modules/atuin.nix
    ../../modules/hypr/default.nix
    ../../modules/spotifyd/home.nix
    ../../modules/beeper/beeper-client.nix
    ../../modules/zed.nix
  ];

  home.username = usr.name;
  home.homeDirectory = "/home/${usr.name}";

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  home.sessionVariables = {
    XDG_DATA_DIRS = "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
  };

  programs.illogical-impulse = {
    enable = true;
  };
}
