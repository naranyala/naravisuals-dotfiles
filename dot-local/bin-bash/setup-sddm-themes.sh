#!/usr/bin/env bash
set -euo pipefail

# Determine home directory
HOME=${HOME:-$(getent passwd "$(whoami)" | cut -d: -f6)}
[[ -z "$HOME" ]] && { echo "❌ Error: Could not determine home directory"; exit 1; }

# Extended theme collection with popular SDDM themes
declare -A THEMES=(
    [slice]="https://github.com/RadRussianRus/sddm-slice/archive/master.tar.gz"
    [tokyo-night]="https://github.com/rototrash/tokyo-night-sddm/archive/master.tar.gz"
    [astronaut]="https://github.com/Keyitdev/sddm-astronaut-theme/archive/master.tar.gz"
    [catppuccin]="https://github.com/catppuccin/sddm/archive/main.tar.gz"
    [chili]="https://github.com/MarianArlt/sddm-chili/archive/master.tar.gz"
    [corners]="https://github.com/aczw/sddm-theme-corners/archive/main.tar.gz"
    [delicious]="https://github.com/stuomas/delicious-sddm-theme/archive/master.tar.gz"
    [sugar-candy]="https://github.com/Kangie/sddm-sugar-candy/archive/master.tar.gz"
    [abstractdark]="https://github.com/3ximus/abstractdark-sddm-theme/archive/master.tar.gz"
    [aerial]="https://github.com/3ximus/aerial-sddm-theme/archive/master.tar.gz"
    [breeze]="https://github.com/KDE/plasma-workspace/archive/master.tar.gz"
    [elegant]="https://github.com/surajmandalcell/elegant-sddm/archive/master.tar.gz"
    [maya]="https://github.com/MayaPolway/sddm-maya/archive/master.tar.gz"
    [nordic]="https://github.com/Sacules/Nordic-sddm/archive/master.tar.gz"
    [sugar-dark]="https://github.com/MarianArlt/sddm-sugar-dark/archive/master.tar.gz"
    [win10os-login]="https://github.com/aviallon/sddm-win10os-login/archive/master.tar.gz"
)

# Directories and files
THEME_BASE="/usr/share/sddm/themes"  # Default to system-wide directory
SDDM_CONF_DIR="/etc/sddm.conf.d"
SDDM_CONF="$SDDM_CONF_DIR/theme.conf"
SDDM_CONF_FALLBACK="/etc/sddm.conf"
SDDM_CONF_BACKUP="${SDDM_CONF}.bak.$(date +%F_%H-%M-%S)"

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

# Check sudo
command -v sudo >/dev/null 2>&1 || { echo "❌ Error: 'sudo' required"; exit 1; }
sudo -n true 2>/dev/null || { echo "❌ Error: No sudo privileges"; exit 1; }

# Check SDDM config path
check_sddm_conf() {
    if [[ -d "$SDDM_CONF_DIR" ]]; then
        return 0
    elif [[ -f "$SDDM_CONF_FALLBACK" ]]; then
        SDDM_CONF="$SDDM_CONF_FALLBACK"
        return 0
    else
        echo "⚠️ No valid SDDM config path found, creating $SDDM_CONF_DIR"
        sudo mkdir -p "$SDDM_CONF_DIR" || { echo "❌ Failed to create $SDDM_CONF_DIR"; exit 1; }
        return 0
    fi
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

# Improved theme validation
theme_exists_and_valid() {
    local name="$1"
    local theme_dir="$THEME_BASE/$name"
    
    # Check if directory exists
    [[ ! -d "$theme_dir" ]] && return 1
    
    # List of possible QML entry files
    local qml_files=(
        "Main.qml"
        "main.qml"
        "theme.qml"
        "Theme.qml"
        "index.qml"
        "Index.qml"
        "Login.qml"
        "login.qml"
    )
    
    # Check for any valid QML file and theme metadata
    local has_qml=false has_metadata=false
    for qml_file in "${qml_files[@]}"; do
        [[ -f "$theme_dir/$qml_file" ]] && has_qml=true && break
    done
    
    [[ -f "$theme_dir/theme.conf" || -f "$theme_dir/metadata.desktop" ]] && has_metadata=true
    
    # Theme is valid only if both QML and metadata exist
    [[ "$has_qml" == "true" && "$has_metadata" == "true" ]] && return 0
    
    # Check subdirectories
    local subdirs
    mapfile -t subdirs < <(find "$theme_dir" -maxdepth 1 -mindepth 1 -type d 2>/dev/null || true)
    
    for subdir in "${subdirs[@]}"; do
        has_qml=false
        has_metadata=false
        for qml_file in "${qml_files[@]}"; do
            [[ -f "$subdir/$qml_file" ]] && has_qml=true && break
        done
        [[ -f "$subdir/theme.conf" || -f "$subdir/metadata.desktop" ]] && has_metadata=true
        [[ "$has_qml" == "true" && "$has_metadata" == "true" ]] && return 0
    done
    
    return 1
}

# Download and extract theme
extract_theme() {
    local name="$1" url="$2"
    local tmp_file extract_dir
    
    if theme_exists_and_valid "$name"; then
        echo "✅ Theme '$name' already exists and is valid"
        DOWNLOAD_SUCCESS+=("$name")
        return 0
    fi
    
    echo "🌐 Fetching theme: $name"
    
    tmp_file=$(mktemp "/tmp/sddm-$name.XXXXXX.tar.gz") || { 
        echo "❌ Failed to create temp file for $name"; 
        DOWNLOAD_FAILED+=("$name")
        return 1; 
    }
    
    extract_dir=$(mktemp -d "/tmp/sddm-extract-$name.XXXXXX") || { 
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
    
    # Extract with error handling
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
        mapfile -t theme_content < <(find "$extract_dir" -name "*.qml" -type f 2>/dev/null | head -1)
        if [[ ${#theme_content[@]} -gt 0 ]]; then
            local actual_theme_dir
            actual_theme_dir=$(dirname "${theme_content[0]}")
            if [[ "$actual_theme_dir" != "$extract_dir" ]]; then
                temp_dir=$(mktemp -d "/tmp/sddm-move-$name.XXXXXX")
                mv "$actual_theme_dir"/* "$temp_dir"/ 2>/dev/null || true
                rm -rf "$extract_dir"
                mv "$temp_dir" "$extract_dir"
            fi
        fi
    fi
    
    # Validate extraction
    local qml_files metadata_files
    mapfile -t qml_files < <(find "$extract_dir" -name "*.qml" -type f 2>/dev/null)
    mapfile -t metadata_files < <(find "$extract_dir" \( -name "theme.conf" -o -name "metadata.desktop" \) -type f 2>/dev/null)
    
    if [[ ${#qml_files[@]} -eq 0 || ${#metadata_files[@]} -eq 0 ]]; then
        echo "❌ Invalid theme structure: $name (missing QML or metadata)"
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
    
    # Set correct permissions
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
    local qml_count metadata_count
    
    qml_count=$(find "$theme_dir" -name "*.qml" -type f 2>/dev/null | wc -l)
    metadata_count=$(find "$theme_dir" \( -name "theme.conf" -o -name "metadata.desktop" \) -type f 2>/dev/null | wc -l)
    
    echo "    └─ $qml_count QML files, $metadata_count metadata files"
    
    local main_qml
    for qml_file in "Main.qml" "main.qml" "theme.qml" "Theme.qml"; do
        if [[ -f "$theme_dir/$qml_file" ]]; then
            main_qml="$qml_file"
            break
        fi
    done
    
    [[ -n "$main_qml" ]] && echo "    └─ Entry point: $main_qml"
}

# Main process
main() {
    echo "🎨 SDDM Theme Manager"
    echo "===================="

    check_sddm_conf

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

    # Theme selection with robust input validation
    while true; do
        read -p "🎯 Choose theme (1-${#choices[@]}) or 'q' to quit: " -r selection
        
        if [[ "$selection" == "q" || "$selection" == "Q" ]]; then
            echo "👋 Goodbye!"
            exit 0
        fi
        
        if [[ "$selection" =~ ^[0-9]+$ ]] && (( selection >= 1 && selection <= ${#choices[@]} )); then
            selected_theme="${choices[$((selection-1))]}"
            echo "📝 Applying theme '$selected_theme'..."
            
            # Backup existing config
            if [[ -f "$SDDM_CONF" ]]; then
                sudo cp "$SDDM_CONF" "$SDDM_CONF_BACKUP" || {
                    echo "⚠️ Warning: Failed to create backup of $SDDM_CONF"
                }
            fi
            
            # Write SDDM config
            if echo -e "[Theme]\nCurrent=$selected_theme" | sudo tee "$SDDM_CONF" >/dev/null; then
                echo "✅ Theme '$selected_theme' applied successfully!"
                echo "ℹ️  Restart SDDM to see changes: sudo systemctl restart sddm"
                echo "ℹ️  Or restart your system for the changes to take effect"
            else
                echo "❌ Failed to write SDDM config"
                exit 1
            fi
            break
        else
            echo "❌ Invalid selection. Please enter a number between 1 and ${#choices[@]}, or 'q' to quit."
        fi
    done
}

# Run main function
main
