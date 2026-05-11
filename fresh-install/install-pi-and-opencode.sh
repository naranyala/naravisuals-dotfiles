#!/bin/bash
# Script to install coding agents: OpenCode and Pi.dev

set -e  # Exit immediately if a command fails

echo "Installing OpenCode agent..."
curl -fsSL https://opencode.ai/install | bash

echo "Installing Pi.dev agent..."
curl -fsSL https://pi.dev/install.sh | sh

echo "✅ Installation complete!"

