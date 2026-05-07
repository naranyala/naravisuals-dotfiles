#!/usr/bin/env bash

# Fedora Audio Programming + GUI Tools Setup
# Make executable: chmod +x install_audio_full.sh
# Run: ./install_audio_full.sh

set -e

echo "Updating system..."
sudo dnf upgrade --refresh -y

echo "Installing core audio backends..."
sudo dnf install -y --skip-unavailable \
    pipewire \
    pipewire-jack-audio-connection-kit \
    jack-audio-connection-kit \
    alsa-utils \
    pulseaudio-utils

echo "Installing development libraries..."
sudo dnf install -y --skip-unavailable \
    portaudio-devel \
    rtaudio-devel \
    lv2-devel \
    ladspa-devel \
    fluidsynth-devel \
    gstreamer1-devel \
    gstreamer1-plugins-base-devel \
    gstreamer1-plugins-good \
    gstreamer1-plugins-bad-free \
    gstreamer1-plugins-ugly

echo "Installing audio programming environments..."
sudo dnf install -y --skip-unavailable \
    csound \
    supercollider \
    puredata \
    chuck \
    sox

echo "Installing DAWs and creative tools..."
sudo dnf install -y --skip-unavailable \
    ardour \
    qtractor \
    lmms \
    rosegarden \
    musescore \
    hydrogen \
    audacity

echo "Installing synths, samplers & effects..."
sudo dnf install -y --skip-unavailable \
    qsynth \
    guitarix \
    calf-plugins \
    zam-plugins \
    sooperlooper \
    yoshimi \
    zynaddsubfx

echo "Installing audio utilities & GUI helpers..."
sudo dnf install -y --skip-unavailable \
    qjackctl \
    pavucontrol \
    carla \
    easytag \
    kid3 \
    vlc

echo "All done! 🎶 Your Fedora system is now loaded with audio dev tools and creative apps."

