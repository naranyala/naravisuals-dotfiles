#!/usr/bin/env bash
#
# multimedia_setup.sh — Provision multimedia dev stack on Fedora
# Audit-friendly, idempotent, and extensible
#
# Usage: sudo ./multimedia_setup.sh
#

set -euo pipefail

LOGFILE="/var/log/multimedia_setup.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "[INFO] Starting multimedia provisioning at $(date)"

# --- CONFIG: Package groups ---
BASE_PKGS=(
  gstreamer1-devel
  gstreamer1-plugins-base-devel
  gstreamer1-plugins-good
  gstreamer1-plugins-good-extras
  gstreamer1-plugins-bad-free
  gstreamer1-plugins-bad-free-devel
  gstreamer1-plugins-bad-free-extras
  gstreamer1-plugins-ugly
  gstreamer1-libav
)

EXTRA_CODECS=(
  ffmpeg
  lame
  x264
  x265
  opus
  vorbis-tools
  flac
)

IMAGE_LIBS=(
  libjpeg-turbo-devel
  libpng-devel
  libtiff-devel
  libwebp-devel
)

AUDIO_DEV=(
  alsa-lib-devel
  pulseaudio-libs-devel
  jack-audio-connection-kit-devel
  pipewire-devel
)

# --- FUNCTIONS ---
check_distro() {
  if ! grep -qi "fedora" /etc/os-release; then
    echo "[ERROR] This script is intended for Fedora."
    exit 1
  fi
}

enable_rpmfusion() {
  echo "[INFO] Enabling RPM Fusion repos (free + nonfree)"
  dnf install -y \
    https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
}

install_pkgs() {
  local group_name="$1"
  shift
  local pkgs=("$@")
  echo "[INFO] Installing $group_name packages..."
  dnf install -y "${pkgs[@]}"
}

# --- EXECUTION ---
check_distro
enable_rpmfusion
dnf upgrade -y

install_pkgs "GStreamer base" "${BASE_PKGS[@]}"
install_pkgs "Extra codecs" "${EXTRA_CODECS[@]}"
install_pkgs "Image libraries" "${IMAGE_LIBS[@]}"
install_pkgs "Audio development" "${AUDIO_DEV[@]}"

echo "[INFO] Multimedia provisioning completed at $(date)"

