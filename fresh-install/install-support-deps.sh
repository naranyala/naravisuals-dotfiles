#!/usr/bin/env bash


## install-support-deps.sh
#!/usr/bin/env bash
set -e

echo "Detecting package manager..."

if command -v apt >/dev/null 2>&1; then
    echo "APT detected (Debian/Ubuntu). Installing dependencies..."
    sudo apt update
    sudo apt install -y \
        build-essential \
        cmake \
        pkg-config \
        libglib2.0-dev \
        libcairo2-dev \
        librsvg2-dev \
        libdbus-1-dev \
        libdbus-glib-1-dev \
        libxml2-dev \
        libgl1-mesa-dev \
        libglu1-mesa-dev \
        libcurl4-openssl-dev \
        libgtk-3-dev \
        libgtk-4-dev

elif command -v dnf >/dev/null 2>&1; then
    echo "DNF detected (Fedora/RHEL). Installing dependencies..."
    sudo dnf install -y \
        gcc gcc-c++ make \
        cmake \
        pkg-config \
        glib2-devel \
        cairo-devel \
        librsvg2-devel \
        dbus-devel \
        dbus-glib-devel \
        libxml2-devel \
        mesa-libGL-devel \
        mesa-libGLU-devel \
        libcurl-devel \
        gtk3-devel \
        gtk4-devel

else
    echo "Error: No supported package manager found (apt or dnf)."
    exit 1
fi

echo "All dependencies installed successfully!"

