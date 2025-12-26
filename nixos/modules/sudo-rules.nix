{ config, pkgs, ... }:

{
  security.sudo.extraRules = [
    {
      users = [ "chrisleebear" ];
      commands = [
        { 
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        },
        { 
          command = "/run/current-system/sw/bin/shutdown";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}