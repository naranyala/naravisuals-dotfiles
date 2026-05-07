#!/usr/bin/env bash
# install-fltk-rs-deps.sh
# Dependencies for building fltk-rs on Fedora

set -e

echo "Installing build essentials..."
sudo dnf -y install gcc gcc-c++ make cmake git

echo "Installing X11 and OpenGL development libraries..."
sudo dnf -y install \
    libX11-devel libXext-devel libXft-devel libXinerama-devel \
    mesa-libGL-devel mesa-libGLU-devel

echo "Installing image and compression libraries..."
sudo dnf -y install \
    libjpeg-turbo-devel libpng-devel zlib-devel

echo "All dependencies installed. Now try building your Rust project again:"
echo "  cargo build"

