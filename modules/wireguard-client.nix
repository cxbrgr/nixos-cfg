{ 
  config,
  pkgs,
  ... 
}:
{
  boot.kernelModules = [ "wireguard" ];

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  # we need systemd-resolved enabled to configure split DNS
  services.resolved.enable = true;
}
