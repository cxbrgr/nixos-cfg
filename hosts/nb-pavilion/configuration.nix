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
    ../../modules/nix-ld.nix
    ../../modules/home-manager.nix
    ../../modules/wireguard.nix
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
      "mehri"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # --- BOOT & ZFS ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # ==========================================
  # network
  # ==========================================
  networking = {
    hostName = "nb-pavilion";
    search = [ "lan" ];
    domain = "lan";
    networkmanager.enable = true;
  };

  networking.firewall.enable = true;
  
  # ==========================================
  # time & locale
  # ==========================================
  time.timeZone = "Europe/Vienna";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  console.keyMap = "us";

  # ==========================================
  # graphics & hardware
  # ==========================================
  hardware.graphics.enable = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableAllFirmware = true;

  # NVIDIA Prime Sync (render on NVIDIA, output on Intel)
  # Note: Mobile 840M requires Intel for display output
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;  # Use proprietary driver
    nvidiaSettings = true;
    prime = {
      sync.enable = true;  # Always use NVIDIA for rendering
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:10:0:0";
    };
  };


  # ==========================================
  # desktop environment
  # ==========================================
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
    xkb = {
      layout = "us,ir";  # US English + Persian/Farsi
      options = "grp:alt_shift_toggle";  # Switch layouts with Alt+Shift
    };
  };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # ==========================================
  # audio
  # ==========================================
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ==========================================
  # keyring & authentication
  # ==========================================
  services.gnome.gnome-keyring.enable = true;

  # ==========================================
  # power management (laptop)
  # ==========================================
  services.upower.enable = true;

  # ==========================================
  # location services
  # ==========================================
  services.geoclue2.enable = true;

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

  users.users.mehri = {
    isNormalUser = true;
    description = "Mehri";
    extraGroups = [ 
      "networkmanager"
      "wheel"
      "video"
      "audio"
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
  # packages
  # ==========================================
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    google-chrome
    brave
  ];

  # ==========================================
  # services
  # ==========================================
  services.openssh.enable = true;
}
