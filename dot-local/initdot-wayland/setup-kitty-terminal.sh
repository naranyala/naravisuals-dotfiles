
#!/usr/bin/env bash
set -euo pipefail

# === Config Paths ===
KITTY_CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"
KITTY_CONF_FILE="$KITTY_CONF_DIR/kitty.conf"
BACKUP_SUFFIX=".bak.$(date +%s)"

# === Logging ===
log() { echo "[kitty-setup] $*" >&2; }

# === Ensure Config Directory ===
ensure_conf_dir() {
  if [[ ! -d "$KITTY_CONF_DIR" ]]; then
    log "Creating config directory: $KITTY_CONF_DIR"
    mkdir -p "$KITTY_CONF_DIR"
  fi
}

# === Backup Existing Config ===
backup_existing() {
  if [[ -f "$KITTY_CONF_FILE" ]]; then
    cp "$KITTY_CONF_FILE" "$KITTY_CONF_FILE$BACKUP_SUFFIX"
    log "Backed up existing config to: $KITTY_CONF_FILE$BACKUP_SUFFIX"
  fi
}

# === Config Sections ===
config_header() {
  cat <<EOF
# Kitty Configuration
# Generated on $(date)
EOF
}

config_font() {
  cat <<EOF
font_family      FiraCode Nerd Font
bold_font        auto
italic_font      auto
font_size        12.0
EOF
}

config_colors() {
  cat <<EOF
background       #1e1e2e
foreground       #cdd6f4
selection_background #44475a
selection_foreground #f8f8f2
EOF
}

config_behavior() {
  cat <<EOF
enable_audio_bell no
confirm_os_window_close 0
EOF
}

config_keybindings() {
  cat <<EOF
map ctrl+shift+t new_tab
map ctrl+shift+w close_tab
EOF
}


config_shell() {
  local shell_path="/home/naranyala/.nix-profile/bin/nix-shell"
  cat <<EOF
shell $shell_path
EOF
}

config_window_layout() {
  cat <<EOF
tab_bar_edge bottom
tab_bar_style powerline
window_border_width 2
active_border_color #89b4fa
inactive_border_color #585b70
EOF
}

config_performance() {
  cat <<EOF
repaint_delay 10
input_delay 3
scrollback_lines 10000
EOF
}

config_scrolling_input() {
  cat <<EOF
mouse_hide_wait 3.0
wheel_scroll_multiplier 5.0
EOF
}

config_startup() {
  cat <<EOF
# Launch a shell or session manager
launch --type=tab --keep-focus $SHELL
EOF
}

# === Assemble Config ===
generate_config() {
  {
    config_header
    echo
    config_font
    echo
    config_colors
    echo
    config_behavior
    echo
    config_keybindings
    echo
    config_shell
    echo
    config_window_layout
    echo
    config_performance
    echo
    config_scrolling_input
    echo
    config_startup
  } > "$KITTY_CONF_FILE"
  log "Generated config at: $KITTY_CONF_FILE"
}

# === Main ===
main() {
  ensure_conf_dir
  backup_existing
  generate_config
}

main "$@"
