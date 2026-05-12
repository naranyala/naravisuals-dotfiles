#!/bin/bash

set -e

# Choose audio stack: "pipewire" or "pulseaudio"
AUDIO_STACK="pipewire"

install_spotify_apt() {
    echo "Detected apt package manager (Debian/Ubuntu)."
    # Import new Spotify GPG key
    curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg \
        | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg

    # Add Spotify repository
    echo "deb http://repository.spotify.com stable non-free" \
        | sudo tee /etc/apt/sources.list.d/spotify.list

    # Update and install
    sudo apt update || true
    if sudo apt install -y spotify-client; then
        echo "Spotify installed successfully via apt."
    else
        echo "Spotify installation via apt failed. Falling back to Snap."
        install_spotify_snap
    fi

    # Install audio stack
    if [ "$AUDIO_STACK" = "pipewire" ]; then
        echo "Installing PipeWire audio stack..."
        sudo apt install -y pipewire pipewire-alsa pipewire-jack \
            pipewire-pulse libspa-0.2-bluetooth ffmpeg sox
    else
        echo "Installing PulseAudio audio stack..."
        sudo apt install -y pulseaudio alsa-utils jackd2 \
            libasound2-dev libpulse-dev libjack-jackd2-dev ffmpeg sox
    fi
}

install_spotify_dnf() {
    echo "Detected dnf package manager (Fedora/RHEL)."
    # Enable RPM Fusion repositories
    sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    # Install Spotify via lpf
    sudo dnf install -y lpf-spotify-client
    sudo usermod -a -G lpf $USER
    echo "Log out and back in, then run: lpf-spotify-client to build and install Spotify."

    # Install audio stack
    if [ "$AUDIO_STACK" = "pipewire" ]; then
        echo "Installing PipeWire audio stack..."
        sudo dnf install -y pipewire pipewire-alsa pipewire-jack \
            pipewire-pulseaudio ffmpeg sox
    else
        echo "Installing PulseAudio audio stack..."
        sudo dnf install -y pulseaudio alsa-utils jack-audio-connection-kit \
            pulseaudio-libs-devel alsa-lib-devel jack-audio-connection-kit-devel ffmpeg sox
    fi
}

install_spotify_snap() {
    echo "Installing Spotify via Snap..."
    sudo snap install spotify
}

install_spotify_flatpak() {
    echo "Installing Spotify via Flatpak..."
    flatpak install -y flathub com.spotify.Client
}

# Detect package manager
if command -v apt >/dev/null 2>&1; then
    install_spotify_apt
elif command -v dnf >/dev/null 2>&1; then
    install_spotify_dnf
elif command -v snap >/dev/null 2>&1; then
    install_spotify_snap
elif command -v flatpak >/dev/null 2>&1; then
    install_spotify_flatpak
else
    echo "No supported package manager detected (apt, dnf, snap, or flatpak)."
    exit 1
fi

