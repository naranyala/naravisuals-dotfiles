#!/bin/bash

# KDE Plasma Wayland: Enable tap-to-click and natural scrolling for Elan touchpad

echo "🔍 Checking session type..."
if [ "$XDG_SESSION_TYPE" != "wayland" ]; then
    echo "❌ This script is intended for KDE Plasma running on Wayland."
    exit 1
fi

echo "✅ Wayland session detected."

echo "⚙️ Applying touchpad settings using KDE configuration..."

# Enable tap-to-click
kwriteconfig5 --file kcm_touchpadrc --group Touchpad --key TapToClick true

# Enable natural scrolling
kwriteconfig5 --file kcm_touchpadrc --group Touchpad --key NaturalScroll true

# Optional: Adjust sensitivity (1–10)
kwriteconfig5 --file kcm_touchpadrc --group Touchpad --key Sensitivity 5

# Optional: Set acceleration profile
kwriteconfig5 --file kcm_touchpadrc --group Touchpad --key AccelProfile adaptive

# Reload KWin settings
qdbus org.kde.KWin /KWin reconfigure

echo "✅ Touchpad settings applied for KDE Plasma Wayland."

# Optional: Create autostart entry for persistence
AUTOSTART_DIR="$HOME/.config/autostart"
AUTOSTART_FILE="$AUTOSTART_DIR/touchpad-fix.desktop"

if [ ! -d "$AUTOSTART_DIR" ]; then
    echo "📁 Creating autostart directory..."
    mkdir -p "$AUTOSTART_DIR"
fi

echo "📝 Writing autostart config to $AUTOSTART_FILE"
cat > "$AUTOSTART_FILE" <<EOF
[Desktop Entry]
Type=Application
Exec=bash -c "kwriteconfig5 --file kcm_touchpadrc --group Touchpad --key TapToClick true && kwriteconfig5 --file kcm_touchpadrc --group Touchpad --key NaturalScroll true && kwriteconfig5 --file kcm_touchpadrc --group Touchpad --key Sensitivity 5 && kwriteconfig5 --file kcm_touchpadrc --group Touchpad --key AccelProfile adaptive && qdbus org.kde.KWin /KWin reconfigure"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Touchpad Fix
EOF

echo "✅ Autostart entry created. Settings will apply at login."
echo "🔁 You may need to log out and back in for full effect."
