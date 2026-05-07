
#!/usr/bin/env bash
# bash_with_nushell_autorun.sh — Keep Bash as default, autorun Nushell on login

set -euo pipefail
LOGFILE="${HOME}/bash_nushell_autorun.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "🔧 Starting Bash+Nushell setup at $(date)"

# Ensure Bash is listed in /etc/shells
BASH_PATH="$(command -v bash)"
if ! grep -Fxq "$BASH_PATH" /etc/shells; then
  echo "📝 Adding Bash to /etc/shells..."
  echo "$BASH_PATH" | sudo tee -a /etc/shells
else
  echo "✅ Bash already listed in /etc/shells."
fi

# Set Bash as default shell
if [[ "$SHELL" != "$BASH_PATH" ]]; then
  echo "🔄 Changing default shell to Bash..."
  chsh -s "$BASH_PATH"
  echo "✅ Default shell changed to Bash."
else
  echo "🔁 Bash is already your default shell."
fi

# Ensure Nushell is installed
if ! command -v nu &>/dev/null; then
  echo "❌ Nushell not found. Please install it first."
  exit 1
fi

# Add Nushell autorun to .bash_profile or .bashrc
NU_LAUNCH='[[ -n "$PS1" ]] && command -v nu &>/dev/null && exec nu'
TARGET_FILE="$HOME/.bash_profile"
[[ -f "$TARGET_FILE" ]] || TARGET_FILE="$HOME/.bashrc"

if ! grep -Fxq "$NU_LAUNCH" "$TARGET_FILE"; then
  echo "🚀 Adding Nushell autorun to $TARGET_FILE..."
  echo -e "\n# Autorun Nushell if interactive shell\n$NU_LAUNCH" >> "$TARGET_FILE"
  echo "✅ Nushell will autorun on Bash login."
else
  echo "🔁 Nushell autorun already configured in $TARGET_FILE."
fi

echo "🎉 Setup complete. Open a new terminal to test Nushell autorun."
