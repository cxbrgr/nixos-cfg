{ 
  config,
  pkgs, 
  lib,
  usr,
  ... 
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/fonts.nix
    ../../modules/nix-gc.nix
    ../../modules/docker.nix
    ../../modules/nix-ld.nix
  ];

  # --- NIX SETTINGS ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" usr.name ];
  };
  nixpkgs.config.allowUnfree = true;

  # --- BOOT & ZFS ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  
  # Enable ZFS
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "1f487b70";
  services.zfs.autoScrub.enable = true;

  # --- BACKUP BOOTLOADER SYNC ---
  system.activationScripts.syncBoot = ''
    echo "Syncing boot partition to backup drive..."
    cp -r /boot/* /boot-backup/ || true
  '';

  # ==========================================
  # network
  # ==========================================
  networking.hostName = "hmsrvr";
  networking.networkmanager.enable = true;

  # ==========================================
  # time & locale
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

  # ==========================================
  # users
  # ==========================================
  users.users.${usr.name} = {
    isNormalUser = true;
    description = usr.fullName;
    extraGroups = [ 
      "networkmanager"
      "wheel" 
      "docker"
    ];
  };

  # ==========================================
  # home-manager
  # ==========================================
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit usr; };
    users.${usr.name} = import ./home.nix;
  };

  # ==========================================
  # services
  # ==========================================
  services.openssh.enable = true;
  
  custom.docker.enable = true;

  # ==========================================
  # system
  # ==========================================
  system.stateVersion = "25.11";
}