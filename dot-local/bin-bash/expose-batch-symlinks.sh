#!/usr/bin/env bash
set -euo pipefail

# === Config ===
SOURCE_BIN_DIR="${1:-}"
TARGET_LINK_DIR="/usr/local/bin"
LOG_FILE="/var/log/symlink-bin.log"

# === Functions ===
log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"
}

require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        log "ERROR: This script must be run as root. Use sudo."
        exit 1
    fi
}

validate_args() {
    if [[ -z "$SOURCE_BIN_DIR" ]]; then
        log "ERROR: No source directory provided."
        echo "Usage: sudo $0 /path/to/custom/bin"
        exit 2
    fi
}

validate_source() {
    if [[ ! -d "$SOURCE_BIN_DIR" ]]; then
        log "ERROR: Source directory '$SOURCE_BIN_DIR' does not exist."
        exit 3
    fi
}

link_binaries() {
    local linked=0 skipped=0
    for file in "$SOURCE_BIN_DIR"/*; do
        [[ -x "$file" && ! -d "$file" ]] || continue
        filename="$(basename "$file")"
        target="$TARGET_LINK_DIR/$filename"

        if [[ -e "$target" && ! -L "$target" ]]; then
            log "SKIP: '$target' exists and is not a symlink. Manual review needed."
            ((skipped++))
            continue
        fi

        ln -sf "$file" "$target"
        log "Linked '$file' → '$target'"
        ((linked++))
    done

    log "Summary: $linked linked, $skipped skipped."
}

# === Main ===
log "=== Starting symlink-bin script ==="
require_root
validate_args
validate_source
link_binaries
log "=== Done ==="
