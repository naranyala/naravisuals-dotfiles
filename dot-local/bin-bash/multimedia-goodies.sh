#!/usr/bin/env bash
#
# multimedia_setup.sh — Debian-based multimedia installer with robust error handling
#
set -euo pipefail

GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

LOG_FILE="$HOME/multimedia_install.log"
FAILED_PACKAGES=()

trap 'echo -e "\n${RED}Installation interrupted by user.${RESET}"; exit 130' INT

log_and_run() {
    local description="$1"
    shift
    echo -e "${CYAN}${description}...${RESET}"
    if ! "$@" >>"$LOG_FILE" 2>&1; then
        echo -e "${RED}Failed: ${description}${RESET}"
        FAILED_PACKAGES+=("${description}")
    fi
}

update_system() {
    log_and_run "Updating package lists" sudo apt update
}

install_packages() {
    local desc="$1"
    shift
    log_and_run "Installing $desc" sudo apt install -y "$@"
}

# --- Tier A: Core multimedia libraries & runtime ---
install_core_libs() {
    install_packages "core multimedia runtime/libs" \
        ffmpeg sox mediainfo \
        libavcodec-extra libasound2 libpulse0 \
        jackd2 libjack-jackd2-dev \
        libsndfile1 libsamplerate0 libflac-dev \
        libvorbis-dev libopus-dev libmp3lame-dev \
        libtheora-dev libx264-dev libx265-dev \
        gstreamer1.0-tools \
        gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
        gstreamer1.0-libav
}

# --- Tier B: Lightweight CLI utilities ---
install_cli_utils() {
    install_packages "CLI multimedia utilities" \
        pavucontrol flac vorbis-tools opus-tools lame \
        mkvtoolnix mkvtoolnix-gui \
        imagemagick exiftool qrencode
}

# --- Tier C: Specialized audio/video stack ---
install_specialized_stack() {
    install_packages "specialized audio/video stack" \
        ardour qtractor hydrogen lmms carla \
        calf-plugins invada-studio-plugins-lv2 \
        swh-plugins zam-plugins guitarix jalv \
        kdenlive shotcut
}

# --- Tier D: Full studio applications ---
install_full_studio() {
    install_packages "full studio suite" \
        blender inkscape krita darktable gimp \
        obs-studio handbrake
}

# --- Menu ---
update_system
echo -e "${YELLOW}Select installation level:${RESET}"
echo "1) Core multimedia runtime/libs only"
echo "2) Core + CLI utilities"
echo "3) Core + CLI + specialized stack"
echo "4) Full studio (all tiers)"
read -rp "Enter choice [1-4]: " choice

case "$choice" in
    1) install_core_libs ;;
    2) install_core_libs; install_cli_utils ;;
    3) install_core_libs; install_cli_utils; install_specialized_stack ;;
    4) install_core_libs; install_cli_utils; install_specialized_stack; install_full_studio ;;
    *) echo "Invalid choice."; exit 1 ;;
esac

# --- Final report ---
if [ ${#FAILED_PACKAGES[@]} -gt 0 ]; then
    echo -e "${RED}Some packages failed to install:${RESET}"
    for pkg in "${FAILED_PACKAGES[@]}"; do
        echo " - $pkg"
    done
    echo -e "See ${YELLOW}$LOG_FILE${RESET} for details."
    exit 1
else
    echo -e "${GREEN}All selected packages installed successfully!${RESET}"
    echo "Log saved to $LOG_FILE"
fi

