#!/usr/bin/env bash
# full-gnome-install.sh
# Installs the complete GNOME desktop environment and GDM across major distros.

set -e

echo "=== Detecting package manager ==="
if command -v apt >/dev/null 2>&1; then
    PM="apt"
elif command -v dnf5 >/dev/null 2>&1; then
    PM="dnf5"
elif command -v dnf >/dev/null 2>&1; then
    PM="dnf"
elif command -v yum >/dev/null 2>&1; then
    PM="yum"
elif command -v pacman >/dev/null 2>&1; then
    PM="pacman"
else
    echo "❌ Unsupported package manager."
    exit 1
fi

echo "=== Installing full GNOME and GDM ==="
case "$PM" in
    apt)
        sudo apt update
        # 'gnome' meta-package = full GNOME desktop + apps
        sudo apt install -y gnome gdm3
        ;;
    dnf5)
        # Fedora/RHEL with dnf5
        sudo dnf5 install -y @gnome-desktop gdm
        ;;
    dnf)
        # Fedora/RHEL with dnf4
        sudo dnf groupinstall -y "GNOME Desktop Environment"
        sudo dnf install -y gdm
        ;;
    yum)
        # Older RHEL/CentOS
        sudo yum groupinstall -y "GNOME Desktop Environment"
        sudo yum install -y gdm
        ;;
    pacman)
        # Arch Linux full GNOME + extra apps
        sudo pacman -Syu --noconfirm gnome gnome-extra gdm
        ;;
esac

echo "=== Enabling GDM and graphical target ==="
sudo systemctl disable lightdm sddm lxdm 2>/dev/null || true
sudo systemctl enable gdm
sudo systemctl set-default graphical.target

echo "✅ Full GNOME desktop with apps installed."
echo "🔄 Please reboot to start GNOME."

