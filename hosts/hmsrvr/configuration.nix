{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
      ../../modules/docker.nix
    ];

  custom.docker.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.systemd-boot.consoleMode = "max";

  boot.initrd.luks.devices."cryptlvm".device = "/dev/disk/by-uuid/5c21a2bf-807d-4514-ae6d-cd6d0c468b5e";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings.experimental-features = [ "nix-command" "flakes"];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;  

  hardware.graphics = {
    enable = true;
  };

  services.xserver.enable = true;

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.excludePackages = [
    pkgs.xterm
  ];

  networking.hostName = "hmsrvr";
  networking.networkmanager.enable = true;

  users.users.chrisleebear = {
    isNormalUser = true;
    description = "ChrisLeeBear";
    extraGroups = [ 
      "networkmanager"
      "wheel" 
      "video" 
      "input" 
      "i2c" 
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.chrisleebear = import ./home.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  nixpkgs.config.allowUnfree = true;

  programs.hyprland.enable = true;

  # ==========================================
  # LOCALE & TIME (Vienna)
  # ==========================================
  time.timeZone = "Europe/Vienna";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };

  console.keyMap = "de";

  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  services.geoclue2.enable = true;

  #############################################

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    direnv
    google-chrome
    vscode
    pciutils
  ];

  # garbage collect generations
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 14d";
  nix.settings.auto-optimise-store = true;

  system.stateVersion = "25.11"; 
}
