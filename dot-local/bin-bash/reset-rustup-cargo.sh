#!/usr/bin/env bash
set -euo pipefail

# Config
BACKUP_DIR="${HOME}/rust-reset-backup-$(date +%Y%m%d%H%M%S)"
RUSTUP_INIT_URL="https://sh.rustup.rs"

echo "Creating backup at: ${BACKUP_DIR}"
mkdir -p "${BACKUP_DIR}"

# 1) Backup user rust directories if present
for d in "${HOME}/.cargo" "${HOME}/.rustup"; do
  if [ -d "${d}" ]; then
    echo "Backing up ${d}"
    mv "${d}" "${BACKUP_DIR}/$(basename "${d}")"
  fi
done

# 2) Try rustup self-uninstall if rustup exists (preferred)
if command -v rustup >/dev/null 2>&1; then
  echo "Running: rustup self uninstall -y"
  rustup self uninstall -y || echo "rustup self uninstall failed; continuing with manual cleanup"
fi

# 3) Remove leftover user-level files
echo "Removing leftover user-level files (if any)"
rm -rf "${HOME}/.cargo" "${HOME}/.rustup" "${HOME}/.rustup-toolchains" "${HOME}/.rustup-update" || true

# 4) Attempt to remove system packages (Debian/Ubuntu and Fedora/CentOS examples)
if command -v apt >/dev/null 2>&1; then
  echo "Attempting to purge system Rust packages via apt (requires sudo)"
  sudo apt remove --purge -y rustc cargo || true
  sudo apt autoremove -y || true
fi

if command -v dnf >/dev/null 2>&1; then
  echo "Attempting to remove system Rust packages via dnf (requires sudo)"
  sudo dnf remove -y rust cargo || true
fi

# 5) Remove stray binaries in common locations (careful)
for p in /usr/local/bin/rustc /usr/local/bin/cargo /usr/bin/rustc /usr/bin/cargo; do
  if [ -f "${p}" ]; then
    echo "Removing ${p} (requires sudo)"
    sudo rm -f "${p}" || true
  fi
done

# 6) Clean PATH entries in shell rc files (non-destructive: create backups)
RC_FILES=("${HOME}/.profile" "${HOME}/.bashrc" "${HOME}/.bash_profile" "${HOME}/.zshrc")
for rc in "${RC_FILES[@]}"; do
  if [ -f "${rc}" ]; then
    cp "${rc}" "${rc}.rust-reset-backup"
    # remove lines that add ~/.cargo/bin to PATH
    sed -i '/CARGO_HOME/d; /\\.cargo\\/bin/d; /rustup/d' "${rc}" || true
  fi
done

# 7) Reinstall rustup (user-level) non-interactively
echo "Reinstalling rustup (user-level) using official installer"
curl --proto '=https' --tlsv1.2 -sSf "${RUSTUP_INIT_URL}" | sh -s -- -y

echo "Done. Please open a new shell or source your profile to pick up the new PATH."
echo "Backups are in: ${BACKUP_DIR}"

