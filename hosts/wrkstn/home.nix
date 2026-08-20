{
  lib,
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

  xdg.configFile."hypr/custom/general.conf".text = lib.mkForce ''
    # General overrides for wrkstn NVIDIA GPU
    monitor = DP-4, 3440x1440@100, 0x0, 1
    monitor = HDMI-A-2, 2560x1440@75, 3440x0, 1
    monitor = DP-1, 3440x1440@100, 0x0, 1

    input {
        kb_layout = de
        follow_mouse = 1
        touchpad {
            natural_scroll = no
        }
        sensitivity = 0
    }

    cursor {
        no_hardware_cursors = true
    }

    render {
        direct_scanout = false
    }

    general {
        allow_tearing = false
    }
  '';
}
