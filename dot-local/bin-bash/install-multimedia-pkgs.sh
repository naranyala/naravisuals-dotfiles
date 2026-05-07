#!/usr/bin/env bash

set -euo pipefail

LOGFILE="/var/log/multimedia-setup.log"
PKG_GROUP="Multimedia Packages"
PKGS=(
  # Core multimedia tools
  ffmpeg
  gstreamer1-plugins-base
  gstreamer1-plugins-good
  gstreamer1-plugins-bad-free
  gstreamer1-plugins-bad-freeworld
  gstreamer1-plugins-ugly
  gstreamer1-libav
  vlc
  mpv

  # Audio tools
  audacity
  pavucontrol
  sox
  lame
  flac

  # creative tools
  inkscape

  # Codecs and extras
  x264
  x265
  libdvdcss
  libdvdread
  libdvdnav
)

function log() {
  echo "[$(date +'%F %T')] $*" | tee -a "$LOGFILE"
}

function check_root() {
  if [[ $EUID -ne 0 ]]; then
    log "This script must be run as root."
    exit 1
  fi
}

function check_dnf() {
  if ! command -v dnf &>/dev/null; then
    log "dnf not found. This script is intended for Fedora-based systems."
    exit 1
  fi
}

function enable_rpmfusion() {
  log "Enabling RPM Fusion repositories..."
  dnf install -y --skip-unavailable \
    https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
}

function install_packages() {
  log "Installing $PKG_GROUP..."
  dnf install -y  --skip-unavailable "${PKGS[@]}"
}

function main() {
  log "Starting $PKG_GROUP installation..."
  check_root
  check_dnf
  enable_rpmfusion
  install_packages
  log "$PKG_GROUP installation complete."
}

main

