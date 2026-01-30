#!/usr/bin/env bash
# install-bun.sh - Bun JavaScript runtime
set -euo pipefail

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required. Please install curl and re-run."; exit 1
fi

# Install Bun
curl -fsSL https://bun.sh/install | bash

# Add Bun to PATH for current session if installed to ~/.bun
if [ -d "$HOME/.bun/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.bun/bin:"*) ;;
    *) export PATH="$HOME/.bun/bin:$PATH" ;;
  esac
fi

echo "Bun installed. Version:"
bun --version || echo "Open a new shell to use bun if not detected."

