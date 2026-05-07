
#!/bin/bash

# Exit on error
set -e

# Update the system
echo "Updating system packages..."
sudo dnf update -y

# Install GTK 3 and GTK 4 development packages
echo "Installing GTK development packages..."
sudo dnf install -y \
    gtk3-devel \
    gtk4-devel \
    glib2-devel \
    libadwaita-devel

# Install build tools and dependencies
echo "Installing build tools and dependencies..."
sudo dnf install -y \
    meson \
    ninja-build \
    pkg-config \
    vala \
    gcc \
    gcc-c++ \
    make \
    cmake \
    git \
    gdb

# Install documentation tools
echo "Installing documentation tools..."
sudo dnf install -y \
    gtk-doc \
    devhelp

# Print completion message
echo ""
echo "GTK development environment setup complete!"
echo "You can now start developing GTK applications."
