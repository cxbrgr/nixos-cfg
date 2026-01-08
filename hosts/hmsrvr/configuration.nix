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

  system.stateVersion = "25.11";

  # --- NIX SETTINGS ---
  nix.settings = {
    experimental-features = [ 
      "nix-command"
      "flakes"
    ];
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
    trusted-users = [ 
      "root"
      usr.name
    ];
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
  networking = {
    hostName = "hmsrvr";
    search = [ "lan" ];

    nameservers = [ 
      "192.168.0.199" 
      "1.1.1.1"
    ];

    defaultGateway = "192.168.0.1";

    interfaces.enp2s0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "192.168.0.199";
        prefixLength = 24;
      }];
    };

    networkmanager = {
      enable = true;
      dns = "default";

      insertNameservers = [ 
        "192.168.0.199"
        "1.1.1.1"
      ];
    };
  };

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
}