#!/bin/bash

# Cinnamon + GNOME App Suite Installer for Fedora

echo "🔧 Starting installation of Cinnamon + GNOME desktop tools..."

# Update system
sudo dnf upgrade --refresh -y

# Cinnamon desktop environment
echo "📦 Installing Cinnamon desktop environment..."
sudo dnf groupinstall -y "Cinnamon Desktop"

# Cinnamon tools and utilities
echo "🧩 Installing Cinnamon tools..."
sudo dnf install -y \
  --skip-unavailable \
  cinnamon-control-center \
  cinnamon-screensaver \
  cinnamon-settings-daemon \
  cinnamon-session \
  cinnamon-translations \
  nemo \
  nemo-fileroller \
  cinnamon-desklets \
  cinnamon-applets

# GNOME core apps and utilities
echo "🧠 Installing GNOME applications..."
sudo dnf install -y \
  --skip-unavailable \
  gnome-calendar \
  gnome-contacts \
  gnome-weather \
  gnome-maps \
  gnome-clocks \
  gnome-calculator \
  gnome-disk-utility \
  gnome-font-viewer \
  gnome-system-monitor \
  gnome-terminal \
  gedit \
  evince \
  file-roller

# GNOME customization tools
echo "🎨 Installing GNOME customization tools..."
sudo dnf install -y \
  --skip-unavailable \
  gnome-tweaks \
  dconf-editor \
  arc-theme \
  numix-gtk-theme \
  numix-icon-theme

# Optional: Backup and system tools
echo "🧰 Installing system utilities..."
sudo dnf install -y \
  --skip-unavailable \
  timeshift \
  synaptic

echo "✅ Installation complete! Enjoy your enhanced Cinnamon + GNOME desktop experience."

