#!/usr/bin/env bash
# GTK3/GTK4 full setup script for Fedora Linux
# Installs runtime libraries, development headers, and common dependencies
# Uses --skip-unavailable to avoid errors if some packages are missing

set -e

echo "Updating system..."
sudo dnf -y update --skip-unavailable

echo "Installing GTK3 runtime and development packages..."
sudo dnf -y install --skip-unavailable \
    gtk3 \
    gtk3-devel \
    gtk3-doc \
    gtk3-tools

echo "Installing GTK4 runtime and development packages..."
sudo dnf -y install --skip-unavailable \
    gtk4 \
    gtk4-devel \
    gtk4-doc \
    gtk4-tools

echo "Installing common GTK dependencies..."
sudo dnf -y install --skip-unavailable \
    glib2 \
    glib2-devel \
    pango \
    pango-devel \
    gdk-pixbuf2 \
    gdk-pixbuf2-devel \
    atk \
    atk-devel \
    gobject-introspection \
    gobject-introspection-devel \
    libepoxy \
    libepoxy-devel

echo "Installing optional extras (themes, demos, examples)..."
sudo dnf -y install --skip-unavailable \
    adwaita-icon-theme \
    gtk3-demo \
    gtk4-demo \
    gtk4-examples

echo "GTK3/GTK4 installation complete!"

