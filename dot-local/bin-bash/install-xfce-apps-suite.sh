#!/usr/bin/env bash
# XFCE Apps Installer for Fedora & Debian-based systems (No Desktop Environment)
# Run this script with sudo privileges

set -e

echo "🔧 Installing XFCE applications only..."

# Detect package manager
if command -v apt >/dev/null 2>&1; then
    PKG_MGR="apt"
elif command -v dnf >/dev/null 2>&1; then
    PKG_MGR="dnf"
else
    echo "❌ No supported package manager found (apt or dnf)."
    exit 1
fi

install_debian() {
    echo "[Debian/Ubuntu] Updating system..."
    sudo apt update && sudo apt upgrade -y

    echo "[Debian/Ubuntu] Installing XFCE core apps and utilities..."
    sudo apt install -y \
        xfce4-panel \
        xfce4-settings \
        xfce4-terminal \
        thunar \
        thunar-volman \
        xfce4-appfinder \
        xfce4-power-manager \
        xfce4-notifyd \
        xfce4-screenshooter \
        xfce4-taskmanager \
        xfce4-dict \
        ristretto \
        mousepad \
        parole \
        catfish \
        xfburn \
        gigolo \
        xfce4-whiskermenu-plugin \
        xfce4-weather-plugin \
        xfce4-pulseaudio-plugin \
        xfce4-goodies
}

install_fedora() {
    echo "[Fedora/RHEL] Updating system..."
    sudo dnf update -y

    echo "[Fedora/RHEL] Installing XFCE core apps and utilities..."
    sudo dnf install -y --skip-unavailable \
        xfce4-panel \
        xfce4-settings \
        xfce4-terminal \
        thunar \
        thunar-volman \
        xfce4-appfinder \
        xfce4-power-manager \
        xfce4-notifyd \
        xfce4-screenshooter \
        xfce4-taskmanager \
        xfce4-dict \
        ristretto \
        mousepad \
        parole \
        catfish \
        xfburn \
        gigolo \
        xfce4-whiskermenu-plugin \
        xfce4-weather-plugin \
        xfce4-pulseaudio-plugin \
        xfce4-goodies
}

case "$PKG_MGR" in
    apt) install_debian ;;
    dnf) install_fedora ;;
esac

echo "✅ XFCE apps installed successfully!"

