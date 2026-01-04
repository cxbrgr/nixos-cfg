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
  nix.settings.experimental-features = [ "nix-command" "flakes"];

  system.stateVersion = "26.05";

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
  services.desktopManager.gnome.enable = true;
  
  services.xserver.enable = true;
  services.xserver.excludePackages = [
    pkgs.xterm
  ];

# ==========================================
# network
# ==========================================
  networking.hostName = "wrkstn";
  networking.networkmanager.enable = true;

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

# ==========================================
# home-manager
# ==========================================
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.chrisleebear = import ./home.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
  };

# ========================================== 
# fonts
# ========================================== 

  fonts.packages = with pkgs; [
    # nerd fonts
    nerd-fonts.caskaydia-cove
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.jetbrains-mono     
    nerd-fonts.mononoki
    nerd-fonts.space-mono
    nerd-fonts.symbols-only       
    nerd-fonts.ubuntu
    nerd-fonts.ubuntu-mono

    # monospace
    rubik
    fira-code                     
    fira-code-symbols             
    hanken-grotesk                
    noto-fonts                    

    # icons
    font-awesome                  
    material-symbols              
    papirus-icon-theme    
    noto-fonts-color-emoji        
  ];

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
  programs.hyprland.enable = true; 
  services.flatpak.enable = true;
  
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
    direnv
    google-chrome
    vscode
    pciutils
    pwvucontrol
    qjackctl
  ];

# ========================================== 
# garbage collection
# ========================================== 
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 14d";
  nix.settings.auto-optimise-store = true;
}
