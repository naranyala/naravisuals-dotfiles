#!/bin/bash
set -e

# Script to download and build Latte Dock manually
# Supports apt (Debian/Ubuntu) and dnf (Fedora/RHEL)

# Step 0: Remove old latte-dock directory if it exists
if [ -d "latte-dock" ]; then
    echo "Removing existing latte-dock directory..."
    rm -rf latte-dock
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
    sudo apt install -y build-essential cmake extra-cmake-modules \
        qtbase5-dev qtdeclarative5-dev qtquickcontrols2-5-dev \
        libkf5plasma-dev libkf5activities-dev libkf5xmlgui-dev \
        libkf5wayland-dev libkf5screen-dev libkf5globalaccel-dev \
        libkf5crash-dev libkf5package-dev libkf5i18n-dev \
        libkf5notifications-dev libkf5config-dev libkf5coreaddons-dev \
        libkf5windowsystem-dev libkf5kio-dev libkf5service-dev \
        libkf5iconthemes-dev libkf5archive-dev libkf5doctools-dev \
        libkf5declarative-dev kirigami2-dev libkf5newstuff-dev \
        plasma-wayland-protocols plasma-workspace-dev git
elif [ "$PKG_MANAGER" = "dnf" ]; then
    sudo dnf install -y gcc gcc-c++ make cmake extra-cmake-modules \
        qt5-qtbase-devel qt5-qtdeclarative-devel qt5-qtquickcontrols2-devel \
        kf5-plasma-devel kf5-activities-devel kf5-xmlgui-devel \
        kf5-wayland-devel kf5-screen-devel kf5-globalaccel-devel \
        kf5-crash-devel kf5-package-devel kf5-i18n-devel \
        kf5-notifications-devel kf5-config-devel kf5-coreaddons-devel \
        kf5-windowsystem-devel kf5-kio-devel kf5-service-devel \
        kf5-kiconthemes-devel kf5-archive-devel kf5-doctools-devel \
        kf5-kdeclarative-devel kirigami2-devel kf5-knewstuff-devel \
        plasma-wayland-protocols-devel plasma-workspace-devel git
fi

# Step 3: Clone the repository (shallow clone)
echo "Cloning Latte Dock repository..."
git clone --depth=1 https://github.com/KDE/latte-dock.git
cd latte-dock

# Step 4: Create build directory
echo "Creating build directory..."
mkdir -p build
cd build

# Step 5: Run CMake (force Qt5)
echo "Configuring build with CMake..."
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DQT_MAJOR_VERSION=5

# Step 6: Compile
echo "Compiling Latte Dock..."
make -j$(nproc)

# Step 7: Install
echo "Installing Latte Dock..."
sudo make install

echo "Latte Dock build and installation complete!"

