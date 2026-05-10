#!/usr/bin/env bash
set -euo pipefail

# === USAGE CHECK ===
if [[ $# -lt 1 ]]; then
    echo "❌ Missing arguments!"
    echo "Usage: $0 <github_email> [key_name]"
    echo "Example: $0 naranyala@example.com my_github_key"
    exit 1
fi

# === CONFIGURATION ===
EMAIL="$1"                          # GitHub email (required)
KEY_NAME="${2:-github_ssh_key}"     # Optional: custom key name

# === GENERATE SSH KEY ===
echo "🔑 Generating new SSH key..."
ssh-keygen -t ed25519 -C "$EMAIL" -f "$HOME/.ssh/$KEY_NAME" -N ""

# === EXPOSE KEYS ===
echo "✅ SSH key pair created!"
echo
echo "👉 Public key (add this to GitHub):"
cat "$HOME/.ssh/$KEY_NAME.pub"
echo
echo "👉 Private key (keep this secret!):"
cat "$HOME/.ssh/$KEY_NAME"

# === ADD TO SSH AGENT ===
eval "$(ssh-agent -s)"
ssh-add "$HOME/.ssh/$KEY_NAME"

echo
echo "🎉 Done! Copy the public key above and paste it into your GitHub account under Settings > SSH and GPG keys."

