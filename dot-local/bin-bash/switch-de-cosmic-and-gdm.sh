#!/usr/bin/env bash
# install-cosmic.sh
# Installs System76 COSMIC desktop on Fedora-based or Arch-based systems.

set -e

echo "=== Detecting distribution type ==="
if command -v dnf5 >/dev/null 2>&1; then
    DISTRO="fedora-dnf5"
elif command -v dnf >/dev/null 2>&1; then
    DISTRO="fedora-dnf4"
elif command -v pacman >/dev/null 2>&1; then
    DISTRO="arch"
else
    echo "❌ This script supports only Fedora-based (dnf/dnf5) and Arch-based (pacman) systems."
    exit 1
fi

case "$DISTRO" in
    fedora-dnf5)
        echo "=== Installing COSMIC on Fedora (dnf5) ==="
        sudo dnf5 install -y 'dnf5-command(copr)' || true
        sudo dnf5 copr enable -y ryanabx/cosmic-epoch
        sudo dnf5 install -y cosmic-desktop gdm
        ;;
    fedora-dnf4)
        echo "=== Installing COSMIC on Fedora (dnf4) ==="
        sudo dnf install -y dnf-plugins-core
        sudo dnf copr enable ryanabx/cosmic-epoch
        sudo dnf install -y cosmic-desktop gdm
        ;;
    arch)
        echo "=== Installing COSMIC on Arch ==="
        # Try official repo first
        if sudo pacman -Si cosmic >/dev/null 2>&1; then
            sudo pacman -Syu --noconfirm cosmic gdm
        else
            echo "⚠ COSMIC not in official repos, installing from AUR (requires yay)"
            if ! command -v yay >/dev/null 2>&1; then
                echo "❌ 'yay' AUR helper not found. Install it first."
                exit 1
            fi
            yay -S cosmic gdm
        fi
        ;;
esac

echo "=== Enabling GDM and graphical target ==="
sudo systemctl disable lightdm sddm lxdm 2>/dev/null || true
sudo systemctl enable gdm
sudo systemctl set-default graphical.target

echo "✅ COSMIC desktop installed."
echo "🔄 Reboot, then select 'COSMIC' from the session menu in GDM."

