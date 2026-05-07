#!/bin/bash

echo "🚀 Starting Fedora optimization..."

# 1. Remove unused services
echo "🔧 Disabling unnecessary services..."
systemctl disable bluetooth cups avahi-daemon
systemctl mask systemd-udev-settle
systemctl disable NetworkManager-wait-online.service

# 2. Enable RPM Fusion Repos
echo "📦 Enabling RPM Fusion repositories..."
dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# 3. Install TuneD and apply performance profile
echo "⚙️ Installing and configuring TuneD..."
dnf install -y tuned
systemctl enable --now tuned
tuned-adm profile latency-performance

# 4. Install GameMode
echo "🎮 Installing GameMode for gaming performance..."
dnf install -y gamemode

# 5. Clean system
echo "🧹 Cleaning up system..."
dnf autoremove -y
dnf clean all

# 6. Optional: Disable SELinux (comment out if you want to keep it)
echo "⚠️ Disabling SELinux (optional, reduces security)..."
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

echo "✅ All tweaks applied. Reboot recommended!"

