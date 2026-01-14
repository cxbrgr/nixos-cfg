{ 
  config,
  pkgs,
  lib,
  ... 
}:
let
  # This script intercepts calls to 'cmake' and injects the compatibility flag
  # needed to build the old 'libolm' library.
  cmake-shim = pkgs.writeShellScriptBin "cmake" ''
    exec ${pkgs.cmake}/bin/cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 "$@"
  '';

  extraPath = lib.makeBinPath (with pkgs; [
    coreutils
    cmake-shim
    gnumake
    gcc
    pkg-config
    python3
  ]);

  bbctl-wrapper = pkgs.writeShellScriptBin "bbctl-custom" ''
    export PATH="${extraPath}:$PATH"
    exec ${pkgs.beeper-bridge-manager}/bin/bbctl "$@"
  '';
in
{
  home.packages = [
    bbctl-wrapper
    pkgs.beeper-bridge-manager
  ];

  systemd.user.services.beeper-telegram = {
    Unit = {
      Description = "Beeper Telegram Bridge";
      After = [ "network-online.target" ];
    };
    Service = {
      ExecStart = "${bbctl-wrapper}/bin/bbctl-custom run sh-telegram";
      Restart = "always";
      RestartSec = 10;
      StandardOutput = "journal";
      StandardError = "journal";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.beeper-whatsapp = {
    Unit = {
      Description = "Beeper WhatsApp Bridge";
      After = [ "network-online.target" ];
    };
    Service = {
      ExecStart = "${bbctl-wrapper}/bin/bbctl-custom run sh-whatsapp";
      Restart = "always";
      RestartSec = 10;
      StandardOutput = "journal";
      StandardError = "journal";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}