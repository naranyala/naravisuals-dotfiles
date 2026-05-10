#!/usr/bin/env bash

## install-nvm-nodejs-bun.sh
#!/usr/bin/env bash

set -euo pipefail

# === SAFETY CHECK ===
if [[ $EUID -eq 0 ]]; then
  echo "❌ Do not run this script as root or with sudo."
  echo "   Please run it as a normal user."
  exit 1
fi

# === FUNCTIONS ===

error_exit() {
  echo "❌ Error: $1" >&2
  exit 1
}

check_command() {
  local cmd="$1"
  if ! command -v "$cmd" &>/dev/null; then
    error_exit "Required command '$cmd' not found. Please install it first."
  fi
}

# === MAIN ===

# Check prerequisites
check_command curl
check_command bash

# Get latest NVM version dynamically
echo "⬇️ Fetching latest NVM version..."
NVM_VERSION=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest \
  | grep -Po '"tag_name": "\K.*?(?=")' || true)

[[ -n "$NVM_VERSION" ]] || error_exit "Could not determine latest NVM version."
echo "Latest NVM version: $NVM_VERSION"

# Download and install NVM
echo "⬇️ Installing NVM ($NVM_VERSION)..."
curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash || error_exit "Failed to install NVM."

# Load NVM without restarting shell
NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"
else
  error_exit "NVM script not found at $NVM_DIR/nvm.sh"
fi

# Install latest stable Node.js (LTS)
echo "⬇️ Installing latest stable Node.js..."
nvm install --lts || error_exit "Failed to install latest stable Node.js."

# Verify Node.js
NODE_VER=$(node -v || true)
[[ -n "$NODE_VER" ]] || error_exit "Node.js not found after installation."
echo "✅ Node.js version: $NODE_VER"

# Verify npm
NPM_VER=$(npm -v || true)
[[ -n "$NPM_VER" ]] || error_exit "npm not found after Node.js installation."
echo "✅ npm version: $NPM_VER"

# Install Bun
echo "⬇️ Installing Bun..."
curl -fsSL https://bun.sh/install | bash || error_exit "Failed to install Bun."

# Load Bun binary (default install path: ~/.bun/bin)
export PATH="$HOME/.bun/bin:$PATH"

# Verify Bun
BUN_VER=$(bun -v || true)
[[ -n "$BUN_VER" ]] || error_exit "Bun not found after installation."
echo "✅ Bun version: $BUN_VER"

echo "🎉 Installation complete! NVM, Node.js, npm, and Bun are ready."


