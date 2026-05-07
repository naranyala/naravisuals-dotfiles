#!/bin/bash

# KDE Plasma Apps Installer for Fedora & Debian/Ubuntu (No Desktop Environment)
# Run this script with sudo privileges

echo "🔧 Detecting package manager..."

if command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    UPDATE_CMD="dnf update -y"
    INSTALL_CMD="dnf install -y --skip-unavailable"
elif command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
    UPDATE_CMD="apt update -y && apt upgrade -y"
    INSTALL_CMD="apt install -y"
else
    echo "❌ No supported package manager found (dnf or apt)."
    exit 1
fi

echo "📦 Using $PKG_MANAGER"

# Update system
eval "$UPDATE_CMD"

# Install KDE apps
eval "$INSTALL_CMD" \
  konsole \
  dolphin \
  kate \
  okular \
  gwenview \
  ark \
  kcalc \
  kcharselect \
  kcolorchooser \
  ksystemlog \
  # spectacle \
  kdenlive \
  kmail \
  kontact \
  korganizer \
  kruler \
  ktimer \
  k3b \
  filelight \
  yakuake \
  skanlite \
  plasma-systemmonitor \
  plasma-discover \
  kdeconnect \
  partitionmanager

echo "✅ KDE Plasma apps installed successfully!"

