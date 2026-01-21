{ 
  lib,
  config,
  pkgs,
  ... 
}:
{
  users.users.chrisleebear = {
    isNormalUser = true;
    description = "ChrisLeeBear";
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
