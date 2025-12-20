#!/bin/bash
# Connect to Spark Audio 40 and set as default sink

DEVICE_NAME="Spark Audio 40"
LOG_FILE="/tmp/spark_connect.log"

# Log start
echo "[$(date)] Starting connection script for $DEVICE_NAME" > "$LOG_FILE"

# Find MAC address from paired devices
# grep -i for case insensitivity
MAC=$(bluetoothctl devices | grep -i "$DEVICE_NAME" | head -n 1 | awk '{print $2}')

if [ -z "$MAC" ]; then
    echo "Device not found in paired list." >> "$LOG_FILE"
    notify-send "Spark Audio" "Device '$DEVICE_NAME' not found in paired devices."
    exit 1
fi

echo "Found MAC: $MAC" >> "$LOG_FILE"

# Attempt to disconnect first to ensure clean state (optional, but can help)
# bluetoothctl disconnect "$MAC"
# sleep 1

# Connect
echo "Connecting to $MAC..." >> "$LOG_FILE"
bluetoothctl connect "$MAC" >> "$LOG_FILE" 2>&1

# Wait for sink to appear in PulseAudio/PipeWire
MAX_RETRIES=15
i=0
# Convert MAC to PulseAudio format (xx_xx_xx_xx_xx_xx)
MAC_UNDERSCORE=$(echo "$MAC" | tr ':' '_')
# Common prefix for bluez sinks. grep matches substring so partial is okay.
SINK_SEARCH="bluez_output.$MAC_UNDERSCORE" 

while [ $i -lt $MAX_RETRIES ]; do
    # List sinks and look for our device
    SINK_NAME=$(pactl list short sinks | grep "$SINK_SEARCH" | awk '{print $2}')
    
    if [ -n "$SINK_NAME" ]; then
        echo "Found sink: $SINK_NAME" >> "$LOG_FILE"
        
        # Set as default sink
        pactl set-default-sink "$SINK_NAME"
        
        # Verify
        CURRENT_DEFAULT=$(pactl get-default-sink)
        if [ "$CURRENT_DEFAULT" == "$SINK_NAME" ]; then
            echo "Successfully set as default sink." >> "$LOG_FILE"
            notify-send "Spark Audio" "Connected and set as default."
            exit 0
        else
            echo "Failed to set default sink (Current: $CURRENT_DEFAULT)" >> "$LOG_FILE"
        fi
    fi
    
    echo "Sink not ready, waiting... ($i/$MAX_RETRIES)" >> "$LOG_FILE"
    sleep 2
    ((i++))
done

echo "Timed out waiting for sink." >> "$LOG_FILE"
notify-send "Spark Audio" "Failed to set audio output (Timeout)."
exit 1
