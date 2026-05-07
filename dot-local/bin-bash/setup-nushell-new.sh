#!/bin/bash

# Exit on error
set -e

echo "🔧 Installing Nushell via Homebrew..."
brew install nushell

echo "📁 Creating Nushell configuration directory..."
mkdir -p ~/.config/nushell

echo "📝 Writing default Nushell configuration..."
cat <<EOF > ~/.config/nushell/config.nu
# Nushell Configuration File

# Enable some default aliases
alias ll = ls -l
alias la = ls -a
EOF

echo "🔍 Locating Nushell binary..."
NUSHELL_PATH="$(which nu)"

echo "📜 Adding Nushell to /etc/shells..."
if ! grep -q "$NUSHELL_PATH" /etc/shells; then
    echo "$NUSHELL_PATH" | sudo tee -a /etc/shells
fi

echo "🔄 Changing default shell to Nushell..."
chsh -s "$NUSHELL_PATH"

echo "✅ Setup complete! Nushell is now your default shell."

