# Steam System Configuration (user-agnostic)
# Import this in your NixOS configuration (configuration.nix)
#
# ============================================================================
# USER GROUPS FOR GAMING
# ============================================================================
# Steam/gaming requires users to be in these groups:
#   - gamemode: Required for GameMode CPU governor optimizations
#   - input:    Required for controller/gamepad access
#   - audio:    Required for audio device access
#   - video:    Required for GPU access and hardware acceleration
#
# Since this module is user-agnostic, you have several options:
#
# OPTION 1: Add groups directly to user definitions (recommended)
#   In your configuration.nix, add to each gaming user:
#
#   users.users.chrisleebear = {
#     extraGroups = [ "gamemode" "input" "audio" "video" ];
#   };
#
# OPTION 2: Make this module take a user parameter (curried function)
#   user: { pkgs, ... }: {
#     ...
#     users.users.${user.name}.extraGroups = [ "gamemode" ... ];
#   }
#   Then import as: import ./steam/system.nix usr
#
# OPTION 3: Define a list of gaming users and iterate
#   let gamingUsers = [ "chrisleebear" "otheruser" ]; in
#   {
#     users.users = lib.genAttrs gamingUsers (name: {
#       extraGroups = [ "gamemode" "input" "audio" "video" ];
#     });
#   }
#
# ============================================================================
{
  pkgs,
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

        libXcursor
        libXi
        libXinerama
        libXScrnSaver
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

  # Note: Add these groups to gaming users in their user definition:
  # extraGroups = [ "gamemode" "input" "audio" "video" ];
}
