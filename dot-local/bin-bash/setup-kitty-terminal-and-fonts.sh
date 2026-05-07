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
  if command -v apt-get >/dev/null 2>&1; then
    echo "apt"
  elif command -v dnf >/dev/null 2>&1; then
    echo "dnf"
  elif command -v yum >/dev/null 2>&1; then
    echo "yum"
  else
    echo ""
  fi
}

install_pkgs_apt() {
  sudo apt-get update
  sudo apt-get install -y "$@"
}

install_pkgs_dnf() {
  sudo dnf install -y "$@"
}

install_pkgs_yum() {
  sudo yum install -y "$@"
}

ensure_kitty() {
  command -v kitty >/dev/null 2>&1 && { log "Kitty already installed."; return; }
  case "$(detect_pkg_mgr)" in
    apt)
      log "Installing Kitty..."
      install_pkgs_apt kitty
      ;;
    dnf)
      log "Installing Kitty..."
      install_pkgs_dnf kitty
      ;;
    yum)
      log "Installing Kitty..."
      install_pkgs_yum kitty
      ;;
    *)
      err "No supported package manager found. Install Kitty manually."
      exit 1
      ;;
  esac
}

install_nerd_font() {
  [ "$INSTALL_NERD_FONT" != "1" ] && { warn "Skipping Nerd Font"; return; }
  fc-list | grep -qi "JetBrains.*Nerd.*Mono" && { log "Nerd Font present"; return; }

  case "$(detect_pkg_mgr)" in
    apt)
      install_pkgs_apt curl unzip fontconfig
      ;;
    dnf)
      install_pkgs_dnf curl unzip fontconfig
      ;;
    yum)
      install_pkgs_yum curl unzip fontconfig
      ;;
  esac

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

  if ! command -v fc-list >/dev/null 2>&1; then
    case "$(detect_pkg_mgr)" in
      apt) install_pkgs_apt fontconfig ;;
      dnf) install_pkgs_dnf fontconfig ;;
      yum) install_pkgs_yum fontconfig ;;
    esac
  fi

  install_nerd_font
  local font_family
  font_family="$(resolve_font_family)"
  local shell_path
  shell_path="$(getent passwd "$USER" | awk -F: '{print $7}')"

  write_minimal_kitty_conf "$shell_path" "$font_family"

  log "Kitty terminal setup complete."
  echo "Launch Kitty to use your configured shell and font."
}

main "$@"

