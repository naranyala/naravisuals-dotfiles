#!/bin/bash

# Check for package manager
if command -v apt-get &> /dev/null; then
    echo "Detected Ubuntu/Debian system (APT)."
    sudo apt update
    # Note: Ubuntu 24.04+ uses 4.1 version by default; older versions use 4.0
    # This installs the common webkit requirements for Tauri
    sudo apt install -y \
        libwebkit2gtk-4.1-dev \
        libappindicator3-dev \
        librsvg2-dev \
        libsoup-3.0-dev \
        libjavascriptcoregtk-4.1-dev \
        build-essential \
        curl \
        wget \
        libssl-dev \
        libgtk-3-dev
        
elif command -v dnf &> /dev/null; then
    echo "Detected Fedora system (DNF)."
    sudo dnf check-update
    # Fedora packages often group javascriptcore within webkit2gtk-devel
    sudo dnf install -y \
        webkit2gtk4.1-devel \
        libsoup3-devel \
        openssl-devel \
        curl \
        wget \
        libappindicator-gtk3-devel \
        librsvg2-devel \
        gcc \
        g++ \
        make
    sudo dnf group install -y "C Development Tools and Libraries"

else
    echo "Error: Neither apt nor dnf was found. This script only supports Debian/Ubuntu or Fedora based systems."
    exit 1
fi

echo "Installation complete. You can now try 'cargo tauri build' again."

