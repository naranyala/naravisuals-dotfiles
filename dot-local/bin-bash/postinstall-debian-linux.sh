#!/bin/bash
# Debian-based Linux Post-Install Setup Script
# Works on Debian, Ubuntu, Linux Mint, Pop!_OS, etc.

set -e  # Exit on error

echo "=== Starting Post-Install Setup ==="

# --- 1. Update & Upgrade ---
echo ">>> Updating system..."
sudo apt update && sudo apt full-upgrade -y

# --- 2. Install Essentials ---
echo ">>> Installing essential packages for development and daily use..."
sudo apt install -y \
    build-essential \
    gcc \
    g++ \
    clang \
    make \
    cmake \
    ninja-build \
    pkg-config \
    autoconf \
    automake \
    libtool \
    m4 \
    gdb \
    valgrind \
    strace \
    ltrace \
    binutils \
    nasm \
    flex \
    bison \
    libssl-dev \
    libffi-dev \
    zlib1g-dev \
    libreadline-dev \
    # libncurses5-dev \
    # libncursesw5-dev \
    libsqlite3-dev \
    libbz2-dev \
    liblzma-dev \
    curl \
    wget \
    git \
    vim \
    nano \
    gnome-tweaks \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    ufw \
    htop \
    unzip \
    p7zip-full \
    neofetch \
    gparted \
    vlc \
    ffmpeg \
    fonts-firacode

# --- 3. Enable Firewall ---
echo ">>> Configuring firewall..."
sudo ufw allow OpenSSH
sudo ufw enable
sudo ufw status

# --- 4. Install Flatpak & Flathub ---
echo ">>> Setting up Flatpak..."
sudo apt install -y flatpak gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# --- 5. Cleanup ---
echo ">>> Cleaning up..."
sudo apt autoremove -y
sudo apt clean

# --- 6. System Info ---
echo ">>> System info:"
neofetch || true

echo "=== Post-Install Setup Complete! ==="

