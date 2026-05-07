
#!/usr/bin/env bash

set -euo pipefail

# Configurable options
TARGET_DIR="/usr/bin"
LOG_FILE="/var/log/delete_symlinks_$(date +%F_%T).log"
DRY_RUN=false  # Set to true to preview actions without deleting

# Ensure log file is writable
touch "$LOG_FILE" || {
    echo "❌ Cannot write to log file: $LOG_FILE"
    exit 1
}

echo "🔍 Scanning for symlinks in $TARGET_DIR..." | tee -a "$LOG_FILE"

# Find symlinks only (not broken ones)
mapfile -t SYMLINKS < <(find "$TARGET_DIR" -maxdepth 1 -type l)

if [[ ${#SYMLINKS[@]} -eq 0 ]]; then
    echo "✅ No symlinks found in $TARGET_DIR." | tee -a "$LOG_FILE"
    exit 0
fi

for LINK in "${SYMLINKS[@]}"; do
    if [[ "$DRY_RUN" == true ]]; then
        echo "📝 DRY RUN: Would delete symlink: $LINK" | tee -a "$LOG_FILE"
    else
        if rm "$LINK"; then
            echo "🗑️ Deleted symlink: $LINK" | tee -a "$LOG_FILE"
        else
            echo "⚠️ Failed to delete: $LINK" | tee -a "$LOG_FILE"
        fi
    fi
done

echo "📄 Log saved to: $LOG_FILE"
