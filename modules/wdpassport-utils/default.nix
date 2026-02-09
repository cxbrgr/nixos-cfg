# WD Passport Hardware Encryption Utilities for NixOS
# Provides wdpassport-utils command for unlocking WD My Passport drives
# Source: https://github.com/evox95/wdpassport-utils

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.wdpassport;

  # Build py3_sg package
  py3-sg = pkgs.python3Packages.callPackage ./py3-sg.nix { };

  # Python environment with required dependencies
  pythonEnv = pkgs.python3.withPackages (ps: [
    py3-sg
    ps.pyudev
  ]);

  # Wrapper script that calls the bundled Python script
  wdpassport-utils = pkgs.writeScriptBin "wdpassport-utils" ''
    #!${pkgs.bash}/bin/bash
    exec ${pythonEnv}/bin/python3 ${./wdpassport-utils.py} "$@"
  '';

  # GUI wrapper script for GNOME integration
  # Script is in separate file for proper syntax checking
  wdmanager = pkgs.stdenv.mkDerivation {
    name = "wdmanager";
    src = ./wdmanager.sh;
    buildInputs = [ pkgs.bash ];
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/bin
      substitute $src $out/bin/wdmanager \
        --replace "@zenity@" "${pkgs.zenity}/bin/zenity" \
        --replace "@wdpass@" "${wdpassport-utils}/bin/wdpassport-utils"
      chmod +x $out/bin/wdmanager
    '';
  };

  # Desktop file for GNOME application launcher
  wdmanager-desktop = pkgs.makeDesktopItem {
    name = "wdmanager";
    desktopName = "WD Manager";
    comment = "Unlock WD My Passport encrypted drives";
    exec = "${wdmanager}/bin/wdmanager";
    icon = "drive-harddisk-usb";
    categories = [ "Utility" ];
    terminal = false;
  };
in
{
  options.custom.wdpassport = {
    enable = lib.mkEnableOption "WD Passport drive unlock utilities";
  };

  config = lib.mkIf cfg.enable {
    # Enable NTFS support for mounting WD Passport drives
    boot.supportedFilesystems = [ "ntfs" ];

    # Enable udisks2 for user-space mounting
    services.udisks2.enable = true;

    environment.systemPackages = [
      wdpassport-utils
      wdmanager
      wdmanager-desktop
      pkgs.nfs-utils
      pkgs.ntfs3g # NTFS driver for udisksctl
    ];

    # Blacklist the ntfs3 kernel driver to force use of ntfs-3g (FUSE)
    # The ntfs3 kernel driver fails on "dirty" volumes (not properly unmounted from Windows)
    # ntfs-3g handles these volumes more gracefully
    boot.blacklistedKernelModules = [ "ntfs3" ];
  };
}
