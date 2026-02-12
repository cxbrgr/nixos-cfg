# Virtual Machines (Quickemu / Quickgui)

This directory contains VM configurations managed by:
- [Quickemu](https://github.com/quickemu-project/quickemu) 
- [Quickgui](https://github.com/quickemu-project/quickgui)

## Directory Structure

```
virtualmachines/
├── conf/           # VM configuration files (.conf)
├── data/           # VM disk images, firmware, and runtime data
└── README.md
```

---

## Quickemu CLI Reference

All commands below should be run from the `conf/` directory.

### Starting & Stopping VMs

```bash
# Start a VM
quickemu --vm <name>.conf

# Start a VM in display mode (SDL, default)
quickemu --vm <name>.conf --display sdl

# Start a VM with SPICE display (remote-capable)
quickemu --vm <name>.conf --display spice

# Start a VM in headless mode (SSH only)
quickemu --vm <name>.conf --display none

# Kill a running VM
quickemu --vm <name>.conf --kill

# Check if a VM is running
quickemu --vm <name>.conf --status
```

### Snapshots

```bash
# Create a snapshot
quickemu --vm <name>.conf --snapshot create <snapshot-name>

# Restore a snapshot
quickemu --vm <name>.conf --snapshot apply <snapshot-name>

# Delete a snapshot
quickemu --vm <name>.conf --snapshot delete <snapshot-name>

# List snapshots
quickemu --vm <name>.conf --snapshot info
```

### SSH Access

```bash
# SSH into a running VM (uses port forwarding configured in .conf)
quickemu --vm <name>.conf --ssh
```

Port forwarding is on `localhost:22220` for macos-sequoia (see the `.sh` file for the exact port).

### USB Passthrough

```bash
# Attach a USB device to a running VM
quickemu --vm <name>.conf --usb VENDOR_ID:PRODUCT_ID
```

Find device IDs with `lsusb`.

### Screen Resolution (macOS)

```bash
# Set a specific resolution
quickemu --vm <name>.conf --width 1920 --height 1080
```

### Disk Management

```bash
# Resize a VM disk (e.g., to 256G)
qemu-img resize ../data/<name>/disk.qcow2 256G

# Get disk info
qemu-img info ../data/<name>/disk.qcow2

# Convert between formats
qemu-img convert -f qcow2 -O raw ../data/<name>/disk.qcow2 disk.raw
```

---

## Quickget CLI Reference

`quickget` downloads OS images and creates VM configurations.

```bash
# List all supported operating systems
quickget --list

# Show info about a specific OS
quickget --show <os>

# Download an OS and create a .conf
quickget <os> <release> [edition]
# Examples:
quickget ubuntu 24.04
quickget macos sequoia
quickget windows 11
quickget fedora 41

# Download only (no config creation)
quickget --download <os> <release> [edition]

# Create config for an existing image
quickget --create-config <os> /path/to/image.iso

# Open the homepage for an OS
quickget --open-homepage <os>
```

---

## QEMU Monitor (Advanced)

Each running VM exposes a QEMU monitor socket for advanced control:

```bash
# Connect to the QEMU monitor
socat - UNIX-CONNECT:../data/<name>/<name>-monitor.socket

# Useful monitor commands (once connected):
#   info status        - VM status
#   info snapshots     - List snapshots
#   info block         - Block device info
#   info network       - Network info
#   info usb           - USB device info
#   system_powerdown   - Send ACPI shutdown
#   quit               - Force quit VM
#   savevm <name>      - Save snapshot
#   loadvm <name>      - Load snapshot
#   device_add         - Hot-add device
#   device_del         - Hot-remove device
```

---

## Tips

- **Config files** use relative paths (`../data/...`), so always run quickemu from the `conf/` directory.
- **macOS VMs** require special firmware (OVMF) and OpenCore bootloader — these are managed automatically by quickget.
- **Shared folders**: macOS Sequoia is configured with a 9p share of your home directory, mountable inside the guest as `Public-{username}`.
- **Ports file**: Check `data/<name>/<name>.ports` for assigned SSH port forwarding.

---

## Troubleshooting

### MacOS

If you encounter issues with macOS VMs on macOS hosts getting stuck loading into the OS, try the following:

```
echo 1 > /sys/module/kvm/parameters/ignore_msrs
echo 0 > /sys/module/kvm/parameters/report_ignored_msrs
´´´
