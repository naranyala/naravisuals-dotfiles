#!/usr/bin/env bash
# install_steam_universal_pkgmgr.sh
# Installs Steam on systems with either apt (Debian/Ubuntu) or dnf (Fedora/RHEL)

set -e

echo "=== Universal Steam Installer (Package Manager Detection) ==="

# Detect package manager
if command -v apt >/dev/null 2>&1; then
    PKG_MGR="apt"
elif command -v dnf >/dev/null 2>&1; then
    PKG_MGR="dnf"
else
    echo "❌ No supported package manager found (apt or dnf)."
    exit 1
fi

# Debian/Ubuntu install
install_debian() {
    echo "[Debian/Ubuntu] Enabling 32-bit architecture..."
    sudo dpkg --add-architecture i386

    echo "[Debian/Ubuntu] Updating system..."
    sudo apt update && sudo apt upgrade -y

    echo "[Debian/Ubuntu] Installing Steam..."
    sudo apt install -y steam

    echo "✅ Steam installation complete on Debian/Ubuntu."
}

# Fedora/RHEL install
install_fedora() {
    echo "[Fedora/RHEL] Enabling RPM Fusion repositories..."
    sudo dnf install -y \
        https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    echo "[Fedora/RHEL] Updating system..."
    sudo dnf update -y

    echo "[Fedora/RHEL] Installing Steam..."
    sudo dnf install -y steam

    echo "✅ Steam installation complete on Fedora/RHEL."
}

# Run the right installer
case "$PKG_MGR" in
    apt) install_debian ;;
    dnf) install_fedora ;;
esac

echo "🎮 You can now launch Steam from your app menu or by running 'steam'."

