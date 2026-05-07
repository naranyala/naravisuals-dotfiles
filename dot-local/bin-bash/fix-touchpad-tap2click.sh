#!/bin/bash

# Fix Elan touchpad: enable tap-to-click and natural scrolling

echo "🔍 Detecting touchpad device..."
TOUCHPAD_ID=$(xinput list | grep -i 'touchpad' | grep -i 'Elan' | sed -n 's/.*id=\([0-9]*\).*/\1/p')

if [ -z "$TOUCHPAD_ID" ]; then
    echo "❌ Elan touchpad not found. Trying generic touchpad..."
    TOUCHPAD_ID=$(xinput list | grep -i 'touchpad' | sed -n 's/.*id=\([0-9]*\).*/\1/p')
fi

if [ -z "$TOUCHPAD_ID" ]; then
    echo "❌ No touchpad device detected. Exiting."
    exit 1
fi

echo "✅ Touchpad detected with ID: $TOUCHPAD_ID"

echo "⚙️ Enabling tap-to-click..."
xinput set-prop "$TOUCHPAD_ID" "libinput Tapping Enabled" 1

echo "⚙️ Enabling natural scrolling..."
xinput set-prop "$TOUCHPAD_ID" "libinput Natural Scrolling Enabled" 1

echo "✅ Settings applied for current session."

# Optional: Make it persistent across reboots
CONFIG_DIR="/etc/X11/xorg.conf.d"
CONFIG_FILE="$CONFIG_DIR/40-libinput.conf"

if [ ! -d "$CONFIG_DIR" ]; then
    echo "📁 Creating config directory: $CONFIG_DIR"
    sudo mkdir -p "$CONFIG_DIR"
fi

echo "📝 Writing persistent config to $CONFIG_FILE"
sudo tee "$CONFIG_FILE" > /dev/null <<EOF
Section "InputClass"
    Identifier "Elan Touchpad"
    MatchIsTouchpad "on"
    MatchProduct "Elan"
    Driver "libinput"
    Option "Tapping" "on"
    Option "NaturalScrolling" "true"
EndSection
EOF

echo "✅ Persistent config saved."
echo "🔁 Please reboot or log out and back in for changes to take effect."

