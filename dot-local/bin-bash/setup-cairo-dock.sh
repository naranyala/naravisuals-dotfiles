#!/usr/bin/env bash
#
# cairo-dock-setup.sh
# Simple installer/launcher for Cairo Dock on Fedora Linux
#

set -euo pipefail

# --- Functions ---
install_cairo_dock() {
    echo "[*] Installing Cairo Dock..."
    sudo dnf -y install cairo-dock
}

launch_cairo_dock() {
    echo "[*] Launching Cairo Dock..."
    # Try OpenGL mode first; fallback to Cairo mode if it fails
    if cairo-dock -o &>/dev/null & then
        echo "[+] Cairo Dock started in OpenGL mode."
    else
        echo "[!] OpenGL mode failed, starting in Cairo mode..."
        cairo-dock -c &
    fi
}

setup_autostart() {
    echo "[*] Setting up autostart..."
    AUTOSTART_DIR="$HOME/.config/autostart"
    mkdir -p "$AUTOSTART_DIR"

    cat > "$AUTOSTART_DIR/cairo-dock.desktop" <<EOF
[Desktop Entry]
Type=Application
Exec=cairo-dock -o
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Cairo Dock
Comment=Start Cairo Dock at login
EOF

    echo "[+] Autostart entry created at $AUTOSTART_DIR/cairo-dock.desktop"
}

# --- Main ---
echo "=== Cairo Dock Setup Script ==="
install_cairo_dock
launch_cairo_dock

# Uncomment the next line if you want it to autostart at login
# setup_autostart

echo "=== Done! ==="

