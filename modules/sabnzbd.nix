{
  pkgs,
  usr,
  ...
}:
{

  services.sabnzbd = {
    enable = true;
  };

  users.users.${usr.Name}.extraGroups = [ "sabnzbd" ];
}