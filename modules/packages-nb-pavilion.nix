{ 
  pkgs,
  lib,
  ... 
}:
{
  home.packages = with pkgs; [
    # ==========================================
    # Desktop Apps - nb-pavilion (Business/Study)
    # ==========================================

    # -- Desktop Utilities --
    seahorse          # GNOME keyring manager for passwords
    polkit_gnome      # PolicyKit authentication agent (GUI password prompts)
    gnome-tweaks      # GNOME customization tool

    # Note: Browsers (Chrome, Brave) installed at system level
    # Additional packages can be added as needed for business/study use
  ];

  # Flatpak configuration
  services.flatpak = {
    enable = true;
    uninstallUnmanaged = false; 
    uninstallUnused = false;

    update.onActivation = false;
    update.auto = {
      enable = true;
      onCalendar = "monthly";
    };

    packages = [
      "io.github.kolunmi.Bazaar"  # Flatpak package manager
    ];
    
    remotes = lib.mkOptionDefault [{
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }];
  };
}
