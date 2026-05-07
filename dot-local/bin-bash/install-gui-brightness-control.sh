#!/bin/bash
# install-brightness-controller-fedora.sh
# Installs Brightness Controller via Flatpak on Fedora

set -e

echo "=== Installing Brightness Controller (Flatpak) ==="

sudo dnf install -y ddcutil
sudo flatpak install -y flathub io.github.rockowitz.ddcui

