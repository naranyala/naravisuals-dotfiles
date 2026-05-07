#!/usr/bin/env bash
set -euo pipefail

# Packages to install
PACKAGES=(curl git unzip xz-utils zip libglu1-mesa)

# Detect package manager
if command -v apt-get &>/dev/null; then
    sudo apt-get update -y
    sudo apt-get upgrade -y
    sudo apt-get install -y "${PACKAGES[@]}"

elif command -v dnf &>/dev/null; then
    sudo dnf upgrade -y
    sudo dnf install -y curl git unzip xz zip mesa-libGLU

elif command -v yum &>/dev/null; then
    sudo yum update -y
    sudo yum install -y curl git unzip xz zip mesa-libGLU

elif command -v zypper &>/dev/null; then
    sudo zypper refresh
    sudo zypper update -y
    sudo zypper install -y curl git unzip xz zip Mesa-libGLU1

elif command -v pacman &>/dev/null; then
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm curl git unzip xz zip glu

else
    echo "❌ Unsupported package manager. Please install manually: ${PACKAGES[*]}"
    exit 1
fi

echo "✅ Installation complete."

