#!/usr/bin/env bash
set -euo pipefail

# 🧾 Config
DEFAULT_NIX_FILE="$HOME/.default-nix-shell.nix"
SHELL_WRAPPER_FLAG="IN_NIX_SHELL"
BASHRC="$HOME/.bashrc"
ZSHRC="$HOME/.zshrc"

# 📦 Step 1: Install Nix if missing
if ! command -v nix-shell &>/dev/null; then
  echo "🔧 Installing Nix package manager..."
  curl -L https://nixos.org/nix/install | sh
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# 🧪 Step 2: Verify nix-shell
if ! command -v nix-shell &>/dev/null; then
  echo "❌ nix-shell not found after install. Aborting."
  exit 1
fi

# 📝 Step 3: Create default nix-shell environment
if [[ ! -f "$DEFAULT_NIX_FILE" ]]; then
  cat > "$DEFAULT_NIX_FILE" <<'EOF'
with import <nixpkgs> {};

mkShell {
  buildInputs = [ bash git coreutils ];
  shellHook = ''
    echo "✅ Entered default nix-shell environment"
  '';
}
EOF
  echo "📁 Created default nix-shell environment at $DEFAULT_NIX_FILE"
fi

# 🔁 Step 4: Inject wrapper into .bashrc / .zshrc
inject_wrapper() {
  local rcfile="$1"
  if [[ -f "$rcfile" ]] && ! grep -q "$SHELL_WRAPPER_FLAG" "$rcfile"; then
    echo "🔁 Injecting nix-shell wrapper into $rcfile"
    cat >> "$rcfile" <<EOF

# 🚀 Auto-launch nix-shell as default shell
if [[ -z "\$$SHELL_WRAPPER_FLAG" && -f "$DEFAULT_NIX_FILE" ]]; then
  export $SHELL_WRAPPER_FLAG=1
  exec nix-shell "$DEFAULT_NIX_FILE"
fi
EOF
  fi
}

inject_wrapper "$BASHRC"
inject_wrapper "$ZSHRC"

# ✅ Step 5: Confirm
echo "🎉 nix-shell is now set to launch by default in your shell sessions."
echo "You can customize the environment in: $DEFAULT_NIX_FILE"

