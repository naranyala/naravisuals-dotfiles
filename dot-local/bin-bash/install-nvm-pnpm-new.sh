#!/bin/bash

# Exit on error
set -e

echo "📦 Installing Node Version Manager (nvm)..."

# Download and source nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Load nvm into current shell session
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1090
source "$NVM_DIR/nvm.sh"

echo "🟢 Installing latest Node.js version..."
nvm install node

echo "🔁 Setting latest Node.js as default..."
nvm alias default node

echo "📦 Installing pnpm globally..."
npm install -g pnpm

echo "✅ Node.js and pnpm setup complete!"
echo "🌐 Node version: $(node -v)"
echo "📦 pnpm version: $(pnpm -v)"

