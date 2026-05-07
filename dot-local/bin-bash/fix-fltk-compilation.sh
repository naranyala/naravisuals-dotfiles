#!/usr/bin/env bash
# install-fltk-deps.sh
# Script to install all dependencies needed to build FLTK from source on Fedora
# without using groupinstall

set -e

echo "Updating package metadata..."
sudo dnf -y update

echo "Installing core build tools..."
sudo dnf -y install \
    gcc gcc-c++ make cmake git

echo "Installing X11 and OpenGL development libraries..."
sudo dnf -y install \
    libX11-devel libXext-devel libXft-devel libXinerama-devel \
    mesa-libGL-devel mesa-libGLU-devel

echo "Installing image and compression libraries..."
sudo dnf -y install \
    libjpeg-turbo-devel libpng-devel zlib-devel

echo "Installing optional GUI/image helpers..."
sudo dnf -y install \
    gdk-pixbuf2 gdk-pixbuf2-devel

echo "Installing LaTeX (optional, for building PDF docs)..."
sudo dnf -y install \
    texlive texlive-latex texlive-latex-bin \
    texlive-collection-latex texlive-collection-latexrecommended \
    texlive-collection-fontsrecommended

echo "All dependencies installed! You can now build FLTK from source."
echo "Example build:"
echo "  git clone https://github.com/fltk/fltk.git"
echo "  cd fltk && mkdir build && cd build"
echo "  cmake .. -DCMAKE_BUILD_TYPE=Release -DOPTION_BUILD_DOCS=OFF"
echo "  make -j$(nproc) && sudo make install"

