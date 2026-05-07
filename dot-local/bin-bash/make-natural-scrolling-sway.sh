#!/bin/bash

# Check if swaymsg is available
if ! command -v swaymsg &> /dev/null; then
    echo "Error: swaymsg not found. Please ensure Sway is installed."
    exit 1
fi

# Check if libinput is installed
if ! command -v libinput &> /dev/null; then
    echo "Error: libinput not found. Please install libinput (e.g., sudo apt install libinput-tools or sudo pacman -S libinput)."
    exit 1
fi

# Define the Sway config file path
CONFIG_FILE="$HOME/.config/sway/config"

# Ensure the config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Sway config file not found at $CONFIG_FILE"
    exit 1
fi

# Backup the original config file
cp "$CONFIG_FILE" "$CONFIG_FILE.bak_$(date +%F_%H%M%S)"
echo "Backed up config file to $CONFIG_FILE.bak_$(date +%F_%H%M%S)"

# Check libinput device detection
echo "Checking available input devices with libinput..."
libinput list-devices > /tmp/libinput_devices.txt
if grep -qi "touchpad\|pointer" /tmp/libinput_devices.txt; then
    echo "Touchpad or mouse devices detected by libinput:"
    grep -i "touchpad\|pointer" /tmp/libinput_devices.txt
else
    echo "No touchpad or mouse devices detected by libinput. Possible issues:"
    echo "1. Missing kernel drivers (e.g., i2c-hid for touchpads)."
    echo "2. Permissions issue (ensure user is in 'input' group)."
    echo "3. Run 'sudo libinput list-devices' to confirm kernel detection."
    echo "4. Check kernel modules (e.g., modprobe i2c-hid)."
    exit 1
fi

# Get input devices from swaymsg
INPUTS=$(swaymsg -t get_inputs | grep -E '"type":.*(touchpad|pointer)' | grep -oP '"identifier":\s*"\K[^"]+')

# Check if swaymsg detects any touchpad or pointer devices
if [ -z "$INPUTS" ]; then
    echo "Warning: swaymsg -t get_inputs did not detect touchpad or mouse devices."
    echo "Attempting to apply natural_scroll to all input devices using wildcard (*)."
    # Check if wildcard natural_scroll is already set
    if ! grep -q "input \"\*\".*natural_scroll enabled" "$CONFIG_FILE"; then
        echo -e "\ninput * {\n  natural_scroll enabled\n}" >> "$CONFIG_FILE"
        echo "Added natural_scroll enabled for all devices (*)"
    else
        echo "natural_scroll already enabled for all devices (*)"
    fi
    # Also try type:touchpad as a fallback
    if ! grep -q "input type:touchpad.*natural_scroll enabled" "$CONFIG_FILE"; then
        echo -e "\ninput type:touchpad {\n  natural_scroll enabled\n}" >> "$CONFIG_FILE"
        echo "Added natural_scroll enabled for type:touchpad"
    else
        echo "natural_scroll already enabled for type:touchpad"
    fi
else
    # Process each detected input device
    while IFS= read -r identifier; do
        # Escape special characters in identifier for sed/grep
        escaped_identifier=$(echo "$identifier" | sed 's/[\/&]/\\&/g')
        # Check if natural_scroll is already set for this device
        if ! grep -A 5 "input \"$escaped_identifier\"" "$CONFIG_FILE" | grep -q "natural_scroll enabled"; then
            sed -i "/input \"$escaped_identifier\"/a \ \ natural_scroll enabled" "$CONFIG_FILE"
            echo "Added natural_scroll enabled for $identifier"
        else
            echo "natural_scroll already enabled for $identifier"
        fi
    done <<< "$INPUTS"
fi

# Check seat configuration
echo "Checking seat configuration..."
SEATS=$(swaymsg -t get_seats)
if echo "$SEATS" | grep -q "seat0"; then
    echo "Devices attached to seat0:"
    echo "$SEATS" | grep -A 10 "seat0" | grep "Devices"
else
    echo "Warning: No seat0 detected. This may cause input issues."
    echo "Try attaching devices to seat0 with: swaymsg seat seat0 attach *"
fi

# Reload Sway configuration
swaymsg reload
echo "Sway configuration reloaded."

# Verify natural_scroll setting
echo "Verifying natural_scroll settings..."
swaymsg -t get_inputs | grep -E '"identifier"|"natural_scroll"'

# Additional troubleshooting suggestions
echo "If natural scrolling is still not working:"
echo "1. Check kernel modules: sudo modprobe i2c-hid"
echo "2. Verify user permissions: sudo usermod -aG input $USER"
echo "3. Test libinput directly: sudo libinput debug-events"
echo "4. Reboot to ensure kernel drivers are loaded."
echo "5. Check dmesg for errors: dmesg | grep -i input"

exit 0
