{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.systemd-boot.consoleMode = "max";

  boot.loader.systemd-boot.extraEntries = 
  {
    "arch.conf" = ''
      title Omarchy (Arch Linux)
      linux /vmlinuz-linux
      initrd /amd-ucode.img
      initrd /initramfs-linux.img
      options cryptdevice=UUID=5c21a2bf-807d-4514-ae6d-cd6d0c468b5e:cryptlvm root=/dev/vg_workstation/omarchy rw nvidia_drm.modeset=1
    '';
  };

  boot.initrd.luks.devices."cryptlvm".device = "/dev/disk/by-uuid/5c21a2bf-807d-4514-ae6d-cd6d0c468b5e";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings.experimental-features = [ "nix-command" "flakes"];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;  

  hardware.graphics = {
    enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.xserver.enable = true;

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.excludePackages = [
    pkgs.xterm
  ];

  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  console.keyMap = "de";

  networking.hostName = "wrkstn";
  networking.networkmanager.enable = true;

  users.users.chrisleebear = {
    isNormalUser = true;
    description = "ChrisLeeBear";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  nixpkgs.config.allowUnfree = true;

  programs.hyprland.enable = true;
  services.geoclue2.enable = true;  # For QtPositioning

  programs.gamemode.enable = true;
  
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; 
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    pciutils
    google-chrome
    vscode
    antigravity
    spotify
    discord
    ripgrep
    remmina
    opencode
    claude-code
  ];

  fonts.packages = with pkgs; [
    rubik
    nerd-fonts.ubuntu
    nerd-fonts.jetbrains-mono
];

  # TODO: find option for lagging update
  #system.autoUpgrade.enabled = true;
  #system.autoUpgrade.dates = "monthly";

  # garbage collect generations
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 14d";
  nix.settings.auto-optimise-store = true;

  system.stateVersion = "25.11"; 
}
