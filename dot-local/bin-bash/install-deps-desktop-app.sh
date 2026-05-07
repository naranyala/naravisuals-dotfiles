#!/usr/bin/env bash
#
# install_desktop_basics.sh
# Modular Fedora desktop essentials + desktop app runtime dependencies
# Author: Fudzer's provisioning blueprint
# -----------------------------------------

set -euo pipefail

LOGFILE="${HOME}/install_desktop_basics.log"

log() {
    local msg="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" | tee -a "$LOGFILE"
}

pkg_install() {
    local pkg="$1"
    if rpm -q "$pkg" &>/dev/null; then
        log "SKIP: $pkg already installed"
    else
        log "INSTALL: $pkg"
        sudo dnf install -y "$pkg" >>"$LOGFILE" 2>&1
    fi
}

# === Original Essentials ===

install_dialog_tools() {
    log "=== Installing GUI dialog tools ==="
    for p in zenity yad kdialog; do
        pkg_install "$p"
    done
}

install_file_clipboard_utils() {
    log "=== Installing file & clipboard utilities ==="
    for p in xdg-utils gvfs gvfs-fuse xclip; do
        pkg_install "$p"
    done
}

install_theming() {
    log "=== Installing theming & icon essentials ==="
    for p in adwaita-gtk3-theme adwaita-icon-theme hicolor-icon-theme; do
        pkg_install "$p"
    done
}

install_multimedia() {
    log "=== Installing multimedia codecs & audio tools ==="
    for p in gstreamer1-plugins-good gstreamer1-plugins-bad-free gstreamer1-plugins-ugly-free pipewire-utils; do
        pkg_install "$p"
    done
}

install_notifications_automation() {
    log "=== Installing notifications & automation tools ==="
    for p in libnotify xdotool; do
        pkg_install "$p"
    done
}

# === New Desktop App Runtime Dependencies ===

install_gui_toolkits() {
    log "=== Installing GUI toolkit runtimes ==="
    for p in \
        gtk3 gtk4 \
        qt5-qtbase qt5-qttools qt5-qtx11extras \
        qt6-qtbase qt6-qttools \
        wxGTK3 \
        SDL2 SDL2_image SDL2_mixer SDL2_ttf; do
        pkg_install "$p"
    done
}

install_theme_integration() {
    log "=== Installing cross-DE theme integration ==="
    for p in \
        papirus-icon-theme \
        breeze-icon-theme \
        breeze-cursor-theme \
        qt5ct qt6ct; do
        pkg_install "$p"
    done
}

install_av_backends() {
    log "=== Installing audio/video backend libraries ==="
    for p in \
        ffmpeg-libs \
        gstreamer1-libav \
        gstreamer1-plugins-bad-freeworld \
        libva libvdpau \
        pulseaudio-utils alsa-utils; do
        pkg_install "$p"
    done
}

install_web_net_libs() {
    log "=== Installing network & web embedding libs ==="
    for p in \
        webkit2gtk4.1 \
        webkit2gtk3 \
        libsoup libsoup3 \
        curl \
        libssh libssh2 \
        avahi; do
        pkg_install "$p"
    done
}

install_print_pdf_libs() {
    log "=== Installing printing, scanning & PDF libs ==="
    for p in \
        cups-libs \
        poppler poppler-utils \
        ghostscript \
        sane-backends-libs; do
        pkg_install "$p"
    done
}

install_file_format_libs() {
    log "=== Installing file format & data handling libs ==="
    for p in \
        libarchive \
        libzip \
        libjpeg-turbo \
        libpng \
        libtiff \
        giflib; do
        pkg_install "$p"
    done
}

# === Optional: Fonts & i18n ===
install_fonts_i18n() {
    log "=== Installing fonts & i18n support ==="
    for p in \
        google-noto-sans-fonts \
        google-noto-serif-fonts \
        google-noto-emoji-fonts \
        dejavu-sans-fonts \
        dejavu-serif-fonts \
        ibus ibus-anthy ibus-m17n; do
        pkg_install "$p"
    done
}

# === Main ===
main() {
    log "=== Starting Fedora desktop essentials & runtime dependencies installation ==="
    install_dialog_tools
    install_file_clipboard_utils
    install_theming
    install_multimedia
    install_notifications_automation
    install_gui_toolkits
    install_theme_integration
    install_av_backends
    install_web_net_libs
    install_print_pdf_libs
    install_file_format_libs
    install_fonts_i18n
    log "=== Installation complete ==="
}

main "$@"

