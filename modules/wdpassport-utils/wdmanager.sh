#!/bin/bash
# WD Passport Manager - GUI wrapper for unlocking WD drives
# This script is called by the wdmanager NixOS wrapper

# These paths are substituted by Nix at build time
ZENITY="@zenity@"
WDPASS="@wdpass@"

# Check if any WD device is connected
DEVICE=$($WDPASS -l 2>/dev/null | grep "Device:" | head -1 | awk '{print $2}')

if [ -z "$DEVICE" ]; then
  $ZENITY --error --title="WD Manager" --text="No Western Digital Passport drive detected.\n\nPlease connect your drive and try again."
  exit 1
fi

# Get device info
MODEL=$($WDPASS -l 2>/dev/null | grep "Model:" | head -1 | awk '{print $2}')
SIZE=$($WDPASS -l 2>/dev/null | grep "Size:" | head -1 | awk '{print $2, $3}')

# Get sudo password to check status
SUDO_PASSWORD=$($ZENITY --password --title="WD Manager" --text="Enter your sudo password:")
if [ -z "$SUDO_PASSWORD" ]; then
  exit 0
fi

# Check current status
STATUS=$(echo "$SUDO_PASSWORD" | sudo -S $WDPASS -d "$DEVICE" 2>/dev/null | grep "Security status:" | awk -F': ' '{print $2}')

if [ -z "$STATUS" ]; then
  $ZENITY --error --title="WD Manager" --text="Failed to get drive status.\n\nIncorrect password or permission denied."
  exit 1
fi

if [ "$STATUS" = "Locked" ]; then
  # Ask for WD drive password
  WD_PASSWORD=$($ZENITY --password --title="WD Manager - Unlock" --text="Enter password for $MODEL ($SIZE):")
  
  if [ -z "$WD_PASSWORD" ]; then
    exit 0
  fi
  
  # Unlock the drive
  TMPSCRIPT=$(mktemp)
  cat > "$TMPSCRIPT" << 'INNEREOF'
#!/bin/bash
WDPASS="$1"
DEVICE="$2"
WD_PASSWORD="$3"
echo "$WD_PASSWORD" | "$WDPASS" -d "$DEVICE" -u 2>&1
INNEREOF
  chmod +x "$TMPSCRIPT"
  
  RESULT=$(echo "$SUDO_PASSWORD" | sudo -S "$TMPSCRIPT" "$WDPASS" "$DEVICE" "$WD_PASSWORD" 2>&1)
  rm -f "$TMPSCRIPT"
  
  if echo "$RESULT" | grep -q "Device unlocked"; then
    # Rescan device so it appears in file manager
    echo "$SUDO_PASSWORD" | sudo -S $WDPASS -d "$DEVICE" -m >/dev/null 2>&1
    $ZENITY --info --title="WD Manager" --text="Drive unlocked!\n\nClick 'My Passport' in the file manager to mount it."
  else
    $ZENITY --error --title="WD Manager" --text="Failed to unlock drive.\n\nWrong password?"
  fi
  
elif [ "$STATUS" = "Unlocked" ] || [ "$STATUS" = "No lock" ]; then
  $ZENITY --info --title="WD Manager" --text="Drive is already unlocked.\n\nClick 'My Passport' in the file manager to mount it."
else
  $ZENITY --error --title="WD Manager" --text="Unknown drive status: $STATUS"
fi
