#!/usr/bin/env bash

## system-programming.sh

set -euo pipefail


# Trap errors
trap 'echo "❌ Error occurred at line $LINENO"; exit 1' ERR

# Detect package manager
if command -v apt >/dev/null 2>&1; then
    PKG_MANAGER="apt"
elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
else
    echo "❌ No supported package manager found (apt or dnf)."
    exit 1
fi

echo "✅ Using $PKG_MANAGER package manager..."

# Function to install packages with fallback
install_packages() {
    local packages=("$@")
    if [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt update || { echo "⚠️ apt update failed, retrying..."; sleep 2; sudo apt update; }
        sudo apt install -y "${packages[@]}" || {
            echo "⚠️ Some packages failed to install with apt. Trying individually..."
            for pkg in "${packages[@]}"; do
                sudo apt install -y "$pkg" || echo "❌ Failed to install $pkg"
            done
        }
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf makecache || { echo "⚠️ dnf makecache failed, retrying..."; sleep 2; sudo dnf makecache; }
        sudo dnf install -y "${packages[@]}" || {
            echo "⚠️ Some packages failed to install with dnf. Trying individually..."
            for pkg in "${packages[@]}"; do
                sudo dnf install -y "$pkg" || echo "❌ Failed to install $pkg"
            done
        }
    fi
}

# Common development packages
COMMON_PACKAGES=(
    gcc g++ make cmake
    pkg-config
    curl wget git
)

# Libraries
LIBRARIES_APT=(
    build-essential
    libssl-dev zlib1g-dev libffi-dev
    libncurses5-dev libncursesw5-dev
    libreadline-dev libsqlite3-dev
    libgdbm-dev libnss3-dev libbz2-dev
)

LIBRARIES_DNF=(
    @development-tools
    openssl-devel zlib-devel libffi-devel
    ncurses-devel readline-devel sqlite-devel
    gdbm-devel nss-devel bzip2 bzip2-devel
)

# Install based on package manager
if [ "$PKG_MANAGER" = "apt" ]; then
    install_packages "${COMMON_PACKAGES[@]}" "${LIBRARIES_APT[@]}"
elif [ "$PKG_MANAGER" = "dnf" ]; then
    install_packages "${COMMON_PACKAGES[@]}" "${LIBRARIES_DNF[@]}"
fi

echo "🎉 Installation complete!"

