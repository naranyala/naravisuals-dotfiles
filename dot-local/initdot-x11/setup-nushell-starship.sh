#!/usr/bin/env bash
# nushell_starship_setup.sh — Install Nushell & Starship via Homebrew, set Nushell as default

set -euo pipefail
LOGFILE="${HOME}/nushell_starship_setup.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "🔧 Starting Nushell + Starship setup at $(date)"

# Check for Homebrew
if ! command -v brew &>/dev/null; then
  echo "❌ Homebrew not found. Installing..."
  NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo '✅ Homebrew installed.'
else
  echo "✅ Homebrew already installed."
fi

# Ensure brew is in PATH
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv 2>/dev/null || /opt/homebrew/bin/brew shellenv)"

# Install Nushell
if ! brew list nushell &>/dev/null; then
  echo "📦 Installing Nushell..."
  brew install nushell
  echo "✅ Nushell installed."
else
  echo "🔁 Nushell already installed via Homebrew."
fi

# Install Starship
if ! brew list starship &>/dev/null; then
  echo "🌟 Installing Starship prompt..."
  brew install starship
  echo "✅ Starship installed."
else
  echo "🔁 Starship already installed via Homebrew."
fi

# Get Nushell binary path
NU_PATH="$(brew --prefix)/bin/nu"
if [[ ! -x "$NU_PATH" ]]; then
  echo "❌ Nushell binary not found at expected location: $NU_PATH"
  exit 1
fi

# Add Nushell to /etc/shells if not present
if ! grep -Fxq "$NU_PATH" /etc/shells; then
  echo "📝 Adding Nushell to /etc/shells..."
  echo "$NU_PATH" | sudo tee -a /etc/shells
else
  echo "✅ Nushell already listed in /etc/shells."
fi

# Change default shell
if [[ "$SHELL" != "$NU_PATH" ]]; then
  echo "🔄 Changing default shell to Nushell..."
  chsh -s "$NU_PATH"
  echo "✅ Default shell changed to Nushell."
else
  echo "🔁 Nushell is already your default shell."
fi

# Configure Starship for Nushell
NU_CONFIG_DIR="${HOME}/.config/nushell"
mkdir -p "$NU_CONFIG_DIR"
STARSHIP_INIT="source (starship init nu | save -f ~/.cache/starship.nu)"

if ! grep -Fxq "$STARSHIP_INIT" "$NU_CONFIG_DIR/config.nu"; then
  echo "🔧 Adding Starship init to Nushell config..."
  echo -e "\n# Starship prompt\n$STARSHIP_INIT" >> "$NU_CONFIG_DIR/config.nu"
  echo "✅ Starship prompt configured for Nushell."
else
  echo "🔁 Starship already configured in Nushell."
fi

echo "🎉 Setup complete. Log out and back in to enjoy Nushell + Starship!"
