#!/bin/bash

set -e

echo "📦 Installing ONLYOFFICE Desktop Editors from AUR..."

# Step 1: Ensure base-devel and git are installed
echo "🔧 Installing required packages..."
sudo pacman -S --needed --noconfirm base-devel git

# Step 2: Clone the AUR repository
WORKDIR="$HOME/aur-build-onlyoffice"
echo "📁 Creating build directory at $WORKDIR..."
mkdir -p "$WORKDIR"
cd "$WORKDIR"

if [ -d "onlyoffice-bin" ]; then
    echo "🔄 Removing existing onlyoffice-bin directory..."
    rm -rf onlyoffice-bin
fi

echo "🌐 Cloning onlyoffice-bin from AUR..."
git clone https://aur.archlinux.org/onlyoffice-bin.git
cd onlyoffice-bin

# Step 3: Build and install the package (no sudo!)
echo "🛠️ Building and installing ONLYOFFICE..."
makepkg -si --noconfirm

echo "✅ ONLYOFFICE Desktop Editors installed successfully!"

