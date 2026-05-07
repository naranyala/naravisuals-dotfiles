#!/bin/bash
# Fix missing Wi-Fi icon in KDE Plasma on Fedora

echo "=== Checking NetworkManager service ==="
if ! systemctl is-active --quiet NetworkManager; then
    echo "Starting NetworkManager..."
    sudo systemctl enable --now NetworkManager
else
    echo "NetworkManager is running."
fi

echo "=== Ensuring plasma-nm package is installed ==="
if ! rpm -q plasma-nm >/dev/null 2>&1; then
    echo "Installing plasma-nm..."
    sudo dnf install -y plasma-nm
else
    echo "plasma-nm is already installed."
fi

echo "=== Restarting Plasma shell ==="
kquitapp5 plasmashell 2>/dev/null
kstart5 plasmashell &

echo "=== Resetting system tray configuration ==="
CONFIG_DIR="$HOME/.config"
PLASMA_CONFIG="$CONFIG_DIR/plasma-org.kde.plasma.desktop-appletsrc"

if [ -f "$PLASMA_CONFIG" ]; then
    cp "$PLASMA_CONFIG" "$PLASMA_CONFIG.bak"
    echo "Backup created at $PLASMA_CONFIG.bak"
    # Remove cached tray settings so Plasma regenerates them
    sed -i '/

\[Containments\]

/,/^

\[/ s/Networks/Networks\nShown=true/' "$PLASMA_CONFIG"
fi

echo "=== Forcing widget reload ==="
plasmapkg2 --list | grep -q org.kde.plasma.networkmanagement
if [ $? -eq 0 ]; then
    echo "Network widget found."
else
    echo "Adding Networks widget..."
    plasmapkg2 -i /usr/share/plasma/plasmoids/org.kde.plasma.networkmanagement
fi

echo "=== Done. Please log out and back in if the icon still does not appear. ==="
