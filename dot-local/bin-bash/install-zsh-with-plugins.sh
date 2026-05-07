#!/usr/bin/env bash

set -euo pipefail

### CONFIG ###
LOG_FILE="/tmp/setup-zsh.log"
ZSHRC="$HOME/.zshrc"
ZSHRC_BACKUP="$HOME/.zshrc.backup.$(date '+%Y%m%d_%H%M%S')"
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM="${OH_MY_ZSH_DIR}/custom"
BUILTIN_PLUGINS=(git z sudo command-not-found colored-man-pages history-substring-search web-search dirhistory)
CUSTOM_PLUGINS=(zsh-autosuggestions zsh-syntax-highlighting zsh-completions fzf-tab)
declare -A CUSTOM_PLUGIN_REPOS=(
    [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
    [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting"
    [zsh-completions]="https://github.com/zsh-users/zsh-completions"
    [fzf-tab]="https://github.com/Aloxaf/fzf-tab"
)

### LOGGING ###
log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"
}

### DETECT DISTRO ###
detect_distro() {
    if command -v dnf &>/dev/null; then
        DISTRO="fedora"
    elif command -v pacman &>/dev/null; then
        DISTRO="arch"
    elif command -v apt &>/dev/null; then
        DISTRO="debian"
    else
        log "✗ Unsupported or unknown distro. No known package manager found."
        exit 1
    fi
}

### INSTALL ZSH ###
install_zsh() {
    if command -v zsh &>/dev/null; then
        log "✓ Zsh already installed."
    else
        log "→ Installing Zsh..."
        case "$DISTRO" in
            fedora) sudo dnf install -y zsh git curl ;;
            arch) sudo pacman -Sy --noconfirm zsh git curl ;;
            debian)
                sudo apt update
                sudo apt install -y zsh git curl
                ;;
        esac &>> "$LOG_FILE"
    fi
}

### BACKUP EXISTING ZSHRC ###
backup_zshrc() {
    if [[ -f "$ZSHRC" ]]; then
        log "→ Backing up existing .zshrc to $ZSHRC_BACKUP"
        cp "$ZSHRC" "$ZSHRC_BACKUP"
    else
        log "✓ No existing .zshrc found. Skipping backup."
    fi
}

### INSTALL OH MY ZSH ###
install_oh_my_zsh() {
    if [[ -d "$OH_MY_ZSH_DIR" ]]; then
        log "✓ Oh My Zsh already installed."
    else
        log "→ Installing Oh My Zsh..."
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &>> "$LOG_FILE"
    fi
}

### INSTALL CUSTOM PLUGINS ###
install_custom_plugins() {
    local PLUGIN_DIR="${ZSH_CUSTOM}/plugins"
    mkdir -p "$PLUGIN_DIR"

    for plugin in "${CUSTOM_PLUGINS[@]}"; do
        local repo="${CUSTOM_PLUGIN_REPOS[$plugin]}"
        local target="$PLUGIN_DIR/$plugin"

        if [[ -d "$target" ]]; then
            log "✓ $plugin already installed."
        else
            log "→ Cloning $plugin from $repo..."
            git clone --depth=1 "$repo" "$target" &>> "$LOG_FILE"
        fi
    done
}

### CONFIGURE ZSHRC ###
configure_zshrc() {
    log "→ Writing new .zshrc with plugin configuration..."
    cat > "$ZSHRC" <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
  git
  z
  sudo
  command-not-found
  colored-man-pages
  history-substring-search
  web-search
  dirhistory
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  fzf-tab
)

source $ZSH/oh-my-zsh.sh

# Custom plugin sourcing
source $ZSH_CUSTOM/plugins/zsh-completions/zsh-completions.plugin.zsh
source $ZSH_CUSTOM/plugins/fzf-tab/fzf-tab.plugin.zsh
source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Completion system
autoload -Uz compinit && compinit
EOF
}

### SET DEFAULT SHELL ###
set_default_shell() {
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        log "→ Setting Zsh as default shell..."
        chsh -s "$(which zsh)" "$USER"
    else
        log "✓ Zsh already set as default shell."
    fi
}

### MAIN ###
log "=== Zsh + Oh My Zsh Setup Initiated ==="
detect_distro
install_zsh
backup_zshrc
install_oh_my_zsh
install_custom_plugins
configure_zshrc
set_default_shell
log "=== Setup Complete. Please restart your terminal. ==="

