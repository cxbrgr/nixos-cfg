{ 
  pkgs,
  lib,
  config,
  ...
}:
{
  options.custom.docker = {
    enable = lib.mkEnableOption "Enable Docker configuration";
  };

  config = lib.mkIf config.custom.docker.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
    };
      
    users.users.chrisleebear.extraGroups = [ "docker" ];
    
    environment.systemPackages = with pkgs; [
      docker-compose
      lazydocker
    ] ++ lib.optionals config.services.desktopManager.gnome.enable [
      gnomeExtensions.docker
    ];
  };
}
