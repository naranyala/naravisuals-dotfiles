#!/usr/bin/env bash
set -euo pipefail

# 📦 Packages required
REQUIRED_PACKAGES=(
  build-essential
  dkms
  linux-headers-$(uname -r)
  virtualbox
  virtualbox-dkms
)

echo "🔍 Checking and installing required packages..."
for pkg in "${REQUIRED_PACKAGES[@]}"; do
  if ! dpkg -s "$pkg" &>/dev/null; then
    echo "📦 Installing $pkg..."
    sudo apt install -y "$pkg"
  else
    echo "✅ $pkg is already installed."
  fi
done

# 🧰 Reconfiguring VirtualBox kernel module
echo "🔧 Running VirtualBox configuration..."
if [ -x /sbin/vboxconfig ]; then
  sudo /sbin/vboxconfig
else
  echo "⚠️ /sbin/vboxconfig not found. Trying modprobe instead..."
  sudo modprobe vboxdrv || {
    echo "❌ Failed to load vboxdrv module. Try rebooting or check Secure Boot settings."
    exit 1
  }
fi

# 🚦 Status check
echo "🔎 Checking if vboxdrv module is loaded..."
if lsmod | grep -q vboxdrv; then
  echo "✅ Kernel driver loaded successfully!"
else
  echo "❌ Kernel driver is still not loaded."
  echo "👉 You may need to disable Secure Boot or manually sign the kernel module."
fi

