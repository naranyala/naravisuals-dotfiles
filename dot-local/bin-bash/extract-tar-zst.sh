
#!/usr/bin/env bash
set -euo pipefail

PKG="$1"
TARGET_DIR="${2:-./extracted}"
LOGFILE="./extract_pkg.log"

log() {
    echo "[$(date +'%F %T')] $*" | tee -a "$LOGFILE"
}

check_tools() {
    if ! command -v bsdtar &>/dev/null; then
        log "✗ Missing: bsdtar"
        log "💡 Try: sudo apt install bsdtar"
        exit 1
    fi
    log "✓ bsdtar is available"
}

extract_pkg() {
    mkdir -p "$TARGET_DIR"
    log "📦 Extracting $PKG to $TARGET_DIR..."
    bsdtar -xf "$PKG" -C "$TARGET_DIR"
    log "✅ Extraction complete"
}

main() {
    if [[ ! -f "$PKG" ]]; then
        log "❌ File not found: $PKG"
        exit 1
    fi
    check_tools
    extract_pkg
}

main "$@"
