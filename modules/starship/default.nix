{
  lib,
  ...
}:
let
  # Available themes in ./themes/

  # Change this to switch themes:
  activeTheme = "cyberpunk-cstm";

  themesDir = ./themes;
  themeFile = themesDir + "/${activeTheme}.toml";
in
{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  home.sessionVariables = {
    STARSHIP_CONFIG = lib.mkForce "${themeFile}";
  };
}
