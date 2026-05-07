
#!/usr/bin/env bash
set -euo pipefail

# === Configurable Variables ===
DOTFILES_DIR="$HOME/projects-remote/modular-dotfiles"
CONFIG_DIR="$HOME/.config"
WOFI_DIR="$DOTFILES_DIR/wofi"
LOG_FILE="$DOTFILES_DIR/wofi-setup.log"
REQUIRED_PROGRAMS=("wofi")

touch "$LOG_FILE"

# === Helper Functions ===
log() { echo "[$(date +'%F %T')] $*" | tee -a "$LOG_FILE"; }
ensure_dir() { mkdir -p "$1" && log "📁 Created: $1"; }
safe_symlink() {
    local src="$1" dst="$2"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        log "⚠️  Skipped symlink: $dst exists and is not a symlink"
    else
        ln -sf "$src" "$dst" && log "🔗 Linked: $src → $dst"
    fi
}

# === Setup Directories ===
log "🚀 Starting Wofi setup..."
ensure_dir "$WOFI_DIR"
ensure_dir "$WOFI_DIR/style"
ensure_dir "$WOFI_DIR/scripts"

# === Check Required Programs ===
log "🔍 Checking required programs..."
for prog in "${REQUIRED_PROGRAMS[@]}"; do
    if ! command -v "$prog" &> /dev/null; then
        log "❌ Missing: $prog — consider installing it"
    else
        log "✅ Found: $prog"
    fi
done

# === Generate Wofi Config ===
cat <<EOF > "$WOFI_DIR/config"
# Wofi config
prompt="Launch:"
width=600
height=400
show_icons=true
allow_markup=true
insensitive=true
hide_scroll=true
EOF
log "📝 Generated Wofi config"

# === Generate Wofi Style ===
cat <<EOF > "$WOFI_DIR/style/style.css"
/* Wofi dark theme */
window {
  background-color: #1e1e2e;
  border: 2px solid #89b4fa;
}

#input {
  background-color: #313244;
  color: #cdd6f4;
  border: none;
  padding: 6px;
}

#entry {
  padding: 6px;
  color: #cdd6f4;
}

#entry:selected {
  background-color: #89b4fa;
  color: #1e1e2e;
}
EOF
log "🎨 Generated Wofi style"

# === Create Test Launcher Script ===
cat <<'EOF' > "$WOFI_DIR/scripts/test-launch.sh"
#!/usr/bin/env bash
wofi --show drun --conf "$HOME/.config/wofi/config" --style "$HOME/.config/wofi/style/style.css"
EOF
chmod +x "$WOFI_DIR/scripts/test-launch.sh"
log "🧪 Created test launcher script"

# === Symlink to ~/.config ===
log "🔗 Linking Wofi config to $CONFIG_DIR..."
safe_symlink "$WOFI_DIR" "$CONFIG_DIR/wofi"

# === Final Message ===
log "✅ Wofi setup complete!"
echo -e "\n📂 Configs: $WOFI_DIR → $CONFIG_DIR/wofi"
echo "📄 Log: $LOG_FILE"
echo "🚀 Test with: $CONFIG_DIR/wofi/scripts/test-launch.sh"
