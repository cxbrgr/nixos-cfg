{ 
  lib,
  pkgs,
  ...
}:
{
  #### Bluetooth stack (BlueZ) ####
  hardware.bluetooth = {
    enable = lib.mkDefault true;
    powerOnBoot = lib.mkDefault true;

    # BlueZ main.conf
    settings = {
      Policy = {
        # Automatically enables adapters when present
        AutoEnable = lib.mkDefault "true";
      };

      General = {
        # Helps with game controllers on some setups
        ControllerMode = lib.mkDefault "dual";

        # "true" = faster reconnects but more power usage
        FastConnectable = lib.mkDefault "true";

        # Newer BlueZ features; generally fine on modern kernels
        Experimental = lib.mkDefault "true";
        KernelExperimental = lib.mkDefault "true";
      };
    };
  };

  # Blueman provides a GUI + tray applet (uses NetworkManager-ish UX for BT)
  services.blueman.enable = lib.mkDefault true;

  # Some DEs need this for tray/autostart entries
  xdg.autostart.enable = lib.mkDefault true;

  # Convenience tools (bluetoothctl is in bluez, but extra tools help)
  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
  ];

  #### Nintendo / gamepad kernel support ####
  # Usually auto-loaded, but explicitly enabling improves reliability on NixOS.
  boot.kernelModules = lib.mkDefault [
    "uhid"
    "hid-nintendo"
  ];

  # Realtime scheduling for PipeWire (recommended)
  security.rtkit.enable = lib.mkDefault true;

  #### Firmware ####
  hardware.enableRedistributableFirmware = lib.mkDefault true;
}
