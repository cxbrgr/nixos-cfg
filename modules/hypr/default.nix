{ pkgs, lib, config, ... }:
{
  # TODO: Potentially causes qs crash on nixos-rebuild switch
  #xdg.configFile."hypr/custom/rules.conf".source = ./custom/rules.conf;
  #xdg.configFile."hypr/custom/general.conf".source = ./custom/general.conf;
  #xdg.configFile."hypr/custom/exec.conf".source = ./custom/exec.conf;
}