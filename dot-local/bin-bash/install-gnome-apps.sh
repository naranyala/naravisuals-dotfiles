#!/bin/bash

# GNOME Apps Installer for Fedora & Debian/Ubuntu (No Desktop Environment)
# Run this script with sudo privileges

echo "🔧 Detecting package manager..."

if command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    UPDATE_CMD="dnf update -y"
    INSTALL_CMD="dnf install -y --skip-unavailable"
    PKG_LIST=(
        gnome-terminal
        gnome-system-monitor
        gnome-disk-utility
        gnome-calculator
        gnome-characters
        gnome-font-viewer
        gnome-logs
        gnome-maps
        gnome-weather
        gnome-clocks
        gnome-screenshot
        gnome-tweaks
        gnome-contacts
        gnome-calendar
        gnome-software
        gnome-shell-extension-user-theme
        gnome-shell-extension-appindicator
        # gnome-shell-extension-dash-to-dock
        gnome-shell-extension-topicons-plus
    )
elif command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
    UPDATE_CMD="apt update -y && apt upgrade -y"
    INSTALL_CMD="apt install -y"
    PKG_LIST=(
        gnome-terminal
        gnome-system-monitor
        gnome-disk-utility
        gnome-calculator
        gnome-characters
        gnome-font-viewer
        gnome-logs
        gnome-maps
        gnome-weather
        gnome-clocks
        gnome-screenshot
        gnome-tweaks
        gnome-contacts
        gnome-calendar
        gnome-software
        gnome-shell-extensions
        gnome-shell-extension-appindicator
        # gnome-shell-extension-dash-to-dock
        # TopIcons Plus is deprecated; use AppIndicator instead
    )
else
    echo "❌ No supported package manager found (dnf or apt)."
    exit 1
fi

echo "📦 Using $PKG_MANAGER"
echo "🔄 Updating system..."
eval "$UPDATE_CMD"

echo "📥 Installing GNOME apps..."
eval "$INSTALL_CMD ${PKG_LIST[*]}"

echo "✅ GNOME apps installed successfully!"

