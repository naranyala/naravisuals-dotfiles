#!/usr/bin/env bash

## install-onlyoffice-and-drawio.sh
## Robust installer: continues on errors, logs failures.

set -euo pipefail

RELEASES=(
  "https://github.com/jgraph/drawio-desktop/releases/latest"
  "https://github.com/ONLYOFFICE/DesktopEditors/releases/latest"
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$SCRIPT_DIR/bin"
mkdir -p "$BIN_DIR"

LOG_FILE="$SCRIPT_DIR/install.log"
: > "$LOG_FILE"   # clear log at start

# === FUNCTIONS ===

detect_pkg_manager() {
  if command -v apt &>/dev/null; then
    echo "apt"
  elif command -v dnf &>/dev/null; then
    echo "dnf"
  elif command -v yum &>/dev/null; then
    echo "yum"
  elif command -v rpm &>/dev/null; then
    echo "rpm"
  else
    echo "none"
  fi
}

get_latest_asset_url() {
  local repo_url="$1"
  local asset_type="$2"
  local api_url="${repo_url/github.com/api.github.com\/repos}"
  curl -s "$api_url" \
    | grep -Eo "https://[^\"]+${asset_type}" \
    | head -n 1
}

download_pkg() {
  local url="$1"
  local dest="$BIN_DIR/$(basename "$url")"

  if [[ -f "$dest" ]]; then
    echo "Already downloaded: $dest"
  else
    echo "Downloading: $url"
    if ! curl -L "$url" -o "$dest"; then
      echo "❌ Failed to download $url" | tee -a "$LOG_FILE"
      return 1
    fi
  fi

  printf "%s\n" "$dest"
}

install_pkg() {
  local file="$1"
  local manager="$2"

  if [[ ! -f "$file" ]]; then
    echo "❌ Package file not found: $file" | tee -a "$LOG_FILE"
    return 1
  fi

  case "$manager" in
    apt)
      echo "Installing DEB with apt: $file"
      if ! sudo dpkg -i "$file"; then
        echo "⚠️ dpkg failed, attempting fix..."
        sudo apt-get install -f -y || {
          echo "❌ apt fix failed for $file" | tee -a "$LOG_FILE"
          return 1
        }
      fi
      ;;
    dnf)
      echo "Installing RPM with dnf: $file"
      sudo dnf install -y "$file" || {
        echo "❌ dnf failed for $file" | tee -a "$LOG_FILE"
        return 1
      }
      ;;
    yum)
      echo "Installing RPM with yum: $file"
      sudo yum install -y "$file" || {
        echo "❌ yum failed for $file" | tee -a "$LOG_FILE"
        return 1
      }
      ;;
    rpm)
      echo "Installing RPM directly: $file"
      sudo rpm -i "$file" || {
        echo "❌ rpm failed for $file" | tee -a "$LOG_FILE"
        return 1
      }
      ;;
    *)
      echo "❌ No supported package manager found." | tee -a "$LOG_FILE"
      return 1
      ;;
  esac
}

# === MAIN ===
manager=$(detect_pkg_manager)
echo "Detected package manager: $manager"

for repo in "${RELEASES[@]}"; do
  echo "Processing $repo"

  case "$manager" in
    apt) asset_url=$(get_latest_asset_url "$repo" "deb") ;;
    dnf|yum|rpm) asset_url=$(get_latest_asset_url "$repo" "rpm") ;;
    *) echo "Unsupported system"; exit 1 ;;
  esac

  if [[ -n "${asset_url:-}" ]]; then
    if pkg_file=$(download_pkg "$asset_url"); then
      install_pkg "$pkg_file" "$manager" || echo "⚠️ Skipped install for $pkg_file"
    else
      echo "⚠️ Skipped download for $repo"
    fi
  else
    echo "❌ No suitable package found for $repo" | tee -a "$LOG_FILE"
  fi
done

echo "✅ Script finished. Check $LOG_FILE for any errors."

