# Bluetooth Controller Pairing Guide

Reference for pairing 8Bitdo SN30 Pro, Switch Pro Controller, and similar controllers with NixOS + Steam.

## Controller Modes

| Mode | Button Combo | Use Case |
|------|--------------|----------|
| **XInput (Windows)** | Start + X | **Linux/Steam** - Recommended for 8Bitdo |
| Switch | Start + Y | Nintendo Switch / hid-nintendo |
| Android | Start + B | Android/macOS |

> [!TIP]
> For Linux with Steam, use **XInput mode (Start + X)** for 8Bitdo controllers.
> For Switch Pro Controller, just use the sync button (no mode selection needed).

## Understanding Pairing vs Bonding

| State | Meaning |
|-------|---------|
| **Paired** | Initial handshake completed, devices recognized each other |
| **Bonded** | Encryption keys stored permanently for secure reconnection |

> [!IMPORTANT]
> **BlueZ rejects HID input from non-bonded devices.** If your controller shows `Paired: yes, Bonded: no`, it will connect at Bluetooth level but **won't create a joystick device** (`/dev/input/js*`).

### Symptoms of Bonding Issue
- Controller shows as connected in Blueman/bluetoothctl
- No `/dev/input/js*` device created
- Controller doesn't appear in Steam
- System logs show: `Rejected connection from !bonded device`

### How to Fix
Remove the device completely and re-pair while controller is in fresh pairing mode:
```bash
bluetoothctl disconnect <MAC>
bluetoothctl remove <MAC>
# Put controller in pairing mode, then:
bluetoothctl pair <MAC>
# Verify: must show "Bonded: yes"
```

## Quick Pairing Steps

### 1. Put Controller in Pairing Mode
```bash
# Turn off controller, then hold X + Start until LED blinks rapidly
```

### 2. Scan and Pair
```bash
# Scan for devices
bluetoothctl --timeout 10 scan on

# Find your controller MAC address
bluetoothctl devices | grep -i "8bit\|sn30"

# Pair (replace MAC with your controller's address)
bluetoothctl pair E4:17:D8:DF:AB:56

# Trust for auto-reconnect
bluetoothctl trust E4:17:D8:DF:AB:56

# Connect
bluetoothctl connect E4:17:D8:DF:AB:56
```

### 3. Verify
```bash
# Check device status (must show Bonded: yes)
bluetoothctl info E4:17:D8:DF:AB:56

# Verify joystick device created
ls -la /dev/input/js*

# Check input device registration
cat /proc/bus/input/devices | grep -A 10 "8Bitdo"
```

## Troubleshooting

### Controller Not Detected in Steam
Check if device is properly bonded:
```bash
bluetoothctl info <MAC> | grep -E "Paired|Bonded|Connected"
```

If `Bonded: no`, remove and re-pair:
```bash
bluetoothctl disconnect <MAC>
bluetoothctl remove <MAC>
# Put controller in pairing mode again, then repeat pairing steps
```

### Check BlueZ HID Connection Logs
```bash
sudo journalctl -u bluetooth.service -f
# Look for: "Rejected connection from !bonded device"
```

### No /dev/input/js* Device
Verify kernel modules loaded:
```bash
lsmod | grep -E "uhid|uinput|hid"
```

Check system messages:
```bash
sudo dmesg | grep -iE "8bit|hid|input" | tail -20
```

## Required NixOS Configuration

Key settings in `modules/bluetooth.nix`:
- `hardware.xpadneo.enable = true` - Xbox/8Bitdo driver
- `hardware.uinput.enable = true` - Input device support
- `hardware.bluetooth.input.General.UserspaceHID = true` - HID input plugin

Key settings in `modules/steam.nix`:
- `hardware.steam-hardware.enable = true`
- User in `input` group

## Useful Commands Reference

| Command | Purpose |
|---------|---------|
| `bluetoothctl devices` | List known devices |
| `bluetoothctl info <MAC>` | Device details |
| `bluetoothctl connect <MAC>` | Connect to device |
| `bluetoothctl disconnect <MAC>` | Disconnect device |
| `bluetoothctl remove <MAC>` | Forget device |
| `bluetoothctl trust <MAC>` | Enable auto-connect |
| `cat /proc/bus/input/devices` | List input devices |
| `ls /dev/input/js*` | List joystick devices |
