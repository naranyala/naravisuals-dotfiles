#!/bin/bash

# Universal Linux Time Sync Script
# Supports systemd-timesyncd, chrony, or ntpdate
# Auto-installs missing tools and starts required daemons

NTP_SERVER="pool.ntp.org"

# Function to install a package if missing
install_if_missing() {
    local pkg="$1"
    if ! command -v "$pkg" &> /dev/null; then
        echo "📦 Installing $pkg..."
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y "$pkg"
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y "$pkg"
        elif command -v yum &> /dev/null; then
            sudo yum install -y "$pkg"
        elif command -v pacman &> /dev/null; then
            sudo pacman -Sy --noconfirm "$pkg"
        else
            echo "⚠️ Unsupported package manager. Please install $pkg manually."
            exit 1
        fi
    fi
}

# Check internet connection
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    echo "❌ No internet connection. Time sync skipped."
    exit 1
fi

echo "✅ Internet connection detected."

# Detect if systemd is present
if pidof systemd &> /dev/null; then
    echo "🛠 Detected systemd — using systemd-timesyncd"
    # Ensure systemd-timesyncd is installed (Arch may not have it by default)
    if ! systemctl list-unit-files | grep -q systemd-timesyncd; then
        echo "📦 Installing systemd-timesyncd..."
        if command -v pacman &> /dev/null; then
            sudo pacman -Sy --noconfirm systemd
        elif command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y systemd-timesyncd
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y systemd-timesyncd
        fi
    fi
    sudo systemctl enable --now systemd-timesyncd
    sudo timedatectl set-ntp true
    echo "🕒 Time sync triggered via systemd-timesyncd."
else
    echo "🛠 Non-systemd system detected — using chrony or ntpdate"
    if command -v chronyc &> /dev/null; then
        sudo systemctl enable --now chronyd 2>/dev/null || sudo service chronyd start
        sudo chronyc -a makestep
        echo "🕒 Time synced using chrony."
    elif command -v ntpdate &> /dev/null; then
        sudo ntpdate -u "$NTP_SERVER"
        echo "🕒 Time synced using ntpdate."
    else
        echo "ℹ️ Installing chrony..."
        install_if_missing chrony
        sudo systemctl enable --now chronyd 2>/dev/null || sudo service chronyd start
        sudo chronyc -a makestep
        echo "🕒 Time synced using newly installed chrony."
    fi
fi

