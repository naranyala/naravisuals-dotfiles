#!/usr/bin/env bash
# remove-kde-qt-fedora.sh
# Remove KDE Plasma desktop and Qt-related packages on Fedora
# Then switch login manager to GDM

set -euo pipefail

DRYRUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRYRUN=true
fi

echo "=== Detecting KDE/Qt packages installed ==="
PKGS=$(dnf repoquery --installed | grep -E '^(kde|kf5-|plasma-|qt5-|qt6-)')

if [[ -z "$PKGS" ]]; then
  echo "No KDE Plasma or Qt packages found."
else
  echo "Found packages:"
  echo "$PKGS"

  if $DRYRUN; then
    echo "Dry run mode: no packages will be removed."
  else
    echo "Proceeding to remove packages..."
    sudo dnf remove -y $PKGS
    echo "Cleanup unused dependencies..."
    sudo dnf autoremove -y
    sudo dnf clean all
  fi
fi

echo "=== Switching login manager to GDM ==="
if $DRYRUN; then
  echo "Dry run mode: would install and enable GDM."
else
  # Ensure GDM is installed
  sudo dnf install -y gdm

  # Disable SDDM if present
  if systemctl list-unit-files | grep -q sddm.service; then
    sudo systemctl disable sddm || true
  fi

  # Enable GDM
  sudo systemctl enable gdm
  sudo systemctl set-default graphical.target

  echo "GDM has been enabled as the login manager."
  echo "Reboot to apply changes: sudo reboot"
fi

echo "=== Script complete ==="

