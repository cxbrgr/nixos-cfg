# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/plymouth.nix
    ];

  # ==========================================
  # BOOT & KERNEL (Crucial for 9800X3D + Encryption)
  # ==========================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # CRITICAL: ENCRYPTION KEY
  boot.initrd.luks.devices."luks-0905c652-9881-4409-8c6f-63bf8d407254".device = "/dev/disk/by-uuid/0905c652-9881-4409-8c6f-63bf8d407254";

  # ==========================================
  # NETWORKING
  # ==========================================
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

# ==========================================
  # BLUETOOTH
  # ==========================================
  hardware.bluetooth.enable = true;        # Enable the physical hardware
  hardware.bluetooth.powerOnBoot = true;   # Ensure it turns on at startup
  services.blueman.enable = true;          # The GUI Manager (blueman-applet)

  # ==========================================
  # LOCALE & TIME (Vienna)
  # ==========================================
  time.timeZone = "Europe/Vienna";

  # Select internationalisation properties.
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # ==========================================
  # GRAPHICS & NVIDIA (RTX 4090 Optimized)
  # ==========================================
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load Nvidia drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # ==========================================
  # DESKTOP ENVIRONMENT
  # ==========================================
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Unlock Keyring on Login
  security.pam.services.hyprland.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  # Package Manager https://flatpak.org/
  services.flatpak.enable = true;

  # Enable Hyprland (Selectable at login)
  programs.hyprland.enable = true;

  # ==========================================
  # AUDIO & PRINTING
  # ==========================================
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable GVFS for virtual file system support (needed for file managers).
  services.gvfs.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # ==========================================
  # USER ACCOUNTS
  # ==========================================
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.chrisleebear = {
    isNormalUser = true;
    description = "Chris";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # ==========================================
  # SOFTWARE & PACKAGES
  # ==========================================
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Install firefox.
  programs.firefox.enable = true;

  # GAMING
  programs.gamemode.enable = true;
  
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; 
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # Enable ZSH as default shell
  programs.zsh.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # System Tools
    vim 
    wget
    git
    htop
    fastfetch
    pkgs.dotfiles

    # -- HYPRLAND ESSENTIALS --
    kitty     # The terminal (Hyprland needs this by default)
    wofi      # The app launcher (like Start Menu)
    waybar    # The status bar at the top
    dunst     # Notification daemon (so you see popups)
    hyprpaper # Wallpaper
  ];

  # ==========================================
  # POLKIT (The Password Popup)
  # ==========================================
  security.polkit.enable = true;
  
  # Auto-start the GNOME Polkit agent for Hyprland
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
    };
  };

  # ==========================================
  # FIREWALL
  # ==========================================
  networking.firewall = {
    enable = true;
    # Open a sequential block for self hosted apps in local network (e.g., 10000 to 10050)
    allowedTCPPortRanges = [
      { from = 10000; to = 10050; }
    ];
    allowedUDPPortRanges = [
      { from = 10000; to = 10050; }
    ];
  };

  # ==========================================
  # ADGUARD HOME (DNS Blocker)
  # ==========================================
  services.adguardhome = {
    enable = true;
    
    # 1. Open the Firewall
    # This allows devices on the network to send DNS queries to this PC
    # and allows you to access the Web UI (initially port 10000)
    openFirewall = true;

    # 2. Mutable Settings (Recommended: true)
    # true  = You configure Blocklists/Upstreams via the Web UI (Easy)
    # false = You must configure EVERYTHING in this file (Hard mode)
    mutableSettings = true;
    
    # 3. Initial Port for setup wizard
    port = 10000;
  };

  # To make AdGuard Home the primary DNS resolver
  # 1. Disable the default systemd resolver to free up Port 53
  services.resolved.enable = false;
  # 2. Tell NixOS to look at itself (localhost) for DNS
  networking.nameservers = [ "127.0.0.1" "1.1.1.1" ];

  # ==========================================
  # FLAKES & NEW COMMANDS
  # ==========================================
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ==========================================
  # FONTS (Crucial for the UI icons)
  # ==========================================
  fonts.packages = with pkgs; [
    font-awesome              # Icons
    nerd-fonts.fira-code      # Terminal font
    nerd-fonts.jetbrains-mono # Coding font
  ];

  # ==========================================
  # EXTRA SERVICES (Tutorial Area)
  # ==========================================
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
