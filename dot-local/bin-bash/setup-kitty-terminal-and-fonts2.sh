#!/usr/bin/env bash
set -euo pipefail

INSTALL_NERD_FONT="${INSTALL_NERD_FONT:-1}"
FONT_NAME_DEFAULT="JetBrainsMono Nerd Font"
KITTY_CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"
KITTY_CONF="$KITTY_CONF_DIR/kitty.conf"

log()  { printf "\033[1;32m==> %s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m==> %s\033[0m\n" "$*"; }
err()  { printf "\033[1;31m==> %s\033[0m\n" "$*"; }

require_cmd() { command -v "$1" >/dev/null 2>&1 || { err "Missing: $1"; exit 1; }; }

detect_pkg_mgr() {
  command -v apt-get >/dev/null 2>&1 && echo "apt" || echo ""
}

install_pkgs_apt() {
  sudo apt-get update
  sudo apt-get install -y "$@"
}

ensure_kitty() {
  command -v kitty >/dev/null 2>&1 && { log "Kitty already installed."; return; }
  [ "$(detect_pkg_mgr)" = "apt" ] && {
    log "Installing Kitty..."
    install_pkgs_apt kitty
  } || {
    err "No supported package manager found. Install Kitty manually."
    exit 1
  }
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

select_font_family() {
  local override="${FONT_NAME_OVERRIDE:-}"
  local available_fonts
  available_fonts=$(fc-list : family | sort -u)

  if [ -n "$override" ]; then
    echo "$available_fonts" | grep -qi "$override" && {
      log "Using override font: $override"
      echo "$override"
      return
    }
    warn "Font override '$override' not found. Falling back to interactive selection."
  fi

  log "Available Nerd Fonts:"
  echo "$available_fonts" | grep -i "Nerd" | nl -w2 -s'. '

  echo -ne "\nEnter font name (or press Enter for default: $FONT_NAME_DEFAULT): "
  read -r user_font

  if [ -n "$user_font" ] && echo "$available_fonts" | grep -qi "$user_font"; then
    echo "$user_font"
  else
    log "Using default font: $FONT_NAME_DEFAULT"
    echo "$FONT_NAME_DEFAULT"
  fi
}

write_minimal_kitty_conf() {
  local shell_path="$1" font_family="$2"
  mkdir -p "$KITTY_CONF_DIR"
  [ -f "$KITTY_CONF" ] && cp "$KITTY_CONF" "$KITTY_CONF.bak.$(date +%Y%m%d%H%M%S)"
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
  command -v fc-list >/dev/null 2>&1 || [ "$(detect_pkg_mgr)" = "apt" ] && install_pkgs_apt fontconfig
  install_nerd_font

  local font_family="$(select_font_family)"
  local shell_path="$(getent passwd "$USER" | awk -F: '{print $7}')"

  write_minimal_kitty_conf "$shell_path" "$font_family"

  log "Kitty terminal setup complete."
  echo "Launch Kitty to use your configured shell and font."
}

main "$@"

