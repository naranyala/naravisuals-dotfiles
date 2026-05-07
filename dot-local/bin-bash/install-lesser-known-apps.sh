#!/usr/bin/env bash

# Lesser-known Linux apps from niche DEs/WMs
# Supports Debian/Ubuntu (apt) and Fedora (dnf)

DEBIAN_APPS=(
    # IceWM
    # icewm icewm-themes arandr volumeicon-alsa lxpolkit
    # icewm icewm-themes 
    arandr volumeicon-alsa lxpolkit
    # Fluxbox
    fluxbox fbpanel idesk
    # Enlightenment
    # enlightenment ephoto terminology
    ephoto terminology
    # LXQt
    pcmanfm-qt lximage-qt lxappearance qterminal
    # MATE
    caja pluma engrampa atril
    # Cinnamon
    nemo pix xed xreader
    # Budgie
    # budgie-desktop-view budgie-control-center plank
    budgie-control-center plank
    # Pantheon
    pantheon-files code switchboard
    # UKUI
    peony ukui-control-center ukui-panel
)

FEDORA_APPS=(
    # IceWM
    icewm icewm-themes arandr volumeicon lxpolkit
    # Fluxbox
    fluxbox fbpanel idesk
    # Enlightenment
    # enlightenment ephoto terminology
    ephoto terminology
    # LXQt
    pcmanfm-qt lximage-qt lxappearance qterminal
    # MATE
    caja pluma engrampa atril
    # Cinnamon
    nemo pix xed xreader
    # Budgie
    # budgie-desktop-view budgie-control-center plank
    budgie-control-center plank
    # Pantheon
    pantheon-files elementary-code switchboard
    # UKUI
    peony ukui-control-center ukui-panel
)

if command -v apt >/dev/null 2>&1; then
    PKG_MANAGER="apt"
    PKG_LIST=("${DEBIAN_APPS[@]}")
elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
    PKG_LIST=("${FEDORA_APPS[@]}")
else
    echo "❌ Unsupported distro: no apt or dnf found."
    exit 1
fi

echo "🔄 Updating package lists..."
if [ "$PKG_MANAGER" = "apt" ]; then
    sudo apt update -y
else
    sudo dnf check-update -y || true
fi

echo "📦 Installing apps..."
for app in "${PKG_LIST[@]}"; do
    echo "➡ Installing: $app"
    if [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt install -y "$app"
    else
        sudo dnf install -y "$app"
    fi
done

echo "🧹 Cleaning up..."
if [ "$PKG_MANAGER" = "apt" ]; then
    sudo apt autoremove -y
    sudo apt clean
else
    sudo dnf autoremove -y
    sudo dnf clean all
fi

echo "✅ All selected apps installed!"

