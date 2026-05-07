#!/usr/bin/env bash
set -euo pipefail

# === Config ===
REPO_URL="https://github.com/fwcd/kotlin-language-server.git"
INSTALL_DIR="$HOME/.local/kotlin-language-server"
BIN_DIR="$INSTALL_DIR/server/build/install/kotlin-language-server/bin"
BIN_NAME="kotlin-language-server"
SYMLINK="/usr/local/bin/$BIN_NAME"

# === Ensure prerequisites ===
for cmd in git unzip java; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Missing dependency: $cmd"
    exit 1
  fi
done

# === Clone repository ===
if [[ ! -d "$INSTALL_DIR" ]]; then
  echo "Cloning Kotlin language server..."
  git clone "$REPO_URL" "$INSTALL_DIR"
else
  echo "Repository already cloned at $INSTALL_DIR"
fi

cd "$INSTALL_DIR"

# === Build server ===
echo "Building Kotlin language server..."
./gradlew installDist

# === Link binary ===
if [[ -f "$BIN_DIR/$BIN_NAME" ]]; then
  echo "Kotlin language server built at $BIN_DIR/$BIN_NAME"
  if [[ "$(command -v $BIN_NAME 2>/dev/null)" != "$SYMLINK" ]]; then
    echo "Linking to $SYMLINK..."
    sudo ln -sf "$BIN_DIR/$BIN_NAME" "$SYMLINK"
  else
    echo "Binary already linked."
  fi
else
  echo "Failed to build Kotlin language server."
  exit 2
fi

# === Success ===
echo "✅ Installed and available as: $(which kotlin-language-server)"

