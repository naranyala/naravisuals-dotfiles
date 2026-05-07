#!/usr/bin/env bash
set -euo pipefail

# Require sudo
if [[ $EUID -ne 0 ]]; then
    echo -e "\e[1;31m[ERROR]\e[0m This script must be run as root. Try: sudo $0"
    exit 1
fi

STORE_DIR="/nix/store"
DESKTOP_DIR="/usr/share/applications"
ICON_DIR="/usr/share/icons/hicolor/128x128/apps"
LOG_FILE="$HOME/nix-desktopify.log"

mkdir -p "$DESKTOP_DIR" "$ICON_DIR"
echo "# Desktop entries generated — $(date)" > "$LOG_FILE"

log() { echo -e "\e[1;32m[DESKTOP]\e[0m $*"; echo "[DESKTOP] $*" >> "$LOG_FILE"; }

for pkg in "$STORE_DIR"/*; do
    [[ -d "$pkg/bin" ]] || continue

    for bin in "$pkg/bin/"*; do
        [[ -x "$bin" && ! -d "$bin" ]] || continue
        name=$(basename "$bin")
        exec_path="$bin"
        desktop_file="$DESKTOP_DIR/${name}.desktop"

        # Try to find icon (optional)
        icon_path=""
        for icon_candidate in "$pkg/share/icons" "$pkg/share/pixmaps" "$pkg/share/$name/icons"; do
            [[ -d "$icon_candidate" ]] || continue
            icon_file=$(find "$icon_candidate" -type f \( -name '*.png' -o -name '*.svg' \) | head -n1 || true)
            if [[ -n "$icon_file" ]]; then
                cp "$icon_file" "$ICON_DIR/${name}.png"
                icon_path="${name}.png"
                break
            fi
        done

        # Create .desktop entry
        cat > "$desktop_file" <<EOF
[Desktop Entry]
Name=$name
Exec=$exec_path
Icon=${icon_path:-application-x-executable}
Type=Application
Terminal=false
Categories=Utility;
EOF

        chmod 644 "$desktop_file"
        log "$name → $desktop_file"
    done
done

update-desktop-database "$DESKTOP_DIR" || true
echo -e "\n\e[1;34m[INFO]\e[0m Desktop entries saved to: $DESKTOP_DIR"
echo -e "\e[1;34m[INFO]\e[0m Icons saved to: $ICON_DIR"
echo -e "\e[1;34m[INFO]\e[0m Log saved to: $LOG_FILE"
