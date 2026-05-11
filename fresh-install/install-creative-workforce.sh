#!/bin/bash

# Creative Workflow Installer
# Installs popular open-source creative applications and utilities

# Detect package manager
if command -v apt >/dev/null; then
    PKG_MANAGER="apt"
    INSTALL_CMD="sudo apt install -y"
elif command -v dnf >/dev/null; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="sudo dnf install -y"
elif command -v pacman >/dev/null; then
    PKG_MANAGER="pacman"
    INSTALL_CMD="sudo pacman -S --noconfirm"
else
    echo "Unsupported package manager. Please install manually."
    exit 1
fi

echo "Using $PKG_MANAGER to install creative apps..."

# Update repositories
case $PKG_MANAGER in
    apt) sudo apt update ;;
    dnf) sudo dnf check-update ;;
    pacman) sudo pacman -Sy ;;
esac

# List of creative apps (GUI + CLI utilities)
apps=(
    inkscape        # vector graphics
    blender         # 3D modeling/animation
    krita           # digital painting
    kdenlive        # video editing
    obs-studio      # streaming/recording
    audacity        # audio editing
    scribus         # desktop publishing
    ffmpeg          # CLI video/audio converter
    imagemagick     # CLI image manipulation
    handbrake       # video transcoder
    darktable       # photo workflow
    rawtherapee     # RAW photo editor
    vlc             # versatile media player
    exiftool        # metadata editing
    pandoc          # document converter
    neofetch        # system info (handy for creatives)
    htop            # process monitor
)

# Install apps
for app in "${apps[@]}"; do
    echo "Installing $app..."
    $INSTALL_CMD "$app"
done

echo "✅ Installation complete! Your expanded creative toolkit is ready."

