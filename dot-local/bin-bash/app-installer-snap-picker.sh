#!/usr/bin/env bash
set -e

# Detect package manager
if command -v apt &>/dev/null; then
    PKG_MGR="apt"
    INSTALL_CMD="sudo apt update && sudo apt install -y"
elif command -v dnf &>/dev/null; then
    PKG_MGR="dnf"
    INSTALL_CMD="sudo dnf -y install"
else
    echo "Unsupported package manager. Please install snapd manually."
    exit 1
fi

# Ensure snapd is installed
if ! command -v snap &>/dev/null; then
    echo "Installing snapd..."
    eval "$INSTALL_CMD snapd"

    # Enable snapd service
    sudo systemctl enable --now snapd.socket

    # On Fedora, link /snap
    if [ "$PKG_MGR" = "dnf" ]; then
        sudo ln -s /var/lib/snapd/snap /snap || true
    fi
fi

declare -A apps=(
    ["libreoffice"]="Office suite"
    ["onlyoffice-desktopeditors"]="MS Office-compatible editors"
    ["notion-snap"]="Notes & project management"
    ["code --classic"]="VS Code IDE"
    ["pycharm-community --classic"]="Python IDE"
    ["postman"]="API testing"
    ["gimp"]="Image editor"
    ["inkscape"]="Vector graphics"
    ["blender --classic"]="3D modeling"
    ["spotify"]="Music streaming"
    ["vlc"]="Media player"
    ["audacity"]="Audio editing"
    ["discord"]="Chat & community"
    ["telegram-desktop"]="Messaging"
    ["slack"]="Team collaboration"
    ["chromium"]="Web browser"
    ["brave"]="Privacy browser"
    ["snap-store"]="Snap GUI store"
    ["bitwarden"]="Password manager"
    ["keepassxc"]="Local password vault"
    ["obs-studio"]="Streaming & recording"
    ["krita"]="Digital painting"
    ["darktable"]="RAW photo editing"
    ["kdenlive"]="Video editing"
)

echo "=== Essential Apps Installer (Snap) ==="
echo "Select apps to install (space to select, enter to confirm):"

# Build menu
choices=()
for app in "${!apps[@]}"; do
    choices+=("$app" "${apps[$app]}" off)
done

# Ensure whiptail is installed
if ! command -v whiptail &>/dev/null; then
    echo "Installing whiptail for menu..."
    if [ "$PKG_MGR" = "apt" ]; then
        eval "$INSTALL_CMD whiptail"
    else
        eval "$INSTALL_CMD newt"
    fi
fi

# Show selection menu
selected=$(whiptail --title "Snap App Picker" \
    --checklist "Choose apps to install:" 20 78 10 \
    "${choices[@]}" 3>&1 1>&2 2>&3)

# Install selected apps
for app in $selected; do
    clean_app=$(echo "$app" | tr -d '"')
    echo "Installing $clean_app..."
    sudo snap install $clean_app
done

echo "=== All selected apps installed! ==="

