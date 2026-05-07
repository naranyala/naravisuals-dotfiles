#!/usr/bin/env bash
set -euo pipefail

# LightDM Theme Manager - Minimal version with maximum themes
# Supports both GTK and WebKit2 greeters

# Configuration
THEMES_DIR="/usr/share/lightdm-webkit/themes"
GTK_THEMES_DIR="/usr/share/themes"
CONFIG_FILE="/etc/lightdm/lightdm-webkit2-greeter.conf"
GTK_CONFIG="/etc/lightdm/lightdm-gtk-greeter.conf"
LIGHTDM_CONFIG="/etc/lightdm/lightdm.conf"

# WebKit2 Themes Collection - Most popular and lightweight
declare -A WEBKIT_THEMES=(
    [glorious]="https://github.com/eromatiya/lightdm-webkit2-theme-glorious/archive/master.tar.gz"
    [litarvan]="https://github.com/Litarvan/lightdm-webkit-theme-litarvan/archive/master.tar.gz"
    [material2]="https://github.com/FallingSnow/lightdm-webkit2-material2/archive/master.tar.gz"
    [hacker]="https://github.com/devCote/Lightdm-Hacker-Theme/archive/master.tar.gz"
    # [minimal]="https://github.com/adi1090x/lightdm-webkit2-themes/archive/master.tar.gz"
    [aether]="https://github.com/NoiSek/Aether/archive/master.tar.gz"
    [sequoia]="https://github.com/Matt-MX/LightDM-Webkit2-Sequoia/archive/main.tar.gz"
    [shikai]="https://github.com/TheWisker/Shikai/archive/main.tar.gz"
    # [osmos]="https://github.com/HaleTom/lightdm-webkit2-theme-osmos/archive/master.tar.gz"
    [arch]="https://github.com/manilarome/lightdm-webkit2-theme-arch/archive/master.tar.gz"
    [proxima]="https://github.com/a-raccoon/lightdm-webkit2-theme-proxima/archive/master.tar.gz"
    [forest]="https://github.com/codehearts/lightdm-webkit2-theme-forest/archive/master.tar.gz"
)

# GTK Themes (fallback)
declare -A GTK_THEMES=(
    [arc]="https://github.com/jnsh/arc-theme/archive/master.tar.gz"
    [numix]="https://github.com/numixproject/numix-gtk-theme/archive/master.tar.gz"
    [adapta]="https://github.com/adapta-project/adapta-gtk-theme/archive/master.tar.gz"
    [materia]="https://github.com/nana-4/materia-theme/archive/master.tar.gz"
)

# Status arrays
declare -a SUCCESS=() FAILED=()

# Minimal error handling
err() { echo "❌ $1" >&2; exit 1; }
ok() { echo "✅ $1"; }
info() { echo "ℹ️ $1"; }

# Check prerequisites
check_system() {
    command -v sudo >/dev/null || err "sudo required"
    sudo -n true 2>/dev/null || err "Need sudo privileges"
    
    # Detect active greeter
    local greeter="none"
    if systemctl is-active lightdm >/dev/null 2>&1; then
        if [[ -f "$CONFIG_FILE" ]]; then
            greeter="webkit2"
        elif [[ -f "$GTK_CONFIG" ]]; then
            greeter="gtk"
        fi
    else
        info "LightDM not active - will configure anyway"
    fi
    
    echo "🔍 Detected greeter: $greeter"
    export ACTIVE_GREETER="$greeter"
}

# Network check
online() {
    curl -fsSL --connect-timeout 3 --max-time 5 "https://github.com" -o /dev/null 2>/dev/null
}

# Download and extract theme
get_theme() {
    local name="$1" url="$2" type="$3"
    local tmp_file extract_dir target_dir
    
    tmp_file=$(mktemp) || return 1
    extract_dir=$(mktemp -d) || { rm -f "$tmp_file"; return 1; }
    
    # Set target directory based on type
    case "$type" in
        webkit) target_dir="$THEMES_DIR/$name" ;;
        gtk) target_dir="$GTK_THEMES_DIR/$name" ;;
        *) rm -rf "$tmp_file" "$extract_dir"; return 1 ;;
    esac
    
    # Skip if exists
    if [[ -d "$target_dir" ]]; then
        ok "Theme '$name' exists"
        SUCCESS+=("$name")
        rm -rf "$tmp_file" "$extract_dir"
        return 0
    fi
    
    echo "📥 $name"
    
    # Download
    if ! curl -fsSL --connect-timeout 10 --max-time 30 "$url" -o "$tmp_file"; then
        FAILED+=("$name")
        rm -rf "$tmp_file" "$extract_dir"
        return 1
    fi
    
    # Extract
    if ! tar -xf "$tmp_file" -C "$extract_dir" --strip-components=1 2>/dev/null; then
        FAILED+=("$name")
        rm -rf "$tmp_file" "$extract_dir"
        return 1
    fi
    
    # Install
    sudo mkdir -p "$(dirname "$target_dir")"
    if sudo mv "$extract_dir" "$target_dir"; then
        SUCCESS+=("$name")
        ok "$name installed"
    else
        FAILED+=("$name")
    fi
    
    rm -f "$tmp_file"
}

# Download all themes
download_themes() {
    online || { info "Offline - using existing themes"; return; }
    
    echo "📦 Downloading ${#WEBKIT_THEMES[@]} WebKit themes..."
    for name in "${!WEBKIT_THEMES[@]}"; do
        get_theme "$name" "${WEBKIT_THEMES[$name]}" "webkit"
    done
    
    echo "📦 Downloading ${#GTK_THEMES[@]} GTK themes..."
    for name in "${!GTK_THEMES[@]}"; do
        get_theme "$name" "${GTK_THEMES[$name]}" "gtk"
    done
    
    # Results
    [[ ${#SUCCESS[@]} -gt 0 ]] && ok "Downloaded: ${SUCCESS[*]}"
    [[ ${#FAILED[@]} -gt 0 ]] && echo "❌ Failed: ${FAILED[*]}"
}

# List available themes
list_themes() {
    local -a webkit_themes=() gtk_themes=()
    
    # WebKit themes
    if [[ -d "$THEMES_DIR" ]]; then
        mapfile -t webkit_themes < <(find "$THEMES_DIR" -maxdepth 1 -mindepth 1 -type d -printf '%f\n' 2>/dev/null | sort)
    fi
    
    # GTK themes
    if [[ -d "$GTK_THEMES_DIR" ]]; then
        mapfile -t gtk_themes < <(find "$GTK_THEMES_DIR" -maxdepth 1 -mindepth 1 -type d -printf '%f\n' 2>/dev/null | sort)
    fi
    
    echo "🖼️ WebKit Themes (${#webkit_themes[@]}):"
    printf '  %s\n' "${webkit_themes[@]}"
    echo
    echo "🎨 GTK Themes (${#gtk_themes[@]}):"
    printf '  %s\n' "${gtk_themes[@]}"
}

# Configure WebKit greeter
set_webkit_theme() {
    local theme="$1"
    local config_dir=$(dirname "$CONFIG_FILE")
    
    # Ensure webkit2 greeter is active
    sudo mkdir -p "$config_dir"
    
    # Set greeter in lightdm.conf
    if [[ -f "$LIGHTDM_CONFIG" ]]; then
        sudo sed -i 's/^#*greeter-session=.*/greeter-session=lightdm-webkit2-greeter/' "$LIGHTDM_CONFIG"
    else
        echo -e "[Seat:*]\ngreeter-session=lightdm-webkit2-greeter" | sudo tee "$LIGHTDM_CONFIG" >/dev/null
    fi
    
    # Configure webkit theme
    if [[ -f "$CONFIG_FILE" ]]; then
        sudo sed -i "s/^#*webkit_theme=.*/webkit_theme=$theme/" "$CONFIG_FILE"
        sudo sed -i 's/^#*debug_mode=.*/debug_mode=false/' "$CONFIG_FILE"
    else
        cat << EOF | sudo tee "$CONFIG_FILE" >/dev/null
[greeter]
webkit_theme=$theme
debug_mode=false
EOF
    fi
    
    ok "Set WebKit theme: $theme"
}

# Configure GTK greeter
set_gtk_theme() {
    local theme="$1"
    local config_dir=$(dirname "$GTK_CONFIG")
    
    # Ensure gtk greeter is active
    sudo mkdir -p "$config_dir"
    
    # Set greeter in lightdm.conf
    if [[ -f "$LIGHTDM_CONFIG" ]]; then
        sudo sed -i 's/^#*greeter-session=.*/greeter-session=lightdm-gtk-greeter/' "$LIGHTDM_CONFIG"
    else
        echo -e "[Seat:*]\ngreeter-session=lightdm-gtk-greeter" | sudo tee "$LIGHTDM_CONFIG" >/dev/null
    fi
    
    # Configure gtk theme
    if [[ -f "$GTK_CONFIG" ]]; then
        sudo sed -i "s/^#*theme-name=.*/theme-name=$theme/" "$GTK_CONFIG"
    else
        cat << EOF | sudo tee "$GTK_CONFIG" >/dev/null
[greeter]
theme-name=$theme
EOF
    fi
    
    ok "Set GTK theme: $theme"
}

# Apply theme
apply_theme() {
    local theme="$1" type="$2"
    
    case "$type" in
        webkit)
            [[ ! -d "$THEMES_DIR/$theme" ]] && err "WebKit theme '$theme' not found"
            set_webkit_theme "$theme"
            ;;
        gtk)
            [[ ! -d "$GTK_THEMES_DIR/$theme" ]] && err "GTK theme '$theme' not found"
            set_gtk_theme "$theme"
            ;;
        *)
            err "Invalid theme type: $type"
            ;;
    esac
    
    info "Restart LightDM: sudo systemctl restart lightdm"
}

# Interactive theme selection
select_theme() {
    local -a all_themes=()
    local -a theme_types=()
    
    # Collect all themes
    if [[ -d "$THEMES_DIR" ]]; then
        while IFS= read -r -d '' theme; do
            all_themes+=("$(basename "$theme")")
            theme_types+=("webkit")
        done < <(find "$THEMES_DIR" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null)
    fi
    
    if [[ -d "$GTK_THEMES_DIR" ]]; then
        while IFS= read -r -d '' theme; do
            all_themes+=("$(basename "$theme")")
            theme_types+=("gtk")
        done < <(find "$GTK_THEMES_DIR" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null)
    fi
    
    [[ ${#all_themes[@]} -eq 0 ]] && err "No themes found"
    
    echo "📋 Available Themes:"
    for i in "${!all_themes[@]}"; do
        printf "%2d. %-20s (%s)\n" $((i+1)) "${all_themes[$i]}" "${theme_types[$i]}"
    done
    
    while true; do
        read -p "🎯 Select theme (1-${#all_themes[@]}) or 'q': " choice
        
        if [[ "$choice" == "q" ]]; then
            exit 0
        elif [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#all_themes[@]} )); then
            local idx=$((choice-1))
            apply_theme "${all_themes[$idx]}" "${theme_types[$idx]}"
            break
        else
            echo "❌ Invalid choice"
        fi
    done
}

# Show usage
usage() {
    cat << EOF
🎨 LightDM Theme Manager (Minimal)

Usage: $0 [COMMAND] [OPTIONS]

Commands:
  download          Download all available themes
  list             List installed themes  
  apply <theme>    Apply specific theme
  select           Interactive theme selection
  
Examples:
  $0 download
  $0 apply glorious
  $0 select
EOF
}

# Main function
main() {
    [[ $# -eq 0 ]] && { usage; exit 1; }
    
    check_system
    
    case "$1" in
        download)
            download_themes
            ;;
        list)
            list_themes
            ;;
        apply)
            [[ $# -ne 2 ]] && err "Usage: $0 apply <theme>"
            # Auto-detect theme type
            if [[ -d "$THEMES_DIR/$2" ]]; then
                apply_theme "$2" "webkit"
            elif [[ -d "$GTK_THEMES_DIR/$2" ]]; then
                apply_theme "$2" "gtk"
            else
                err "Theme '$2' not found"
            fi
            ;;
        select)
            select_theme
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"
