#!/usr/bin/env bash
set -euo pipefail

LOG="$HOME/multimedia_setup.log"
DISTRO="$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"
}

install_multimedia_libs() {
  log "Installing multimedia libraries for $DISTRO..."

  case "$DISTRO" in
    ubuntu|debian)
      sudo apt update
      sudo apt install -y \
        ffmpeg \
        libavcodec-dev libavformat-dev libswscale-dev \
        libasound2-dev libpulse-dev libsndfile1-dev \
        libopenal-dev \
        libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev \
        libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
        libjpeg-dev libpng-dev libwebp-dev \
        libv4l-dev v4l-utils
      ;;
    arch)
      sudo pacman -Sy --noconfirm \
        ffmpeg \
        alsa-lib pulseaudio libsndfile \
        openal \
        sdl2 sdl2_image sdl2_mixer sdl2_ttf \
        gstreamer gst-plugins-base \
        libjpeg-turbo libpng libwebp \
        v4l-utils
      ;;
    fedora)
      sudo dnf install -y \
        ffmpeg ffmpeg-devel \
        alsa-lib-devel pulseaudio-libs-devel libsndfile-devel \
        openal-soft-devel \
        SDL2-devel SDL2_image-devel SDL2_mixer-devel SDL2_ttf-devel \
        gstreamer1-devel gstreamer1-plugins-base-devel \
        libjpeg-devel libpng-devel libwebp-devel \
        libv4l-devel v4l-utils
      ;;
    *)
      log "Unsupported distro: $DISTRO"
      exit 1
      ;;
  esac
}

main() {
  log "Starting multimedia package setup..."
  install_multimedia_libs
  log "Setup complete. See $LOG for details."
}

main "$@"

