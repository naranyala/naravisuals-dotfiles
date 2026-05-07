#!/usr/bin/env bash
set -euo pipefail

log() { printf "\033[1;32m%s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m%s\033[0m\n" "$*"; }
err() { printf "\033[1;31m%s\033[0m\n" "$*"; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { err "Missing required command: $1"; exit 1; }
}

append_line_if_missing() {
  local line="$1" file="$2"
  grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

ensure_brew_in_path() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  # Common Linuxbrew locations
  local candidates=(
    "/home/linuxbrew/.linuxbrew/bin/brew"
    "$HOME/.linuxbrew/bin/brew"
    "/opt/homebrew/bin/brew"
    "/usr/local/bin/brew"
  )
  for p in "${candidates[@]}"; do
    if [ -x "$p" ]; then
      eval "$("$p" shellenv)"
      return 0
    fi
  done

  warn "Homebrew not found. Installing Homebrew for Linux..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Shellenv after install
  if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
    eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
  else
    err "Homebrew installed but not found on PATH. Open a new shell or add it manually."
    exit 1
  fi
}

main() {
  require_cmd curl

  ensure_brew_in_path
  require_cmd brew

  log "Updating Homebrew..."
  brew update

  log "Installing zsh via Homebrew..."
  brew install zsh

  log "Installing starship via Homebrew..."
  brew install starship

  local brew_prefix
  brew_prefix="$(brew --prefix)"
  local zsh_path="$brew_prefix/bin/zsh"

  if [ ! -x "$zsh_path" ]; then
    err "zsh not found at $zsh_path. Aborting."
    exit 1
  fi

  # Ensure /etc/shells contains the brew zsh
  if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
    log "Adding $zsh_path to /etc/shells (requires sudo)..."
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  else
    log "$zsh_path is already listed in /etc/shells."
  fi

  # Change default shell for current user if needed
  local current_shell
  current_shell="$(getent passwd "$USER" | awk -F: '{print $7}')"
  if [ "$current_shell" != "$zsh_path" ]; then
    log "Setting default shell to $zsh_path for user $USER (you may be prompted for your password)..."
    chsh -s "$zsh_path"
  else
    log "Default shell is already $zsh_path."
  fi

  # Configure starship in ~/.zshrc
  local zshrc="$HOME/.zshrc"
  if [ -f "$zshrc" ]; then
    cp "$zshrc" "$zshrc.bak.$(date +%Y%m%d%H%M%S)"
  fi

  append_line_if_missing '# Initialize Homebrew (Linuxbrew) in non-login shells' "$zshrc"
  append_line_if_missing 'if command -v brew >/dev/null 2>&1; then eval "$(brew shellenv)"; fi' "$zshrc"

  append_line_if_missing '# Initialize starship prompt' "$zshrc"
  append_line_if_missing 'eval "$(starship init zsh)"' "$zshrc"

  log "Done."
  echo
  echo "Next steps:"
  echo " - Open a new terminal, or run: exec $zsh_path"
  echo " - Your default shell is set. To verify: grep \"^$USER:\" /etc/passwd | awk -F: '{print \$7}'"
  echo " - Starship is active via your ~/.zshrc. Customize with: starship preset pastel-powerline -o ~/.config/starship.toml"
}

main "$@"
