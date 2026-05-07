#!/usr/bin/env bash
# Fedora XFCE Post‑Install Setup Script
# Run after fresh install for RPM Fusion, codecs, tweaks, and XFCE‑friendly essentials

set -e

echo "🚀 Starting Fedora XFCE post‑install setup..."

# 1️⃣ Update system and optimize DNF
echo "📦 Updating system packages..."
sudo dnf -y update

echo "⚡ Optimizing DNF configuration..."
sudo tee -a /etc/dnf/dnf.conf > /dev/null <<EOL
max_parallel_downloads=10
fastestmirror=True
EOL

# 2️⃣ Enable RPM Fusion (Free + Nonfree)
echo "🔓 Enabling RPM Fusion repositories..."
sudo dnf -y install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Enable Cisco H.264 repo
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1

# 3️⃣ Multimedia & Fonts
echo "🎵 Installing multimedia codecs and fonts..."
sudo dnf -y groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf -y groupupdate sound-and-video
sudo dnf -y install freetype-freeworld

# 4️⃣ Enable Flathub
echo "📦 Setting up Flathub repository..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# 5️⃣ XFCE‑friendly essential apps
echo "🛠 Installing XFCE essentials..."
sudo dnf -y install \
  xfce4-terminal \
  thunar-volman \
  ristretto \
  parole \
  mousepad \
  catfish \
  pavucontrol \
  file-roller \
  gnome-disk-utility \
  network-manager-applet \
  gvfs gvfs-mtp gvfs-smb \
  htop \
  neovim \
  unzip p7zip p7zip-plugins \
  wget curl git

# Optional browsers
sudo dnf -y install firefox

# 6️⃣ System tweaks (XFCE defaults)
echo "⚙️ Applying XFCE default tweaks..."
# Show minimize/maximize/close buttons in proper order
xfconf-query -c xfwm4 -p /general/button_layout -s "O|HMC"
# Enable compositing (for smoother graphics)
xfconf-query -c xfwm4 -p /general/use_compositing -s true
# Set clock to show date
xfconf-query -c xfce4-panel -p /plugins/plugin-1/digital-format -s "%a %d %b, %H:%M"
# Enable NumLock at startup
sudo dnf -y install numlockx
echo "@numlockx on" >> ~/.config/autostart/numlockx.desktop

# 7️⃣ GNOME Tweaks removed — XFCE doesn’t need them

echo "✅ All done! Reboot or log out/in to apply all changes."

