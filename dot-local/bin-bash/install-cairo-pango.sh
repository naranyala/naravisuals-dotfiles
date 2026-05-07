#!/usr/bin/env bash
# install-graphics-libs.sh
# Script to install Cairo, Pango, and related graphics/text libraries on Fedora

set -e

echo "Updating package metadata..."
sudo dnf -y update

echo "Installing core graphics libraries..."
sudo dnf -y install \
    cairo cairo-devel \
    pango pango-devel \
    harfbuzz harfbuzz-devel \
    freetype freetype-devel \
    fontconfig fontconfig-devel \
    glib2 glib2-devel

echo "Installing optional GUI libraries (often needed)..."
sudo dnf -y install \
    gtk3 gtk3-devel \
    gdk-pixbuf2 gdk-pixbuf2-devel

echo "All requested libraries installed successfully!"

