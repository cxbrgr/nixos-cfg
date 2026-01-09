{ 
  config,
  pkgs, 
  lib,
  inputs,
  usr,
  ... 
}:
{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/fonts.nix
      ../../modules/nix-gc.nix
      ../../modules/docker.nix
      ../../modules/steam.nix
      ../../modules/spotifyd/system.nix
      ../../modules/sshfs-mounts.nix
      ../../modules/home-manager.nix
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

  custom.docker.enable = true;

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

  nixpkgs.config.allowUnfree = true;



  # Run unpatched binaries (useful for AppImages, VS Code remote, etc.)
  programs.nix-ld.enable = true;
  services.envfs.enable = true;

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;  

  # ==========================================
  # graphics
  # ==========================================
  hardware.graphics = {
    enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia-container-toolkit.enable = true;
  hardware.nvidia = {
    open = false;
    nvidiaSettings = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.displayManager.gdm.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = usr.name;

  services.desktopManager.gnome.enable = true;
  
  programs.hyprland.enable = true;

  services.xserver.enable = true;
  services.xserver.excludePackages = [
    pkgs.xterm
  ];

  # ==========================================
  # network
  # ==========================================
  networking = {
    hostName = "wrkstn";
    search = [ "lan" ];
    domain = "lan";
    networkmanager.enable = true;
  };
  
  # ==========================================
  # audio and bluetooth
  # ==========================================
  security.rtkit.enable = true;          # required for spotify

  services.pulseaudio.enable = false;    # disable default audio server
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.pipewire.wireplumber.extraConfig."51-disable-suspend"."monitor.alsa.rules" = [
    {
      matches = [{
          "node.name" = "~alsa_output.*Sennheiser_EPOS_GSA_70.*";
      }];
      actions.update-props = {
        "session.suspend-timeout-seconds" = 0;
        "node.always-process" = true;
        "dither.method" = "wannamaker3";
        "dither.noise" = 1;
      };
    }
  ];

  # ==========================================
  # users
  # ==========================================
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

  # ==========================================
  # home-manager
  # ==========================================
    home-manager.users.${usr.name}.imports = [ ./home.nix ];

  # ==========================================
  # time & locale
  # ==========================================
  services.geoclue2.enable = true;
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

  # ==========================================
  # monitoring
  # ==========================================
  services.cockpit = {
    enable = true;
    port = 10000;
    openFirewall = true;
    settings = {
      WebService = {
        AllowUnencrypted = true;
      };
    };
  };

  # ==========================================
  # packages
  # ==========================================
  services.flatpak.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    google-chrome
    vscode
    pciutils
    pwvucontrol
    qjackctl
  ];
}
