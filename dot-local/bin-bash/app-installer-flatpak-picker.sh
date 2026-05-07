#!/usr/bin/env bash
set -e

# === Detect package manager ===
if command -v apt &>/dev/null; then
    PKG_MGR="apt"
    INSTALL_CMD="sudo apt update && sudo apt install -y"
elif command -v dnf &>/dev/null; then
    PKG_MGR="dnf"
    INSTALL_CMD="sudo dnf -y install"
else
    echo "Unsupported package manager. Please install Flatpak manually."
    exit 1
fi

# === Ensure Flatpak is installed ===
if ! command -v flatpak &>/dev/null; then
    echo "Installing Flatpak..."
    eval "$INSTALL_CMD flatpak"
fi

# === Enable Flathub if not already ===
if ! flatpak remote-list | grep -q flathub; then
    echo "Adding Flathub repository..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# === App list ===
declare -A apps=(
    ["org.libreoffice.LibreOffice"]="Office suite"
    ["org.onlyoffice.desktopeditors"]="MS Office-compatible editors"
    ["org.standardnotes.standardnotes"]="Encrypted notes"
    ["com.visualstudio.code"]="VS Code IDE"
    ["com.jetbrains.PyCharm-Community"]="Python IDE"
    ["com.getpostman.Postman"]="API testing"
    ["org.gnome.Builder"]="GNOME IDE"
    ["org.gimp.GIMP"]="Image editor"
    ["org.inkscape.Inkscape"]="Vector graphics"
    ["org.blender.Blender"]="3D modeling"
    ["org.kde.krita"]="Digital painting"
    ["org.darktable.Darktable"]="RAW photo editing"
    ["org.kde.kdenlive"]="Video editing"
    ["net.scribus.Scribus"]="Desktop publishing"
    ["org.videolan.VLC"]="Media player"
    ["org.audacityteam.Audacity"]="Audio editing"
    ["io.github.celluloid_player.Celluloid"]="Video player"
    ["org.gnome.Lollypop"]="Music player"
    ["org.telegram.desktop"]="Messaging"
    ["org.signal.Signal"]="Secure messaging"
    ["im.riot.Riot"]="Matrix client"
    ["org.chromium.Chromium"]="Web browser"
    ["com.brave.Browser"]="Privacy browser"
    ["com.obsproject.Studio"]="Streaming & recording"
    ["com.bitwarden.desktop"]="Password manager"
    ["org.keepassxc.KeePassXC"]="Local password vault"
    ["com.github.tchx84.Flatseal"]="Flatpak permissions manager"
    ["org.gnome.tweaks"]="GNOME customization"
    ["org.filezillaproject.Filezilla"]="FTP client"
    ["com.spotify.Client"]="Music Streaming"
)

# === Build whiptail menu choices ===
choices=()
for app in "${!apps[@]}"; do
    choices+=("$app" "${apps[$app]}" off)
done

# === Ensure whiptail is installed ===
if ! command -v whiptail &>/dev/null; then
    echo "Installing whiptail..."
    if [ "$PKG_MGR" = "apt" ]; then
        eval "$INSTALL_CMD whiptail"
    else
        eval "$INSTALL_CMD newt"
    fi
fi

# === Show selection menu ===
selected=$(whiptail --title "Verified Flathub App Picker" \
    --checklist "Choose apps to install:" 25 78 15 \
    "${choices[@]}" 3>&1 1>&2 2>&3)

# === Directory for .desktop files ===
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

# === Install selected apps & create launchers ===
for app in $selected; do
    clean_app=$(echo "$app" | tr -d '"')
    echo "Installing $clean_app..."
    flatpak install -y flathub "$clean_app"

    desktop_file="$DESKTOP_DIR/${clean_app}.desktop"
    cat > "$desktop_file" <<EOF
[Desktop Entry]
Name=${apps[$clean_app]}
Exec=flatpak run $clean_app
Type=Application
Terminal=false
EOF

    chmod +x "$desktop_file"
    echo "Created launcher: $desktop_file"
done

echo "=== All selected verified apps installed and launchers created! ==="

