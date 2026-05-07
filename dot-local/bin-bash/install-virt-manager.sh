#!/bin/bash

# 🧠 Check for root
if [ "$EUID" -ne 0 ]; then
  echo "⚠️ Please run this script as root."
  exit 1
fi

echo "🔧 Updating package list..."
apt update || pacman -Sy

echo "📦 Installing required packages..."
if command -v apt &> /dev/null; then
  apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
elif command -v pacman &> /dev/null; then
  pacman -S --noconfirm qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils
else
  echo "❌ Unsupported distro. This script supports apt or pacman only."
  exit 1
fi

echo "👤 Adding current user to libvirt group..."
usermod -aG libvirt "$SUDO_USER"

echo "🔁 Restarting system recommended to apply group changes."

echo "🎉 Setup complete! Launch Virt-Manager with:"
echo "  virt-manager"

echo ""
echo "🚀 Next steps:"
echo "  - Create a new VM in Virt-Manager"
echo "  - Select your Windows ISO as install media"
echo "  - Assign resources (RAM, CPU, disk)"
echo "  - Add VirtIO drivers if using VirtIO disk for performance"
echo "  - After install, run 'virtio-win-guest-tools.exe' in Windows VM"

echo ""
echo "💡 Tip: Use UEFI firmware and Q35 chipset if installing Windows 11."

