#!/bin/bash

# Bash script to fix linux-firmware-nvidia conflict on Arch Linux

echo "🔧 Starting firmware cleanup..."

# Step 1: Remove linux-firmware without dependency checks
echo "➡️ Removing linux-firmware package..."
sudo pacman -Rdd linux-firmware || {
    echo "❌ Failed to remove linux-firmware. Exiting."
    exit 1
}

# Step 2: Update system packages
echo "➡️ Updating system..."
sudo pacman -Syu --noconfirm || {
    echo "❌ System update failed. Exiting."
    exit 1
}

# Step 3: Install only relevant firmware packages (adjust as needed)
echo "➡️ Installing relevant firmware packages..."
sudo pacman -S --noconfirm linux-firmware-intel linux-firmware-realtek || {
    echo "❌ Firmware installation failed. Exiting."
    exit 1
}

echo "✅ Firmware cleanup complete. Your system should be good to go!"

