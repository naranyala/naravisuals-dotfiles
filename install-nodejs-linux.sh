#!/bin/bash

echo "Starting Node.js reinstallation..."

# 1. Completely remove existing Node.js and npm from system paths
sudo apt-get purge -y nodejs npm 2>/dev/null
sudo rm -rf /usr/local/bin/node /usr/local/bin/npm /usr/local/lib/node_modules
sudo rm -rf ~/.npm ~/.node-gyp

# 2. Install NVM (Node Version Manager)
# This allows managing versions without sudo and fixes common cert issues
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# 3. Load NVM into the current script session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 4. Install the latest Long-Term Support (LTS) version of Node.js
nvm install --lts
nvm use --lts
nvm alias default --lts

echo "Reinstallation complete!"
node -v
npm -v

