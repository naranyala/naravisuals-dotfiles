#!/usr/bin/env bash
set -euo pipefail

trap 'echo "❌ Error occurred at line $LINENO"; exit 1' ERR

# Detect package manager
if command -v apt >/dev/null 2>&1; then
    PKG_MANAGER="apt"
    UPDATE_CMD="sudo apt update"
    INSTALL_CMD="sudo apt install -y"
    LOCK_FILE="/var/lib/dpkg/lock"
    LOCK_FRONTEND="/var/lib/dpkg/lock-frontend"
elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
    UPDATE_CMD="sudo dnf makecache"
    INSTALL_CMD="sudo dnf install -y"
    LOCK_FILE="/var/run/yum.pid"
else
    echo "❌ No supported package manager found (apt or dnf)."
    exit 1
fi

echo "✅ Using $PKG_MANAGER package manager..."

# Unified package list
PACKAGES=(
    btop neovim fastfetch bat git
    kitty tmux
    gcc g++ make cmake
    pkg-config
    curl wget htop tree
    unzip zip tar
    python3 python3-pip
    nodejs npm
    openssl
    blender inkscape ncdu 
    kdenlive vlc
    ntfsfix ntfs-3g
)

# Function to clear stale locks
clear_locks() {
    echo "🔍 Checking for stale locks..."
    if [ "$PKG_MANAGER" = "apt" ]; then
        for lock in "$LOCK_FILE" "$LOCK_FRONTEND"; do
            if sudo fuser "$lock" >/dev/null 2>&1; then
                echo "⚠️ Lock detected on $lock, killing process..."
                sudo fuser -k "$lock" || true
            fi
            sudo rm -f "$lock" || true
        done
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        if [ -f "$LOCK_FILE" ]; then
            PID=$(cat "$LOCK_FILE")
            if ps -p "$PID" >/dev/null 2>&1; then
                echo "⚠️ Killing conflicting dnf process (PID $PID)..."
                sudo kill -9 "$PID" || true
            fi
            sudo rm -f "$LOCK_FILE" || true
        fi
    fi
}

# Run installer
install_packages() {
    clear_locks
    echo "🔄 Updating package index..."
    $UPDATE_CMD

    echo "📦 Bulk installing..."
    if ! $INSTALL_CMD "${PACKAGES[@]}"; then
        echo "⚠️ Bulk install failed, retrying individually..."
        for pkg in "${PACKAGES[@]}"; do
            clear_locks
            $INSTALL_CMD "$pkg" || echo "❌ Failed to install $pkg"
        done
    fi
}

install_packages
echo "🎉 Installation complete!"

