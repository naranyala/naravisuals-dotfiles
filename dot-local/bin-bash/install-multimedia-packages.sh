#!/usr/bin/env bash
#
# install_multimedia_libs.sh
# Installs essential multimedia development libraries for Fedora.
# Covers audio, video, codecs, DSP plugin APIs, and GPU acceleration.
#
# Usage:
#   sudo ./install_multimedia_libs.sh
#
# Notes:
#   - Requires root privileges.
#   - For some codecs (x264, x265, lame), enable RPM Fusion repos first.

set -euo pipefail

LOG_FILE="/var/log/multimedia_libs_install.log"

log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log "Please run as root (sudo)."
        exit 1
    fi
}

install_packages() {
    local pkgs=("$@")
    log "Installing packages: ${pkgs[*]}"
    dnf install -y --skip-unavailable \
      "${pkgs[@]}" | tee -a "$LOG_FILE"
}

check_root
log "=== Starting multimedia library installation ==="

MULTIMEDIA_LIBS=(
    # Audio stacks
    alsa-lib-devel
    pulseaudio-libs-devel
    pipewire-devel
    jack-audio-connection-kit-devel

    # GStreamer core + base plugins
    gstreamer1-devel
    gstreamer1-plugins-base-devel
    gstreamer1-plugins-good-devel
    gstreamer1-plugins-bad-free-devel
    gstreamer1-plugins-ugly-free-devel
    gstreamer1-plugins-base-tools
    gstreamer1-plugins-good-extras
    gstreamer1-libav

    # Video acceleration
    libva-devel
    libvdpau-devel

    # Codec libs
    libvorbis-devel
    libogg-devel
    opus-devel
    theora-devel
    libvpx-devel
    dav1d-devel
    x264-devel
    x265-devel
    lame-devel
    flac-devel

    # DSP plugin APIs
    ladspa-devel
    lv2-devel
)

install_packages "${MULTIMEDIA_LIBS[@]}"

log "=== Multimedia library installation complete ==="
log "All actions logged to $LOG_FILE"

