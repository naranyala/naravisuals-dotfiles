#!/usr/bin/env bash
set -euo pipefail

# Single-file Font Awesome installer (desktop OTFs)
# Source: https://github.com/FortAwesome/Font-Awesome (official) [reference only]
# Usage:
#   User install (no sudo):  bash install-fontawesome.sh
#   System-wide install:     sudo bash install-fontawesome.sh --system

REPO_URL="https://github.com/FortAwesome/Font-Awesome.git"
INSTALL_MODE="${1:-user}"   # "user" (default) or "--system"
TMP_DIR="$(mktemp -d)"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

# Determine target directory
if [[ "$INSTALL_MODE" == "--system" ]]; then
  TARGET_DIR="/usr/local/share/fonts/fontawesome"
  SUDO_PREFIX=""  # already running under sudo if needed
else
  TARGET_DIR="$HOME/.local/share/fonts/fontawesome"
  SUDO_PREFIX=""
fi

# Ensure dependencies
need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Error: '$1' not found. Please install it and re-run." >&2
    exit 1
  }
}
need_cmd git
need_cmd fc-cache
need_cmd sha256sum || need_cmd shasum

echo "==> Cloning Font Awesome (shallow) from official source..."
git clone --depth=1 "$REPO_URL" "$TMP_DIR/fa"

# Verify expected structure (best-effort)
if [[ ! -d "$TMP_DIR/fa/otfs" ]]; then
  echo "Error: 'otfs' directory not found in repository. Structure may have changed." >&2
  exit 1
fi

# Create target directory
echo "==> Preparing target directory: $TARGET_DIR"
mkdir -p "$TARGET_DIR"

echo "==> Copying OTFs..."
cp "$TMP_DIR/fa/otfs/"*.otf "$TARGET_DIR/"

# Generate manifest with checksums
echo "==> Generating manifest and checksums..."
(
  cd "$TARGET_DIR"
  echo "source_repo=$REPO_URL"
  echo "installed_at=$TIMESTAMP"
  echo "installed_mode=$([[ "$INSTALL_MODE" == "--system" ]] && echo system || echo user)"
  echo "version_hint=$(grep -m1 -E 'Version|CHANGELOG' -n "$TMP_DIR/fa/README.md" 2>/dev/null | sed 's/"/'\''/g' || true)"
) > "$TARGET_DIR/INSTALL_MANIFEST.txt"

# Checksums file
if command -v sha256sum >/dev/null 2>&1; then
  (cd "$TARGET_DIR" && sha256sum *.otf > CHECKSUMS.sha256)
else
  (cd "$TARGET_DIR" && shasum -a 256 *.otf > CHECKSUMS.sha256)
fi

echo "==> Refreshing font cache..."
fc-cache -f -v >/dev/null

echo "==> Installation complete."
echo "Installed OTFs to: $TARGET_DIR"
echo "Manifest: $TARGET_DIR/INSTALL_MANIFEST.txt"
echo "Checksums: $TARGET_DIR/CHECKSUMS.sha256"

# Optional: quick smoke test instructions
cat <<'EOF'

Quick test:
  - On GUI apps: select "Font Awesome" as the font, then paste a known glyph (e.g., U+F007).
  - In terminal-aware apps: some terminals won't map FA class names; use glyph codepoints or GUI apps.

To uninstall:
  rm -rf "$TARGET_DIR" && fc-cache -f -v

EOF

