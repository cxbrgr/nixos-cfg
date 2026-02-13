{
  lib,
  ...
}:
let
  # Change this to any theme in ./themes/
  activeTheme = "cyberpunk-terminal";

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
