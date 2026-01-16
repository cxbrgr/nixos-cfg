{ 
  lib,
  pkgs,
  usr,
  ...
}:
{
  hardware.bluetooth = {
    enable = lib.mkDefault true;
    powerOnBoot = lib.mkDefault true;

    # BlueZ input plugin config - enables HID devices as joysticks
    input = {
      General = {
        UserspaceHID = true;
        ClassicBondedOnly = false;  # Allow non-bonded HID devices
      };
    };

    settings = {
      Policy = {
        # Automatically enables adapters when present
        AutoEnable = lib.mkDefault true;
      };

      General = {
        # Helps with game controllers on some setups
        ControllerMode = lib.mkDefault "dual";
        # "true" = faster reconnects but more power usage
        FastConnectable = lib.mkDefault true;
        # Newer BlueZ features; generally fine on modern kernels
        Experimental = lib.mkDefault true;
        KernelExperimental = lib.mkDefault true;
        # Required for HID reconnection
        JustWorksRepairing = lib.mkDefault "always";
      };
    };
  };

  # xpadneo - Xbox/8Bitdo Bluetooth controller driver
  hardware.xpadneo.enable = lib.mkDefault true;

  # Required for Steam Input / controller input access
  hardware.uinput.enable = lib.mkDefault true;

  # Blueman provides a GUI + tray applet (uses NetworkManager-ish UX for BT)
  services.blueman.enable = lib.mkDefault true;

  # Some DEs need this for tray/autostart entries
  xdg.autostart.enable = lib.mkDefault true;
  # Realtime scheduling for PipeWire (recommended)
  security.rtkit.enable = lib.mkDefault true;

  # make sure all firmware is enabled
  hardware.enableAllFirmware = lib.mkDefault true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # enable forwarding pause/play/.. buttons for bluetooth headsets to media players
  home-manager.users.${usr.name}.services.mpris-proxy.enable = true;

  # Add user to input group for joystick/controller access
  users.users.${usr.name}.extraGroups = lib.mkAfter [ "input" ];

  # Convenience tools (bluetoothctl is in bluez, but extra tools help)
  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
  ];

  #### Nintendo / gamepad kernel support ####
  # Usually auto-loaded, but explicitly enabling improves reliability on NixOS.
  boot.kernelModules = lib.mkDefault [
    "uhid"
    "uinput"       # Required for Steam Input / controller remapping
    "hid-nintendo"
    "hid-generic"  # Fallback for controllers without dedicated drivers
  ];
}