#!/usr/bin/env bash
# Robust installer for paru on Arch Linux
# Includes error handling, rollback, and variant logic

set -euo pipefail

# --- CONFIG ---
PKG_NAME="paru"
BUILD_DIR="$HOME/.cache/$PKG_NAME-build"

# --- FUNCTIONS ---
error_exit() {
    echo "❌ Error: $1" >&2
    cleanup
    exit 1
}

cleanup() {
    echo "🧹 Cleaning up..."
    rm -rf "$BUILD_DIR"
}

check_prereqs() {
    echo "🔍 Checking prerequisites..."
    for pkg in git base-devel; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            echo "📦 Installing missing dependency: $pkg"
            sudo pacman -S --needed --noconfirm "$pkg" || error_exit "Failed to install $pkg"
        fi
    done
}

install_from_source() {
    echo "⚙️ Installing $PKG_NAME from source..."
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    git clone https://aur.archlinux.org/$PKG_NAME.git || error_exit "Failed to clone AUR repo"
    cd "$PKG_NAME"
    makepkg -si --noconfirm || error_exit "makepkg failed"
}

install_variant() {
    if pacman -Si "$PKG_NAME" &>/dev/null; then
        echo "📦 Installing $PKG_NAME via pacman..."
        sudo pacman -S --needed --noconfirm "$PKG_NAME" || error_exit "pacman install failed"
    else
        install_from_source
    fi
}

# --- MAIN ---
trap cleanup EXIT
check_prereqs
install_variant
echo "✅ $PKG_NAME installation complete!"

