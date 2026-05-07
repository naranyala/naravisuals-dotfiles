#!/usr/bin/env bash
set -euo pipefail

INSTALL_NERD_FONT="${INSTALL_NERD_FONT:-1}"
FONT_NAME_DEFAULT="JetBrainsMono Nerd Font"
KITTY_CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"
KITTY_CONF="$KITTY_CONF_DIR/kitty.conf"
STARSHIP_CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
STARSHIP_CONF="$STARSHIP_CONF_DIR/starship.toml"

log()  { printf "\033[1;32m==> %s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m==> %s\033[0m\n" "$*"; }
err()  { printf "\033[1;31m==> %s\033[0m\n" "$*"; }

require_cmd() { command -v "$1" >/dev/null 2>&1 || { err "Missing: $1"; exit 1; }; }

append_line_if_missing() {
  local line="$1" file="$2"
  grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

detect_pkg_mgr() {
  if command -v apt-get >/dev/null 2>&1; then echo "apt"; else echo ""; fi
}

install_pkgs_apt() {
  sudo apt-get update
  sudo apt-get install -y "$@"
}

ensure_kitty() {
  if command -v kitty >/dev/null 2>&1; then log "Kitty already installed."; return; fi
  if [ "$(detect_pkg_mgr)" = "apt" ]; then
    log "Installing Kitty..."
    install_pkgs_apt kitty
  else
    err "No supported package manager found. Install Kitty manually."
    exit 1
  fi
}

detect_zsh_path() {
  local zsh_path=""
  if command -v brew >/dev/null 2>&1; then
    local brew_prefix="$(brew --prefix 2>/dev/null || true)"
    if [ -n "$brew_prefix" ] && [ -x "$brew_prefix/bin/zsh" ]; then
      zsh_path="$brew_prefix/bin/zsh"
    fi
  fi
  if [ -z "$zsh_path" ] && command -v zsh >/dev/null 2>&1; then
    zsh_path="$(command -v zsh)"
  fi
  echo "$zsh_path"
}

ensure_shells_contains() {
  local shell_path="$1"
  grep -qxF "$shell_path" /etc/shells 2>/dev/null || \
    { log "Adding $shell_path to /etc/shells"; echo "$shell_path" | sudo tee -a /etc/shells >/dev/null; }
}

ensure_default_shell() {
  local shell_path="$1"
  local current_shell
  current_shell="$(getent passwd "$USER" | awk -F: '{print $7}')"
  [ "$current_shell" != "$shell_path" ] && { log "Changing default shell to $shell_path"; chsh -s "$shell_path"; } || log "Default shell already $shell_path"
}

install_nerd_font() {
  [ "$INSTALL_NERD_FONT" != "1" ] && { warn "Skipping Nerd Font"; return; }
  fc-list | grep -qi "JetBrains.*Nerd.*Mono" && { log "Nerd Font present"; return; }
  [ "$(detect_pkg_mgr)" = "apt" ] && install_pkgs_apt curl unzip fontconfig
  mkdir -p "$HOME/.local/share/fonts/JetBrainsMonoNerd"
  curl -fsSL -o /tmp/JetBrainsMono.zip \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  unzip -oq /tmp/JetBrainsMono.zip -d "$HOME/.local/share/fonts/JetBrainsMonoNerd"
  rm -f /tmp/JetBrainsMono.zip
  fc-cache -f "$HOME/.local/share/fonts"
}

resolve_font_family() {
  fc-list | grep -qi "JetBrains.*Nerd.*Mono" && echo "$FONT_NAME_DEFAULT" || echo "monospace"
}

ensure_starship_in_zshrc() {
  local zshrc="$HOME/.zshrc"
  [ -f "$zshrc" ] && cp "$zshrc" "$zshrc.bak.$(date +%Y%m%d%H%M%S)"
  append_line_if_missing '# Initialize Starship prompt' "$zshrc"
  append_line_if_missing 'if command -v starship >/dev/null 2>&1; then eval "$(starship init zsh)"; fi' "$zshrc"
}

write_minimal_kitty_conf() {
  local shell_path="$1" font_family="$2"
  mkdir -p "$KITTY_CONF_DIR"
  [ -f "$KITTY_CONF" ] && cp "$KITTY_CONF" "$KITTY_CONF.bak.$(date +%Y%m%d%H%M%S)"
  # Only write minimal config if no kitty.conf exists or it's empty
  if [ ! -s "$KITTY_CONF" ]; then
    cat > "$KITTY_CONF" <<EOF
# Minimal Kitty configuration
shell $shell_path
font_family $font_family
font_size 12.0
EOF
  else
    log "Existing Kitty configuration found, skipping minimal config."
  fi
}

main() {
  require_cmd awk
  require_cmd grep

  ensure_kitty
  local zsh_path
  zsh_path="$(detect_zsh_path)"
  [ -z "$zsh_path" ] && { err "zsh not found. Install it first."; exit 1; }
  ensure_shells_contains "$zsh_path"
  ensure_default_shell "$zsh_path"

  command -v fc-list >/dev/null 2>&1 || [ "$(detect_pkg_mgr)" = "apt" ] && install_pkgs_apt fontconfig
  install_nerd_font
  local font_family="$(resolve_font_family)"

  ensure_starship_in_zshrc
  # Skip Starship config file creation to use default
  [ -f "$STARSHIP_CONF" ] && log "Existing Starship configuration found, using it." || log "No Starship config created, using default."
  write_minimal_kitty_conf "$zsh_path" "$font_family"

  log "Minimal terminal setup complete."
  echo "Launch Kitty to use the default theme with Zsh and Starship."
}

main "$@"
