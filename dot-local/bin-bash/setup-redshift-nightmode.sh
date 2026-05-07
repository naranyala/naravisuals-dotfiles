#!/usr/bin/env bash
#
# night-filter-setup.sh
# Installer and launcher for Redshift (night screen filter) on Fedora
#

set -euo pipefail

# --- Functions ---
install_redshift() {
    echo "[*] Installing Redshift..."
    sudo dnf -y install redshift
}

launch_redshift() {
    echo "[*] Launching Redshift..."
    # Example: 6500K daytime, 3500K nighttime, auto location
    redshift -l 0:0 -t 6500:3500 &
    echo "[+] Redshift started with day=6500K, night=3500K"
}

toggle_warm_mode() {
    echo "[*] Forcing warm mode (4000K)..."
    redshift -O 4000
}

reset_screen() {
    echo "[*] Resetting screen color..."
    redshift -x
}

setup_autostart() {
    echo "[*] Setting up autostart..."
    AUTOSTART_DIR="$HOME/.config/autostart"
    mkdir -p "$AUTOSTART_DIR"

    cat > "$AUTOSTART_DIR/redshift.desktop" <<EOF
[Desktop Entry]
Type=Application
Exec=redshift -l 0:0 -t 6500:3500
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Redshift
Comment=Adjust screen color temperature automatically
EOF

    echo "[+] Autostart entry created at $AUTOSTART_DIR/redshift.desktop"
}

# --- Main ---
echo "=== Night Screen Filter Setup ==="
install_redshift
launch_redshift

# Uncomment if you want autostart enabled by default
# setup_autostart

echo "=== Done! Use toggle_warm_mode or reset_screen as needed ==="

