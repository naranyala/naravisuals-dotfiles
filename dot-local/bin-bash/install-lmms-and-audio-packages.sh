#!/bin/bash
# install-lmms.sh
# Installer for LMMS DAW and essential audio packages on Ubuntu

set -e  # Exit immediately if a command fails

echo "=== Updating system package lists ==="
sudo apt update

echo "=== Upgrading existing packages ==="
sudo apt upgrade -y

echo "=== Installing LMMS and essential audio packages ==="
sudo apt install -y \
  lmms \
  audacity \
  qjackctl \
  pulseaudio-module-jack \
  calf-plugins \
  swh-plugins \
  fluidsynth \
  fluid-soundfont-gm \
  ladspa-sdk \
  lv2-dev

echo "=== Cleaning up unnecessary packages ==="
sudo apt autoremove -y
sudo apt clean

echo "=== Installation complete! ==="
echo "You can now launch LMMS from your applications menu or by typing 'lmms' in the terminal."

