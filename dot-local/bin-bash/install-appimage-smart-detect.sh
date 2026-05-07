
#!/usr/bin/env bash
set -euo pipefail

### CONFIG ###
APPDIR="$HOME/Applications"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"
TEMP_DIR="$(mktemp -d)"
APPIMAGE_PATH=""
APP_NAME=""
ICON_PATH=""
USE_PROMPT=false

### FUNCTIONS ###
log()   { echo -e "\e[1;32m[INFO]\e[0m $*"; }
warn()  { echo -e "\e[1;33m[WARN]\e[0m $*"; }
error() { echo -e "\e[1;31m[ERROR]\e[0m $*"; }

usage() {
    echo "Usage: $0 /path/to/AppImage [--prompt]"
    echo "  --prompt   Prompt for missing metadata manually"
    exit 1
}

extract_metadata() {
    log "Extracting metadata from AppImage..."
    if ! command -v bsdtar &>/dev/null; then
        error "bsdtar is required to extract AppImage contents."
        exit 1
    fi

    bsdtar -xf "$APPIMAGE_PATH" -C "$TEMP_DIR" || warn "Failed to extract AppImage"

    # Try to find .desktop file
    local desktop_file
    desktop_file=$(find "$TEMP_DIR" -name '*.desktop' | head -n 1 || true)
    if [[ -n "$desktop_file" ]]; then
        APP_NAME=$(grep -E '^Name=' "$desktop_file" | head -n1 | cut -d= -f2)
        ICON_NAME=$(grep -E '^Icon=' "$desktop_file" | head -n1 | cut -d= -f2)
        log "Detected app name: $APP_NAME"
        log "Detected icon name: $ICON_NAME"

        # Try to find icon file
        ICON_PATH=$(find "$TEMP_DIR" -name "${ICON_NAME}.*" | head -n1 || true)
        if [[ -n "$ICON_PATH" ]]; then
            cp "$ICON_PATH" "$ICON_DIR/${APP_NAME}.png"
            ICON_PATH="$ICON_DIR/${APP_NAME}.png"
            log "Icon saved to $ICON_PATH"
        else
            warn "Icon not found in AppImage."
        fi
    else
        warn "No .desktop file found inside AppImage."
    fi
}

prompt_metadata() {
    read -rp "Enter application name: " APP_NAME
    read -rp "Enter path to icon (or leave blank): " ICON_PATH
}

create_shortcut() {
    local shortcut="$DESKTOP_DIR/${APP_NAME,,}.desktop"
    log "Creating desktop shortcut at $shortcut"

    cat > "$shortcut" <<EOF
[Desktop Entry]
Name=$APP_NAME
Exec=$APPDIR/$(basename "$APPIMAGE_PATH")
Icon=${ICON_PATH:-application-x-executable}
Type=Application
Categories=Utility;
EOF

    chmod +x "$shortcut"
    update-desktop-database "$DESKTOP_DIR" || true
    log "Shortcut created and desktop database updated."
}

main() {
    if [[ $# -lt 1 ]]; then usage; fi

    APPIMAGE_PATH="$1"
    [[ "$APPIMAGE_PATH" != *.AppImage ]] && error "File must be an AppImage." && exit 1
    [[ ! -f "$APPIMAGE_PATH" ]] && error "File not found: $APPIMAGE_PATH" && exit 1

    shift
    [[ "${1:-}" == "--prompt" ]] && USE_PROMPT=true

    mkdir -p "$APPDIR" "$DESKTOP_DIR" "$ICON_DIR"
    cp "$APPIMAGE_PATH" "$APPDIR/"
    chmod +x "$APPDIR/$(basename "$APPIMAGE_PATH")"
    log "AppImage copied to $APPDIR and made executable."

    extract_metadata

    if [[ -z "$APP_NAME" ]] || "$USE_PROMPT"; then
        prompt_metadata
    fi

    create_shortcut
    log "Done. You can now launch '$APP_NAME' from your application menu."
}

main "$@"
