#!/usr/bin/env bash
set -euo pipefail

# Determine home directory
HOME=${HOME:-$(getent passwd "$(whoami)" | cut -d: -f6)}
[[ -z "$HOME" ]] && { echo "❌ Error: Could not determine home directory"; exit 1; }

# GDM theme collection (sourced from GNOME-Look.org or GitHub)
declare -A THEMES=(
    [orchis]="https://github.com/vinceliuice/Orchis-theme/archive/master.tar.gz"
    [whitesur]="https://github.com/vinceliuice/WhiteSur-gtk-theme/archive/master.tar.gz"
    [yaru]="https://github.com/ubuntu/yaru/archive/master.tar.gz"
    [adwaita-dark]="https://github.com/GNOME/gnome-shell/archive/main.tar.gz"
    [nordic]="https://github.com/EliverLara/Nordic/archive/master.tar.gz"
)

# Directories and files
THEME_BASE="/usr/share/themes"
GDM_RESOURCE_DIR="/usr/share/gnome-shell"
GDM_RESOURCE_FILE="$GDM_RESOURCE_DIR/gnome-shell-theme.gresource"
GDM_RESOURCE_BACKUP="$GDM_RESOURCE_DIR/gnome-shell-theme.gresource.bak.$(date +%F_%H-%M-%S)"
GDM_DCONF="/org/gnome/login-screen"
TEMP_WORKDIR="/tmp/gdm-theme-install"

# Arrays to track download status
declare -a DOWNLOAD_SUCCESS=()
declare -a DOWNLOAD_FAILED=()

# Cleanup function
cleanup() {
    local exit_code=$?
    [[ -n "${tmp_file:-}" && -f "$tmp_file" ]] && rm -f "$tmp_file"
    [[ -n "${extract_dir:-}" && -d "$extract_dir" ]] && rm -rf "$extract_dir"
    [[ -n "${temp_dir:-}" && -d "$temp_dir" ]] && rm -rf "$temp_dir"
    exit $exit_code
}
trap cleanup EXIT INT TERM

# Check dependencies
check_dependencies() {
    local deps=("curl" "glib-compile-resources" "dconf" "sudo")
    for dep in "${deps[@]}"; do
        command -v "$dep" >/dev/null 2>&1 || { echo "❌ Error: '$dep' required"; exit 1; }
    done
    sudo -n true 2>/dev/null || { echo "❌ Error: No sudo privileges"; exit 1; }
}

# Check network connectivity
check_connectivity() {
    if curl -fsSL --connect-timeout 5 --max-time 10 "https://github.com" -o /dev/null 2>/dev/null; then
        return 0
    else
        echo "❌ No internet connection, using existing themes"
        return 1
    fi
}

# Validate theme structure
theme_exists_and_valid() {
    local name="$1"
    local theme_dir="$THEME_BASE/$name"
    
    # Check if directory exists
    [[ ! -d "$theme_dir" ]] && return 1
    
    # Check for gnome-shell subdirectory and CSS file
    [[ -f "$theme_dir/gnome-shell/gnome-shell.css" ]] && return 0
    
    # Check subdirectories
    local subdirs
    mapfile -t subdirs < <(find "$theme_dir" -maxdepth 1 -mindepth 1 -type d 2>/dev/null || true)
    
    for subdir in "${subdirs[@]}"; do
        [[ -f "$subdir/gnome-shell/gnome-shell.css" ]] && return 0
    done
    
    return 1
}

# Compile theme into gresource
compile_theme() {
    local theme_dir="$1"
    local output_file="$2"
    
    # Create gresource XML
    local xml_file="$theme_dir/gnome-shell-theme.gresource.xml"
    echo '<?xml version="1.0" encoding="UTF-8"?>' > "$xml_file"
    echo '<gresources>' >> "$xml_file"
    echo '  <gresource prefix="/org/gnome/shell/theme">' >> "$xml_file"
    for file in "$theme_dir"/gnome-shell/*; do
        [[ -f "$file" ]] && echo "    <file>$(basename "$file")</file>" >> "$xml_file"
    done
    echo '  </gresource>' >> "$xml_file"
    echo '</gresources>' >> "$xml_file"
    
    # Compile
    if ! glib-compile-resources --sourcedir="$theme_dir/gnome-shell" --target="$output_file" "$xml_file"; then
        echo "❌ Failed to compile gresource for $theme_dir"
        return 1
    fi
    return 0
}

# Download and install theme
extract_theme() {
    local name="$1" url="$2"
    local tmp_file extract_dir
    
    if theme_exists_and_valid "$name"; then
        echo "✅ Theme '$name' already exists and is valid"
        DOWNLOAD_SUCCESS+=("$name")
        return 0
    fi
    
    echo "🌐 Fetching theme: $name"
    
    tmp_file=$(mktemp "$TEMP_WORKDIR/gdm-$name.XXXXXX.tar.gz") || {
        echo "❌ Failed to create temp file for $name"
        DOWNLOAD_FAILED+=("$name")
        return 1
    }
    
    extract_dir=$(mktemp -d "$TEMP_WORKDIR/gdm-extract-$name.XXXXXX") || {
        rm -f "$tmp_file"
        echo "❌ Failed to create temp dir for $name"
        DOWNLOAD_FAILED+=("$name")
        return 1
    }
    
    # Download with progress bar
    if ! curl -fsSL --connect-timeout 15 --max-time 60 --retry 2 --progress-bar "$url" -o "$tmp_file"; then
        echo "❌ Failed to download theme: $name"
        DOWNLOAD_FAILED+=("$name")
        rm -f "$tmp_file"
        rm -rf "$extract_dir"
        return 1
    fi
    
    if [[ ! -s "$tmp_file" ]]; then
        echo "❌ Empty download: $name"
        DOWNLOAD_FAILED+=("$name")
        rm -f "$tmp_file"
        rm -rf "$extract_dir"
        return 1
    fi
    
    # Extract
    if ! tar -xf "$tmp_file" -C "$extract_dir" --strip-components=1 2>/dev/null; then
        if ! tar -xf "$tmp_file" -C "$extract_dir" 2>/dev/null; then
            echo "❌ Failed to extract: $name"
            DOWNLOAD_FAILED+=("$name")
            rm -f "$tmp_file"
            rm -rf "$extract_dir"
            return 1
        fi
        
        # Find actual theme directory
        local theme_content
        mapfile -t theme_content < <(find "$extract_dir" -name "gnome-shell.css" -type f 2>/dev/null | head -1)
        if [[ ${#theme_content[@]} -gt 0 ]]; then
            local actual_theme_dir
            actual_theme_dir=$(dirname "$(dirname "${theme_content[0]}")")
            if [[ "$actual_theme_dir" != "$extract_dir" ]]; then
                temp_dir=$(mktemp -d "$TEMP_WORKDIR/gdm-move-$name.XXXXXX")
                mv "$actual_theme_dir"/* "$temp_dir"/ 2>/dev/null || true
                rm -rf "$extract_dir"
                mv "$temp_dir" "$extract_dir"
            fi
        fi
    fi
    
    # Validate extraction
    if [[ ! -f "$extract_dir/gnome-shell/gnome-shell.css" ]]; then
        echo "❌ Invalid theme structure: $name (missing gnome-shell/gnome-shell.css)"
        DOWNLOAD_FAILED+=("$name")
        rm -f "$tmp_file"
        rm -rf "$extract_dir"
        return 1
    fi
    
    # Install theme with sudo
    [[ -d "$THEME_BASE/$name" ]] && sudo rm -rf "$THEME_BASE/$name"
    
    sudo mkdir -p "$THEME_BASE"
    if ! sudo mv "$extract_dir" "$THEME_BASE/$name"; then
        echo "❌ Failed to install theme: $name"
        DOWNLOAD_FAILED+=("$name")
        rm -f "$tmp_file"
        rm -rf "$extract_dir"
        return 1
    fi
    
    # Set permissions
    sudo chown -R root:root "$THEME_BASE/$name"
    sudo chmod -R 755 "$THEME_BASE/$name"
    
    rm -f "$tmp_file"
    echo "✅ Successfully installed: $name"
    DOWNLOAD_SUCCESS+=("$name")
    return 0
}

# Get available themes
get_available_themes() {
    local -a all_themes valid_themes
    
    if [[ -d "$THEME_BASE" ]]; then
        mapfile -t all_themes < <(find "$THEME_BASE" -maxdepth 1 -mindepth 1 -type d -printf '%f\n' 2>/dev/null | sort)
    fi
    
    for theme in "${all_themes[@]}"; do
        if theme_exists_and_valid "$theme"; then
            valid_themes+=("$theme")
        else
            echo "⚠️ Invalid theme found: $theme" >&2
        fi
    done
    
    printf '%s\n' "${valid_themes[@]}"
}

# Show theme info
show_theme_info() {
    local theme="$1"
    local theme_dir="$THEME_BASE/$theme"
    local css_count
    
    css_count=$(find "$theme_dir" -name "gnome-shell.css" -type f 2>/dev/null | wc -l)
    echo "    └─ $css_count gnome-shell.css files found"
}

# Apply theme
apply_theme() {
    local theme="$1"
    
    # Backup existing gresource
    if [[ -f "$GDM_RESOURCE_FILE" ]]; then
        sudo cp "$GDM_RESOURCE_FILE" "$GDM_RESOURCE_BACKUP" || {
            echo "⚠️ Warning: Failed to create backup of $GDM_RESOURCE_FILE"
        }
    fi
    
    # Compile and install theme
    if ! compile_theme "$THEME_BASE/$theme" "$TEMP_WORKDIR/gnome-shell-theme.gresource"; then
        echo "❌ Failed to compile theme: $theme"
        return 1
    fi
    
    sudo mv "$TEMP_WORKDIR/gnome-shell-theme.gresource" "$GDM_RESOURCE_FILE" || {
        echo "❌ Failed to install gresource file"
        return 1
    }
    
    # Set permissions
    sudo chown root:root "$GDM_RESOURCE_FILE"
    sudo chmod 644 "$GDM_RESOURCE_FILE"
    
    echo "✅ Theme '$theme' applied successfully"
    return 0
}

# Set background image via DConf
set_background() {
    local image_path="$1"
    
    if [[ ! -f "$image_path" ]]; then
        echo "❌ Background image not found: $image_path"
        return 1
    fi
    
    # Copy image to system directory
    local target_image="/usr/share/backgrounds/gdm-background-$(basename "$image_path")"
    sudo cp "$image_path" "$target_image" || {
        echo "❌ Failed to copy background image"
        return 1
    }
    
    sudo chown root:root "$target_image"
    sudo chmod 644 "$target_image"
    
    # Set DConf setting
    sudo -u gdm dbus-launch gsettings set org.gnome.desktop.background picture-uri "file://$target_image" || {
        echo "❌ Failed to set background via DConf"
        return 1
    }
    
    echo "✅ Background image set: $target_image"
    return 0
}

# Main process
main() {
    echo "🎨 GDM Theme Manager"
    echo "===================="
    
    check_dependencies
    mkdir -p "$TEMP_WORKDIR"
    
    # Download themes if online
    ONLINE_MODE=false
    if check_connectivity; then
        ONLINE_MODE=true
        echo "🌐 Online mode: downloading ${#THEMES[@]} themes..."
        echo
        
        local count=0
        for name in "${!THEMES[@]}"; do
            count=$((count + 1))
            echo "[$count/${#THEMES[@]}] Processing $name..."
            extract_theme "$name" "${THEMES[$name]}"
        done
        
        echo
        if [[ ${#DOWNLOAD_SUCCESS[@]} -gt 0 ]]; then
            echo "✅ Successfully processed (${#DOWNLOAD_SUCCESS[@]}): ${DOWNLOAD_SUCCESS[*]}"
        fi
        if [[ ${#DOWNLOAD_FAILED[@]} -gt 0 ]]; then
            echo "❌ Failed downloads (${#DOWNLOAD_FAILED[@]}): ${DOWNLOAD_FAILED[*]}"
        fi
    else
        echo "📱 Offline mode: using existing themes only"
    fi
    
    echo
    echo "🔍 Scanning for available themes..."
    
    local choices
    mapfile -t choices < <(get_available_themes)
    
    if [[ ${#choices[@]} -eq 0 ]]; then
        echo "❌ No valid themes found in $THEME_BASE"
        if [[ "$ONLINE_MODE" == "true" ]]; then
            echo "   All downloads failed or produced invalid themes"
            echo "   Check your internet connection and try again"
        else
            echo "   Connect to internet to download themes"
        fi
        exit 1
    fi
    
    echo
    echo "🖼️ Available Themes (${#choices[@]} found):"
    for i in "${!choices[@]}"; do
        echo "  $((i+1)). ${choices[$i]}"
        show_theme_info "${choices[$i]}"
    done
    echo
    
    # Theme selection
    while true; do
        read -p "🎯 Choose theme (1-${#choices[@]}) or 'q' to quit: " -r selection
        
        if [[ "$selection" == "q" || "$selection" == "Q" ]]; then
            echo "👋 Goodbye!"
            exit 0
        fi
        
        if [[ "$selection" =~ ^[0-9]+$ ]] && (( selection >= 1 && selection <= ${#choices[@]} )); then
            selected_theme="${choices[$((selection-1))]}"
            echo "📝 Applying theme '$selected_theme'..."
            
            if apply_theme "$selected_theme"; then
                echo "ℹ️  Log out or restart to see changes"
            else
                echo "❌ Failed to apply theme"
                exit 1
            fi
            
            # Optional: Prompt for background image
            read -p "🎨 Enter path to background image (or press Enter to skip): " -r bg_image
            if [[ -n "$bg_image" ]]; then
                if ! set_background "$bg_image"; then
                    echo "⚠️ Warning: Background image not applied"
                fi
            fi
            break
        else
            echo "❌ Invalid selection. Please enter a number between 1 and ${#choices[@]}, or 'q' to quit."
        fi
    done
}

# Run main function
main
