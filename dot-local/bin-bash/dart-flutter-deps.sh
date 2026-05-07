#!/usr/bin/env bash
set -euo pipefail

LOG="$HOME/flutter_dev_setup.log"
DISTRO="$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG"
}

install_packages() {
  log "Installing dev dependencies for $DISTRO..."

  case "$DISTRO" in
    ubuntu|debian)
      sudo apt update
      sudo apt install -y \
        build-essential cmake pkg-config \
        libgl1-mesa-dev libglu1-mesa-dev \
        libasound2-dev libpulse-dev \
        libx11-dev libxrandr-dev libxi-dev libxinerama-dev libxcursor-dev \
        libudev-dev libdbus-1-dev \
        libgtk-3-dev liblzma-dev \
        clang lldb gdb \
        neovim unzip curl git zip xz-utils
      ;;
    arch)
      sudo pacman -Sy --noconfirm \
        base-devel cmake pkgconf \
        mesa glu \
        alsa-lib pulseaudio \
        libx11 libxrandr libxi libxinerama libxcursor \
        libsystemd dbus \
        gtk3 xz \
        clang lldb gdb \
        neovim unzip curl git zip
      ;;
    fedora)
      sudo dnf install -y \
        gcc gcc-c++ make cmake pkgconf-pkg-config \
        mesa-libGL-devel mesa-libGLU-devel \
        alsa-lib-devel pulseaudio-libs-devel \
        libX11-devel libXrandr-devel libXi-devel libXinerama-devel libXcursor-devel \
        systemd-devel dbus-devel \
        gtk3-devel xz-devel \
        clang lldb gdb \
        neovim unzip curl git zip
      ;;
    *)
      log "Unsupported distro: $DISTRO"
      exit 1
      ;;
  esac
}

main() {
  log "Starting Linux dev package setup for Dart/Flutter..."
  install_packages
  log "Setup complete. See $LOG for details."
}

main "$@"

