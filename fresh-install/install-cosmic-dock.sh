#!/bin/bash
set -e

# Script to download and build COSMIC Dock manually
# Supports apt (Debian/Ubuntu/Pop!_OS) and dnf (Fedora/RHEL)

# Step 0: Remove old cosmic-dock directory if it exists
if [ -d "cosmic-dock" ]; then
    echo "Removing existing cosmic-dock directory..."
    rm -rf cosmic-dock
fi

# Step 1: Detect package manager
if command -v apt >/dev/null; then
    PKG_MANAGER="apt"
elif command -v dnf >/dev/null; then
    PKG_MANAGER="dnf"
else
    echo "Error: Neither apt nor dnf found. Please install dependencies manually."
    exit 1
fi

# Step 2: Install dependencies
echo "Installing dependencies using $PKG_MANAGER..."

if [ "$PKG_MANAGER" = "apt" ]; then
    sudo apt update
    sudo apt install -y build-essential git cargo rustc libgtk-3-dev \
        libglib2.0-dev libx11-dev libxrandr-dev libxdo-dev
elif [ "$PKG_MANAGER" = "dnf" ]; then
    sudo dnf install -y gcc gcc-c++ make git cargo rust \
        gtk3-devel glib2-devel libX11-devel libXrandr-devel xdotool-devel
fi

# Step 3: Clone the repository (shallow clone)
echo "Cloning COSMIC Dock repository..."
git clone --depth=1 https://github.com/pop-os/cosmic-dock.git
cd cosmic-dock

# Step 4: Build with Cargo
echo "Building COSMIC Dock..."
cargo build --release

# Step 5: Install binary
echo "Installing COSMIC Dock..."
sudo install -Dm755 target/release/cosmic-dock /usr/local/bin/cosmic-dock

echo "COSMIC Dock build and installation complete!"

