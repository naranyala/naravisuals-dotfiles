#!/bin/bash
# Force-fix dpkg/apt issues and update the system
# Tested on Debian/Ubuntu-based systems

set -e  # Exit on error
set -o pipefail

echo "=== [1/6] Checking for root privileges ==="
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (e.g., sudo $0)"
  exit 1
fi

echo "=== [2/6] Reconfiguring dpkg frontend ==="
dpkg --configure -a

echo "=== [3/6] Fixing broken dependencies ==="
apt-get install -f -y

echo "=== [4/6] Cleaning up package cache ==="
apt-get clean
apt-get autoclean

echo "=== [5/6] Updating package lists ==="
apt-get update

echo "=== [6/6] Upgrading packages ==="
apt-get dist-upgrade -y

echo "=== System update complete! ==="

