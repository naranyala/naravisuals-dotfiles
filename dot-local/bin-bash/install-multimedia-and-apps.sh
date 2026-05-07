#!/bin/bash

# Update system
echo "Updating system..."
sudo dnf update -y

# Enable RPM Fusion repositories (free and nonfree)
echo "Enabling RPM Fusion repositories..."
sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Multimedia codecs and tools
echo "Installing multimedia packages..."
sudo dnf install -y --skip-unavailable \
  gstreamer1-plugins-base \
  gstreamer1-plugins-good \
  gstreamer1-plugins-bad-free \
  gstreamer1-plugins-bad-freeworld \
  gstreamer1-plugins-ugly \
  gstreamer1-libav \
  lame \
  ffmpeg \
  vlc \
  audacity \
  kdenlive \
  obs-studio \
  mpv \
  x264 x265

# Essential applications
echo "Installing essential applications..."
sudo dnf install -y --skip-unavailable \
  firefox \
  # thunderbird \
  # libreoffice \
  gimp \
  inkscape \
  filezilla \
  fastfetch \
  htop \
  curl \
  wget \
  git \
  flatpak

# Optional: Enable Flathub for more apps
echo "Enabling Flathub repository..."
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "Installation complete! 🎉"

