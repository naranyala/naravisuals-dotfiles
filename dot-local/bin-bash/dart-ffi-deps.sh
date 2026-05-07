#!/usr/bin/env bash
set -euo pipefail

LOG="$HOME/ffi_libs_setup.log"
DISTRO="$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"
}

install_ffi_libs() {
  log "Installing native libraries for Dart FFI on $DISTRO..."

  case "$DISTRO" in
    ubuntu|debian)
      sudo apt update
      sudo apt install -y \
        libsqlite3-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        libz-dev \
        libpng-dev \
        libjpeg-dev \
        libavcodec-dev libavformat-dev libswscale-dev \
        libsndfile1-dev libasound2-dev \
        libglib2.0-dev libdbus-1-dev \
        libudev-dev libx11-dev libxrandr-dev
      ;;
    arch)
      sudo pacman -Sy --noconfirm \
        sqlite \
        curl \
        openssl \
        zlib \
        libpng \
        libjpeg-turbo \
        ffmpeg \
        sndfile alsa-lib \
        glib2 dbus \
        libudev0-shim libx11 libxrandr
      ;;
    fedora)
      sudo dnf install -y \
        sqlite-devel \
        libcurl-devel \
        openssl-devel \
        zlib-devel \
        libpng-devel \
        libjpeg-devel \
        ffmpeg-devel \
        libsndfile-devel alsa-lib-devel \
        glib2-devel dbus-devel \
        libudev-devel libX11-devel libXrandr-devel
      ;;
    *)
      log "Unsupported distro: $DISTRO"
      exit 1
      ;;
  esac
}

main() {
  log "Starting native FFI library setup..."
  install_ffi_libs
  log "Setup complete. See $LOG for details."
}

main "$@"

