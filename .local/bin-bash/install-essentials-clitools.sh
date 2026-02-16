#!/usr/bin/env bash
# Arch Linux CLI toolkit installer
# Modular tiers: essentials, dev stack, extras

set -euo pipefail

ROLLBACK_FILE="/tmp/arch-cli-tools-rollback.$(date +%Y%m%d%H%M%S).log"

# --- Tiered package sets ---
ESSENTIAL_PKGS=(
  base-devel git curl wget neovim htop tree unzip ripgrep fd tmux
  man-db man-pages # documentation
  bash-completion  # tab completion
)

DEV_PKGS=(
  # python python-pip nodejs npm go rust cargo
  # docker docker-compose podman
  gcc clang cmake make
  jq yq # JSON/YAML processors
)

EXTRA_PKGS=(
  fzf bat exa        # modern replacements
  ncdu               # disk usage
  rsync              # sync utility
  openssh            # ssh client/server
  net-tools iproute2 # networking
  # httpie # HTTP client
  zsh fish starship # alternative shells + prompt
)

# --- Functions ---
check_arch() {
  if ! grep -qi "Arch" /etc/os-release; then
    echo "❌ This script is intended for Arch Linux only."
    exit 1
  fi
}

install_pkgs() {
  local pkgs=("$@")
  echo "📦 Installing: ${pkgs[*]}"
  for pkg in "${pkgs[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null; then
      echo "✅ $pkg already installed"
    else
      echo "➡️ Installing $pkg"
      if ! sudo pacman -S --noconfirm "$pkg"; then
        echo "❌ Failed to install $pkg"
        echo "$pkg" >>"$ROLLBACK_FILE"
      fi
    fi
  done
}

rollback() {
  if [[ -s "$ROLLBACK_FILE" ]]; then
    echo "⚠️ Rolling back failed installs..."
    while read -r pkg; do
      echo "➡️ Removing $pkg"
      sudo pacman -Rns --noconfirm "$pkg" || true
    done <"$ROLLBACK_FILE"
    echo "Rollback complete. See $ROLLBACK_FILE for details."
  else
    echo "✅ No rollback needed."
  fi
}

# --- Main ---
check_arch
sudo pacman -Syu --noconfirm # update system first

# Install tiers
install_pkgs "${ESSENTIAL_PKGS[@]}"
install_pkgs "${DEV_PKGS[@]}"
install_pkgs "${EXTRA_PKGS[@]}"

rollback

echo "🎉 Arch Linux CLI toolkit setup complete!"
