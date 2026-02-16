#!/bin/bash
# install_webkitgtk_dev.sh
# Script to install WebKit2GTK and related packages for desktop app development on Arch Linux

set -e

echo "Updating package database..."
sudo pacman -Sy

echo "Installing core development tools..."
sudo pacman -S --noconfirm base-devel git

echo "Installing GTK libraries..."
sudo pacman -S --noconfirm gtk3 gtk4 glib2

echo "Installing WebKit2GTK..."
sudo pacman -S --noconfirm webkit2gtk

echo "Installing common development dependencies..."
sudo pacman -S --noconfirm \
    gobject-introspection \
    libxslt \
    libsoup \
    cairo \
    pango \
    vala \
    meson \
    cmake \
    ninja

echo "All packages installed successfully!"

