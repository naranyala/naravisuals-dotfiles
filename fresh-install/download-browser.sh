#!/usr/bin/env bash

## download-browser.sh

set -e

# Modular installer for Helium Linux & Zen Browser
# Downloads latest AppImage into ./bin

REPOS=(
  "https://github.com/imputnet/helium-linux/releases/latest/download/helium-linux-x86_64.AppImage"
  "https://github.com/zen-browser/desktop/releases/latest/download/zen-x86_64.AppImage"
)

BIN_DIR="$(pwd)/bin"

prepare_bin_dir() {
  mkdir -p "$BIN_DIR"
}

download_appimage() {
  local url=$1
  local filename=$(basename "$url")
  local target="$BIN_DIR/$filename"

  echo "Downloading $filename..."
  curl -L "$url" -o "$target"
  chmod +x "$target"
  echo "Saved to $target"
}

main() {
  prepare_bin_dir
  for repo in "${REPOS[@]}"; do
    download_appimage "$repo"
  done
}

main "$@"

