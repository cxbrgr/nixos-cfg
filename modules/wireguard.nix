{ config, pkgs, ... }:
{
  # WireGuard kernel module
  boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];

  # WireGuard tools
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  # Enable WireGuard in the firewall (optional - allows incoming WireGuard connections)
  # networking.firewall.allowedUDPPorts = [ 51820 ];
}
