#!/bin/bash

set -euo pipefail

echo "🔧 Detecting package manager..."

if command -v apt &>/dev/null; then
  PKG_MANAGER="apt"
  UPDATE_CMD="sudo apt update"
  INSTALL_CMD="sudo apt install -y build-essential curl file git"
elif command -v dnf &>/dev/null; then
  PKG_MANAGER="dnf"
  UPDATE_CMD="sudo dnf makecache"
  INSTALL_CMD="sudo dnf install -y @development-tools curl file git"
else
  echo "❌ Unsupported package manager. Please use a Debian- or Fedora-based system."
  exit 1
fi

echo "📦 Updating package index with $PKG_MANAGER..."
eval "$UPDATE_CMD"

echo "📦 Installing required packages..."
eval "$INSTALL_CMD"

echo "📁 Cloning Homebrew..."
mkdir -p ~/.linuxbrew
if [ ! -d ~/.linuxbrew/Homebrew ]; then
  git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew --depth=1
fi

mkdir -p ~/.linuxbrew/bin
ln -sf ~/.linuxbrew/Homebrew/bin/brew ~/.linuxbrew/bin/

echo "🔧 Configuring shell environment..."
BREW_ENV='eval "$($HOME/.linuxbrew/bin/brew shellenv)"'
PROFILE="${HOME}/.bashrc"

if [ -n "${ZSH_VERSION:-}" ]; then
  PROFILE="${HOME}/.zshrc"
fi

if ! grep -Fxq "$BREW_ENV" "$PROFILE"; then
  echo "$BREW_ENV" >> "$PROFILE"
  echo "✅ Added Homebrew environment to $PROFILE"
fi

eval "$($HOME/.linuxbrew/bin/brew shellenv)"

echo "🔄 Updating Homebrew..."
brew update

echo "✅ Homebrew installed successfully!"
brew doctor

