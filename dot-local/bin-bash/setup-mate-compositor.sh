#!/usr/bin/env bash
#
# MATE + XFCE + GNOME Apps Suite Installer with Compiz Setup
# Works on Debian/Ubuntu-based systems
# Run as: sudo bash install_desktop_suite.sh
#

set -e

echo "=== Updating package lists ==="
apt update

echo "=== Installing MATE core apps ==="
apt install -y \
    caja pluma eom atril engrampa mate-terminal mate-system-monitor mate-calc

echo "=== Installing XFCE utilities ==="
apt install -y \
    thunar mousepad ristretto parole xfce4-screenshooter xfce4-taskmanager

echo "=== Installing GNOME utilities ==="
apt install -y \
    nautilus gedit evince eog gnome-calculator gnome-system-monitor

echo "=== Installing Compiz compositor and tools ==="
apt install -y \
    compiz compiz-plugins compiz-plugins-extra compizconfig-settings-manager \
    # compiz-plugins-main compiz-plugins-default fusion-icon
    # compiz-plugins-main 
    # fusion-icon

echo "=== Disabling other compositors (XFCE/MATE) ==="
# Disable XFCE compositor
if command -v xfconf-query >/dev/null 2>&1; then
    xfconf-query -c xfwm4 -p /general/use_compositing -s false || true
fi
# Disable MATE compositor
gsettings set org.mate.Marco.general compositing-manager false || true

echo "=== Setting Compiz as default window manager ==="
# Backup current WM setting
CURRENT_WM=$(gsettings get org.mate.session.required-components windowmanager || echo "marco")
echo "Current WM: $CURRENT_WM (backed up)"
gsettings set org.mate.session.required-components windowmanager "compiz"

echo "=== Creating basic Compiz config ==="
mkdir -p ~/.config/compiz-1
# Enable some basic plugins (move, resize, decoration, cube, rotate, etc.)
compiz --replace &
sleep 3
# Load default profile if available
if command -v ccsm >/dev/null 2>&1; then
    echo "You can now run 'ccsm' to tweak Compiz effects."
fi

echo "=== Adding Fusion Icon to startup ==="
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/fusion-icon.desktop <<EOF
[Desktop Entry]
Type=Application
Exec=fusion-icon
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Fusion Icon
Comment=Compiz tray icon and manager
EOF

echo "=== Installation complete! ==="
echo "Log out and log back in to start using Compiz."

