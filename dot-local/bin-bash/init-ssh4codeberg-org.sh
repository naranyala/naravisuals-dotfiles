
#!/usr/bin/env bash
set -euo pipefail

# === Config ===
KEY_PATH="${HOME}/.ssh/id_ed25519"
CLIP_CMD=""
LOG_FILE="${HOME}/.setup-codeberg-ssh.log"

# === Logging ===
log() {
    echo "[$(date +'%F %T')] $*" | tee -a "$LOG_FILE"
}

# === Detect Clipboard Tool ===
detect_clipboard() {
    if command -v wl-copy &>/dev/null; then
        CLIP_CMD="wl-copy"
    elif command -v xclip &>/dev/null; then
        CLIP_CMD="xclip -selection clipboard"
    elif command -v pbcopy &>/dev/null; then
        CLIP_CMD="pbcopy"
    elif command -v clip &>/dev/null; then
        CLIP_CMD="clip"
    else
        CLIP_CMD=""
    fi
}

# === Check SSH Key ===
check_ssh_key() {
    if [[ -f "$KEY_PATH" && -f "${KEY_PATH}.pub" ]]; then
        log "✅ SSH key found at $KEY_PATH"
    else
        log "❌ SSH key not found at $KEY_PATH"
        echo "Please generate one with: ssh-keygen -t ed25519 -C 'your_email@example.com'"
        exit 1
    fi
}

# === Add Key to Agent ===
add_to_agent() {
    eval "$(ssh-agent -s)"
    if ssh-add -l | grep -q "$KEY_PATH"; then
        log "🔐 Key already loaded in agent"
    else
        ssh-add "$KEY_PATH"
        log "🔐 Key added to SSH agent"
    fi
}

# === Copy Public Key ===
copy_pubkey() {
    detect_clipboard
    if [[ -n "$CLIP_CMD" ]]; then
        cat "${KEY_PATH}.pub" | eval "$CLIP_CMD"
        log "📋 Public key copied to clipboard"
    else
        log "⚠️ No clipboard tool found. Please copy manually:"
        echo "----- BEGIN PUBLIC KEY -----"
        cat "${KEY_PATH}.pub"
        echo "----- END PUBLIC KEY -----"
    fi
}

# === Suggest SSH Config ===
suggest_ssh_config() {
    CONFIG_ENTRY="Host codeberg.org
  HostName codeberg.org
  User git
  IdentityFile $KEY_PATH
  IdentitiesOnly yes"

    if grep -q "Host codeberg.org" ~/.ssh/config 2>/dev/null; then
        log "🛠️ SSH config for Codeberg already exists"
    else
        echo -e "\n$CONFIG_ENTRY" >> ~/.ssh/config
        chmod 600 ~/.ssh/config
        log "🛠️ SSH config for Codeberg added to ~/.ssh/config"
    fi
}

# === Main ===
main() {
    log "🚀 Starting Codeberg SSH setup"
    check_ssh_key
    add_to_agent
    copy_pubkey
    suggest_ssh_config

    echo -e "\n🔗 Now go to https://codeberg.org -> Settings -> SSH / GPG Keys and paste your key."
    log "✅ Setup complete"
}

main "$@"
