#!/usr/bin/env bash
# install-pkg-config.sh
# Tested multi-distro installer for pkg-config with setup

set -euo pipefail

# Colors for output
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
RESET="\033[0m"

log() { echo -e "${GREEN}[+]${RESET} $*"; }
warn() { echo -e "${YELLOW}[!]${RESET} $*"; }
err() { echo -e "${RED}[-]${RESET} $*" >&2; }

DRYRUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRYRUN=true
  warn "Dry-run mode enabled. No changes will be made."
fi

install_pkg_config() {
  if command -v pkg-config >/dev/null 2>&1; then
    log "pkg-config already installed: $(pkg-config --version)"
    return 0
  fi

  if command -v apt-get >/dev/null 2>&1; then
    PKG="pkg-config"
    CMD="sudo apt-get update && sudo apt-get install -y $PKG build-essential"
  elif command -v dnf >/dev/null 2>&1; then
    PKG="pkgconf-pkg-config"
    CMD="sudo dnf install -y $PKG gcc make"
  elif command -v yum >/dev/null 2>&1; then
    PKG="pkgconfig"
    CMD="sudo yum install -y $PKG gcc make"
  elif command -v pacman >/dev/null 2>&1; then
    PKG="pkgconf"
    CMD="sudo pacman -Sy --noconfirm $PKG base-devel"
  elif command -v zypper >/dev/null 2>&1; then
    PKG="pkg-config"
    CMD="sudo zypper install -y $PKG gcc make"
  elif command -v apk >/dev/null 2>&1; then
    PKG="pkgconf"
    CMD="sudo apk add $PKG build-base"
  else
    err "Unsupported package manager. Install pkg-config manually."
    exit 1
  fi

  log "Installing $PKG..."
  $DRYRUN || eval "$CMD"
}

setup_env() {
  DEFAULT_PATH="/usr/lib/pkgconfig:/usr/share/pkgconfig:/usr/local/lib/pkgconfig"
  export PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-$DEFAULT_PATH}"

  if ! grep -q "PKG_CONFIG_PATH" ~/.bashrc; then
    log "Adding PKG_CONFIG_PATH to ~/.bashrc"
    $DRYRUN || echo "export PKG_CONFIG_PATH=$PKG_CONFIG_PATH" >> ~/.bashrc
  fi

  log "PKG_CONFIG_PATH set to: $PKG_CONFIG_PATH"
}

main() {
  install_pkg_config
  setup_env
  log "pkg-config setup complete."
}

main "$@"

