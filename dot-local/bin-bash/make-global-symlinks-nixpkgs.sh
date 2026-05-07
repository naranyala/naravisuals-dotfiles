#!/usr/bin/env bash
set -euo pipefail

# chmod +x make-global-symlinks-nixpkgs.sh

STORE_DIR="/nix/store"
TARGET_DIR="/usr/bin"
LOG_FILE="$HOME/nix-global-symlinks.log"
LOG_PREFIX="\e[1;32m[LINK]\e[0m"
SKIP_PREFIX="\e[1;33m[SKIP]\e[0m"
REPLACE_PREFIX="\e[1;34m[REPLACE]\e[0m"

log_link()    { echo -e "$LOG_PREFIX $*"; echo "[LINK] $*" >> "$LOG_FILE"; }
log_skip()    { echo -e "$SKIP_PREFIX $*"; echo "[SKIP] $*" >> "$LOG_FILE"; }
log_replace() { echo -e "$REPLACE_PREFIX $*"; echo "[REPLACE] $*" >> "$LOG_FILE"; }

# Reset log file
echo "# Symlink audit — $(date)" > "$LOG_FILE"
echo "# Target directory: $TARGET_DIR" >> "$LOG_FILE"
echo >> "$LOG_FILE"

for pkg in "$STORE_DIR"/*; do
    [[ -d "$pkg/bin" ]] || continue

    for bin in "$pkg/bin/"*; do
        [[ -x "$bin" && ! -d "$bin" ]] || continue
        name=$(basename "$bin")
        target="$TARGET_DIR/$name"

        if [[ -e "$target" ]]; then
            if [[ -L "$target" ]]; then
                # Replace existing symlink
                sudo ln -sf "$bin" "$target"
                log_replace "$name → $bin (replaced existing symlink)"
            else
                # Skip real binaries
                log_skip "$name is a real file in $TARGET_DIR — skipped ($bin)"
            fi
        else
            # Fresh symlink
            sudo ln -s "$bin" "$target"
            log_link "$name → $bin"
        fi
    done
done

echo -e "\n\e[1;34m[INFO]\e[0m Log saved to: $LOG_FILE"
