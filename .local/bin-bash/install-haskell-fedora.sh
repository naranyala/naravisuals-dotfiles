#!/bin/bash
# Install complete Haskell programming environment on Fedora Linux

set -euo pipefail

log() {
    echo -e "\033[1;32m[INFO]\033[0m $*"
}

error_exit() {
    echo -e "\033[1;31m[ERROR]\033[0m $*" >&2
    exit 1
}

install_packages() {
    local pkgs=("$@")
    log "Installing: ${pkgs[*]}"
    if ! sudo dnf install -y --skip-unavailable "${pkgs[@]}"; then
        error_exit "Failed to install packages: ${pkgs[*]}"
    fi
}

log "Updating system..."
if ! sudo dnf upgrade --refresh -y --skip-unavailable; then
    error_exit "System update failed"
fi

log "Installing Haskell core components..."
install_packages ghc cabal-install stack haskell-platform

log "Installing Haskell development extras..."
install_packages haskell-language-server hlint alex happy hoogle

log "Setup complete!"
echo "You now have a full Haskell environment installed."
echo "Try: ghc --version, cabal --version, stack --version"
echo "Run 'hoogle server' to start API search locally."

