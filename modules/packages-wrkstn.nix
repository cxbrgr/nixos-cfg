{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
      # -- Media / Office / Social --
      discord           # All-in-one voice and text chat for gamers
      obsidian          # Knowledge base that operates on local Markdown files

      # -- Audio --
      spotify           # Proprietary music streaming service
      alsa-scarlett-gui # GUI for Scarlett 2i2i
      playerctl         # Command line tool for controlling media players
      bitwig-studio     # The DAW
      reaper            # Good to have as backup/mastering
      qpwgraph          # Visual patchbay (essential for routing PipeWire)

      # Browsers
      # no nix pacakge available - thorium          # Chromium fork compiled with AVX optimizations for maximum speed
      nyxt              # Infinite extensibility via Common Lisp; the "Emacs of browsers"
      vivaldi           # Power-user GUI with built-in vertical tabs, split-screen, and gestures
      qutebrowser       # Keyboard-driven minimalism with Vim-like bindings (QtWebEngine backend)
    ];

  services.flatpak = {
    enable = true;
    # unmanaged and managed can coexist
    uninstallUnmanaged = false; 
    # cleanup unused flatpaks
    uninstallUnused = false;

    # do not update on app startup
    update.onActivation = false;
    # regularly auto update flatpaks
    update.auto = {
      enable = true;
      onCalendar = "monthly";
    };

    packages = [
      "io.github.kolunmi.Bazaar"
      "com.github.IsmaelMartinez.teams_for_linux"
    ];
    
    remotes = lib.mkOptionDefault [{
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }];
  };
}