
#!/bin/bash
# Script to install GUI-related development packages on Fedora

set -e

echo "Updating system..."
sudo dnf -y update

echo "Installing core GUI libraries and development headers..."

# GTK (popular C GUI toolkit)
sudo dnf -y install gtk3 gtk3-devel

# Qt (C++ GUI framework, useful if mixing with C++)
sudo dnf -y install qt5-qtbase qt5-qtbase-devel

# SDL2 (multimedia & GUI helper library)
sudo dnf -y install SDL2 SDL2-devel

# OpenGL + GLEW (graphics rendering)
sudo dnf -y install mesa-libGL mesa-libGL-devel glew glew-devel

# Nuklear dependencies (minimal, but SDL2/OpenGL are needed)
# Already covered above

# Extra GUI utilities
sudo dnf -y install cairo cairo-devel pango pango-devel

echo "All GUI-related packages installed successfully!"
