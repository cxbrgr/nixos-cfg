# Steam Home-Manager Configuration
# Import this in your home-manager configuration (home.nix)
{ 
  pkgs,
  ... 
}:
{
  programs.mangohud = {
    enable = true;
    # Optional: customize MangoHud settings
    # settings = {
    #   fps_limit = 144;
    #   vsync = 0;
    #   gl_vsync = 0;
    # };
  };
}
