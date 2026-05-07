#!/usr/bin/env bash
set -euo pipefail

log() { echo -e "\033[1;32m[INFO]\033[0m $*"; }
err() { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }

detect_distro() {
  if command -v dnf &>/dev/null; then echo "fedora"
  elif command -v apt &>/dev/null; then echo "debian"
  elif command -v pacman &>/dev/null; then echo "arch"
  elif command -v zypper &>/dev/null; then echo "opensuse"
  else err "Unsupported distro"; exit 1
  fi
}

install_packages() {
  local distro="$1"
  case "$distro" in
    fedora)
      sudo dnf install -y \
        webkit2gtk4.0-devel webkit2gtk4.1-devel libsoup3 libsoup3-devel \
        gtk3-devel libappindicator-gtk3 libnotify-devel \
        gstreamer1 gstreamer1-plugins-base pulseaudio-libs-devel \
        gcc make curl pkgconf openssl-devel clang
      ;;
    debian)
      sudo apt update
      sudo apt install -y \
        libwebkit2gtk-4.0-dev libwebkit2gtk-4.1-dev libsoup-3.0-dev \
        libgtk-3-dev libappindicator3-dev libnotify-dev \
        gstreamer1.0-plugins-base gstreamer1.0-libav libpulse-dev \
        build-essential curl pkg-config libssl-dev clang
      ;;
    arch)
      sudo pacman -Sy --noconfirm \
        webkit2gtk libsoup3 gtk3 libappindicator-gtk3 libnotify \
        gstreamer gst-plugins-base pulseaudio \
        base-devel curl pkgconf openssl clang
      ;;
    opensuse)
      sudo zypper install -y \
        webkit2gtk3-devel libsoup3-devel gtk3-devel \
        libappindicator3-devel libnotify-devel \
        gstreamer-plugins-base pulseaudio-devel \
        gcc make curl pkg-config libopenssl-devel clang
      ;;
    *)
      err "No install logic for $distro"
      ;;
  esac
}

main() {
  log "Detecting distro..."
  distro=$(detect_distro)
  log "Detected: $distro"

  log "Installing Tauri native dependencies..."
  install_packages "$distro"
  log "All dependencies installed successfully."
}

main "$@"

