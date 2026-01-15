{
  pkgs,
  usr,
  ...
}:
{
  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--adaptive-sync"
        "--rt"
        "--mangoapp"
      ];
    };
    gamemode = {
      enable = true;
      enableRenice = true;
      settings.general.renice = 20;
    };
    steam = {
      enable = true;
      gamescopeSession = {
        enable = true;
        args = [
          "--adaptive-sync"
          "--rt"
          "--mangoapp"
          "--borderless"
          "--scale-to-output 1.0"
          "--scale-to-window 1.0"
          "--session-name steam"
        ];
      };
      extraPackages = with pkgs; [
        gamescope-wsi
        gamemode
        mangohud
        steamtinkerlaunch

        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
      ];
    };
  };

  hardware.steam-hardware.enable = true;

  users.users.${usr.name}.extraGroups = [ "gamemode" ];

  home-manager.users.${usr.name} = {
    programs.mangohud.enable = true;
  };
}