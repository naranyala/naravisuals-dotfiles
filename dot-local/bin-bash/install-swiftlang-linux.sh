#!/usr/bin/env bash
set -euo pipefail

# === CONFIGURATION ===
SWIFT_DL_DIR="$HOME/Downloads"
SWIFT_ARCHIVE="swiftly-$(uname -m).tar.gz"
SWIFT_URL="https://download.swift.org/swiftly/linux/$SWIFT_ARCHIVE"
SWIFTLY_HOME="${SWIFTLY_HOME_DIR:-$HOME/.local/share/swiftly}"
SWIFTLY_BIN_DIR="$SWIFTLY_HOME/bin"

# === FUNCTIONS ===
error_exit() {
    echo "❌ Error: $1" >&2
    exit 1
}

info() {
    echo "➡ $1"
}

# === MAIN SCRIPT ===
info "Creating download directory..."
mkdir -p "$SWIFT_DL_DIR" || error_exit "Failed to create $SWIFT_DL_DIR"

info "Downloading Swiftly from $SWIFT_URL..."
if ! curl -fL -o "$SWIFT_DL_DIR/$SWIFT_ARCHIVE" "$SWIFT_URL"; then
    error_exit "Download failed. Check your internet connection or URL."
fi

info "Extracting archive..."
if ! tar -xzf "$SWIFT_DL_DIR/$SWIFT_ARCHIVE" -C "$SWIFT_DL_DIR"; then
    error_exit "Extraction failed."
fi

# Detect extracted folder automatically
EXTRACTED_DIR=$(tar -tzf "$SWIFT_DL_DIR/$SWIFT_ARCHIVE" | head -1 | cut -f1 -d"/")
SWIFTLY_EXEC="$SWIFT_DL_DIR/$EXTRACTED_DIR/swiftly"

if [[ ! -x "$SWIFTLY_EXEC" ]]; then
    # Try searching for the binary anywhere inside the extracted folder
    SWIFTLY_EXEC=$(find "$SWIFT_DL_DIR/$EXTRACTED_DIR" -type f -name swiftly -perm -u+x | head -n 1 || true)
    [[ -z "$SWIFTLY_EXEC" ]] && error_exit "Swiftly executable not found in extracted folder."
fi

info "Initializing Swiftly..."
if ! "$SWIFTLY_EXEC" init --quiet-shell-followup; then
    error_exit "Swiftly initialization failed."
fi

info "Adding Swiftly bin path to ~/.bashrc..."
if ! grep -q "$SWIFTLY_BIN_DIR" "$HOME/.bashrc"; then
    echo "export PATH=\"$SWIFTLY_BIN_DIR:\$PATH\"" >> "$HOME/.bashrc" \
        || error_exit "Failed to update ~/.bashrc"
fi

info "Sourcing Swiftly environment for current session..."
if [[ -f "$SWIFTLY_HOME/env.sh" ]]; then
    # shellcheck disable=SC1090
    . "$SWIFTLY_HOME/env.sh"
else
    error_exit "Swiftly environment file not found."
fi

hash -r
info "✅ Swiftly installation complete!"
echo "   Restart your shell or run: source ~/.bashrc"

