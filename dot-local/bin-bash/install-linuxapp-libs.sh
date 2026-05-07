#!/usr/bin/env bash
set -euo pipefail

# Packages to install
PKGS=(
  cmark
  cmark-devel
  gtk3-devel
  gtk4-devel
  webkitgtk-devel
  gobject-introspection-devel
  pkgconfig
  meson
  ninja-build
  gcc
  make
  python3
  python3-pip
)

echo "Updating package metadata..."
sudo dnf makecache --refresh

echo "Installing development packages..."
sudo dnf install -y "${PKGS[@]}" --skip-unavailable

echo
echo "Checking whether any package provides cmark-gtk.h..."
if sudo dnf provides '*/cmark-gtk.h' >/dev/null 2>&1; then
  echo "A package provides cmark-gtk.h:"
  sudo dnf provides '*/cmark-gtk.h'
else
  echo "No package in the repos provides cmark-gtk.h."
  echo "You may need to build a GTK integration from source or vendor the header."
fi

echo
echo "Installed packages summary:"
rpm -q "${PKGS[@]}" || true

echo "Done."

