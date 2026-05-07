#!/bin/bash

set -euo pipefail

echo "📦 Installing Flatpak and ONLYOFFICE Desktop Editors..."

# Check and install Flatpak
if ! command -v flatpak &> /dev/null; then
    echo "🔧 Flatpak not found. Installing..."
    sudo pacman -S --noconfirm flatpak
fi

# Add Flathub repository if missing
if ! flatpak remote-list | grep -q flathub; then
    echo "🌐 Adding Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Install ONLYOFFICE Desktop Editors
echo "🚀 Installing ONLYOFFICE Desktop Editors via Flatpak..."
if flatpak install -y flathub org.onlyoffice.desktopeditors; then
    echo "✅ ONLYOFFICE installed successfully."
else
    echo "❌ Installation failed. Please check your Flatpak setup."
    exit 1
fi

# Verify installation
if ! flatpak info org.onlyoffice.desktopeditors &> /dev/null; then
    echo "❌ ONLYOFFICE not found after installation. Aborting shortcut creation."
    exit 1
fi

# Create desktop shortcut
DESKTOP_FILE="$HOME/.local/share/applications/onlyoffice.desktop"
echo "🖼️ Creating desktop shortcut at $DESKTOP_FILE..."
mkdir -p "$(dirname "$DESKTOP_FILE")"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=ONLYOFFICE Desktop Editors
Comment=Open and edit documents, spreadsheets, and presentations
Exec=flatpak run org.onlyoffice.desktopeditors
Icon=org.onlyoffice.desktopeditors
Terminal=false
Type=Application
Categories=Office;WordProcessor;Spreadsheet;Presentation;
EOF

echo "🔗 Shortcut created! You can now launch ONLYOFFICE from your application menu."

