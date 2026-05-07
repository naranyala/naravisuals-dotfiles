
#!/usr/bin/env bash
set -euo pipefail

LOGFILE="./brew_cpp_env.log"

# List of tools to install
TOOLS=(
    gcc
    g++
    cmake
    meson
    ninja
    pkg-config
    gdb
    valgrind
    clang
    cppcheck
    binutils
    libtool
    glib
    gtk+3
    webkitgtk
    glibc
)

log() {
    echo "[$(date +'%F %T')] $*" | tee -a "$LOGFILE"
}

check_brew() {
    if ! command -v brew &>/dev/null; then
        log "❌ Homebrew not found. Please install it first: https://brew.sh"
        exit 1
    fi
    log "✓ Homebrew is available"
}

install_tool() {
    local tool="$1"
    if brew list "$tool" &>/dev/null; then
        log "🔁 Already installed: $tool"
    else
        log "📦 Installing: $tool"
        brew install "$tool"
    fi
}

main() {
    log "🚀 Starting C/C++ environment setup via Homebrew"
    check_brew
    for tool in "${TOOLS[@]}"; do
        install_tool "$tool"
    done
    log "✅ All tools installed or already present"
}

main "$@"
