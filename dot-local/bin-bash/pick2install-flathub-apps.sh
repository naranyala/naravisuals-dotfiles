#!/usr/bin/env bash

# Ensure whiptail is installed
if ! command -v whiptail &> /dev/null; then
    echo "Please install 'whiptail' first (Debian/Ubuntu: sudo apt install whiptail)"
    exit 1
fi

# Define apps in "tag description status" format
OPTIONS=(
    # --- Core Utilities ---
    "com.github.tchx84.Flatseal" "Flatseal - Manage Flatpak permissions" OFF
    "org.gnome.baobab"           "Baobab - Disk usage analyzer" OFF
    "org.gnome.FileRoller"       "File Roller - Archive manager" OFF
    "org.gnome.Calculator"       "Calculator" OFF
    "org.gnome.Characters"       "Character Map" OFF

    # --- Browsers & Communication ---
    "org.mozilla.firefox"        "Firefox - Web browser" OFF
    "org.chromium.Chromium"      "Chromium - Web browser" OFF
    "org.signal.Signal"          "Signal - Secure messaging" OFF
    "com.discordapp.Discord"     "Discord - Chat & voice" OFF
    "org.telegram.desktop"       "Telegram Desktop" OFF
    "org.mozilla.Thunderbird"    "Thunderbird - Email client" OFF

    # --- Office & Productivity ---
    "org.libreoffice.LibreOffice" "LibreOffice - Office suite" OFF
    "org.onlyoffice.desktopeditors" "OnlyOffice - MS Office compatible suite" OFF
    "net.cozic.joplin_desktop"   "Joplin - Notes & sync" OFF
    "org.gnome.Evince"           "Evince - PDF viewer" OFF
    "org.kde.okular"             "Okular - Document viewer" OFF

    # --- Creative & Media ---
    "org.gimp.GIMP"              "GIMP - Image editor" OFF
    "org.inkscape.Inkscape"      "Inkscape - Vector graphics" OFF
    "org.blender.Blender"        "Blender - 3D creation suite" OFF
    "org.kde.krita"              "Krita - Digital painting" OFF
    "org.darktable.Darktable"    "Darktable - RAW photo editor" OFF
    "org.videolan.VLC"           "VLC - Media player" OFF
    "io.github.celluloid_player.Celluloid" "Celluloid - Lightweight video player" OFF
    "com.spotify.Client"         "Spotify - Music streaming" OFF
    "com.obsproject.Studio"      "OBS Studio - Streaming/recording" OFF

    # --- Security & Backup ---
    "org.keepassxc.KeePassXC"    "KeePassXC - Password manager" OFF
    "org.veracrypt.VeraCrypt"    "VeraCrypt - Disk encryption" OFF
    "org.gnome.DejaDup"          "Déjà Dup - Backup tool" OFF
    "com.rclone.rclone"          "Rclone - Cloud sync" OFF

    # --- Developer Tools ---
    "com.visualstudio.code"      "VS Code - IDE" OFF
    "com.vscodium.codium"        "VSCodium - Open-source VS Code" OFF
    "org.geany.Geany"            "Geany - Lightweight IDE" OFF
    "io.dbeaver.DBeaverCommunity" "DBeaver - Database manager" OFF
    "com.getpostman.Postman"     "Postman - API testing" OFF
)

# Show checklist
CHOICES=$(whiptail --title "Flathub Essentials Installer" \
    --checklist "Select apps to install (SPACE to toggle, ENTER to confirm):" 25 78 18 \
    "${OPTIONS[@]}" 3>&1 1>&2 2>&3)

# If user pressed Cancel
if [ $? -ne 0 ]; then
    echo "Installation cancelled."
    exit 1
fi

# Install selected apps
for choice in $CHOICES; do
    app=$(echo $choice | tr -d '"')  # remove quotes
    echo "Installing $app..."
    flatpak install -y flathub "$app"
done

echo "✅ All selected apps installed!"

