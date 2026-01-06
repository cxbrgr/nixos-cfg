{ config, pkgs, lib, inputs, usr, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/docker.nix
    ];

  custom.docker.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.systemd-boot.consoleMode = "max";

  boot.initrd.luks.devices."cryptlvm".device = "/dev/disk/by-uuid/5c21a2bf-807d-4514-ae6d-cd6d0c468b5e";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
    trusted-users = [ "root" usr.name ];
  };

  # Run unpatched binaries (useful for AppImages, VS Code remote, etc.)
  programs.nix-ld.enable = true;
  services.envfs.enable = true;

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

  users.users.${usr.name} = {
    isNormalUser = true;
    description = usr.fullName;
    extraGroups = [ 
      "networkmanager"
      "wheel" 
      "video" 
      "input" 
      "i2c" 
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs usr; };
    users.${usr.name} = import ./home.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
    # address clobbering of files, by moving them to a new location in the same director
    backupFileExtension = "backup";    
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
