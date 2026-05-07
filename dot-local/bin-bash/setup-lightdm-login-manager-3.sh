#!/usr/bin/env bash
set -euo pipefail

# Configuration
THEME_BASE="/usr/share/lightdm-webkit/themes"
CONF_FILE="/etc/lightdm/lightdm-webkit2-greeter.conf"
BACKUP_DIR="/usr/share/lightdm-webkit/themes/backup"

# Extensive theme collection (40+ themes)
declare -A THEMES=(
    # Official and popular themes
    [webkit]="https://github.com/antergos/lightdm-webkit-theme-webkit/archive/master.tar.gz"
    [antergos]="https://github.com/antergos/lightdm-webkit-theme-archlinux/archive/master.tar.gz"
    [litarvan]="https://github.com/Litarvan/lightdm-webkit-theme-litarvan/archive/master.tar.gz"
    [glorious]="https://github.com/manilarome/lightdm-webkit-theme-glorious/archive/master.tar.gz"
    
    # Minimal themes
    [minimal]="https://github.com/prikhi/lightdm-webkit-minimal/archive/master.tar.gz"
    [slick]="https://github.com/agiz/lightdm-webkit-slick/archive/master.tar.gz"
    [plain]="https://github.com/davvil/lightdm-webkit-plain/archive/master.tar.gz"
    
    # Elegant themes
    [elegance]="https://github.com/gabrielhuang/lightdm-webkit-theme-elegance/archive/master.tar.gz"
    [aether]="https://github.com/NoiSek/Aether/archive/master.tar.gz"
    [material]="https://github.com/artur9010/lightdm-webkit-material/archive/master.tar.gz"
    
    # Dark themes
    [dark]="https://github.com/davvil/lightdm-webkit-dark/archive/master.tar.gz"
    [void]="https://github.com/iamverysimp1e/lightdm-webkit-void-theme/archive/master.tar.gz"
    [black]="https://github.com/addy-dclxvi/lightdm-webkit-black/archive/master.tar.gz"
    
    # Animated themes
    [sequoia]="https://github.com/daniruiz/sequoia-webkit-theme/archive/master.tar.gz"
    [particle]="https://github.com/davvil/lightdm-webkit-particle/archive/master.tar.gz"
    [solar]="https://github.com/polkaned/lightdm-webkit-solar/archive/master.tar.gz"
    
    # Distro-specific themes
    [arch]="https://github.com/antergos/lightdm-webkit-theme-archlinux/archive/master.tar.gz"
    [ubuntu]="https://github.com/UbuntuBudgie/lightdm-webkit-ubuntu-budgie/archive/master.tar.gz"
    [manjaro]="https://github.com/manjaro/lightdm-webkit-theme-manjaro/archive/master.tar.gz"
    [endeavouros]="https://github.com/endeavouros-team/lightdm-webkit-theme-endeavouros/archive/master.tar.gz"
    
    # Additional themes
    [retro]="https://github.com/Keyitdev/lightdm-webkit-retro/archive/master.tar.gz"
    [neon]="https://github.com/Khertan/lightdm-webkit-neon/archive/master.tar.gz"
    [flat]="https://github.com/RaphaelRochet/lightdm-webkit-flat/archive/master.tar.gz"
    [future]="https://github.com/RaphaelRochet/lightdm-webkit-future/archive/master.tar.gz"
    [glass]="https://github.com/addy-dclxvi/lightdm-webkit-glass/archive/master.tar.gz"
    [nord]="https://github.com/Khertan/lightdm-webkit-nord/archive/master.tar.gz"
    [gruvbox]="https://github.com/prikhi/lightdm-webkit-gruvbox/archive/master.tar.gz"
    [dracula]="https://github.com/dracula/lightdm-webkit/archive/master.tar.gz"
    [tokyonight]="https://github.com/rototrash/tokyonight-lightdm/archive/master.tar.gz"
    [catppuccin]="https://github.com/catppuccin/lightdm/archive/main.tar.gz"
    [onedark]="https://github.com/daniruiz/lightdm-webkit-theme-onedark/archive/master.tar.gz"
    [monterey]="https://github.com/rose-pine/lightdm-webkit-theme/archive/main.tar.gz"
    [cyberpunk]="https://github.com/RaphaelRochet/lightdm-webkit-cyberpunk/archive/master.tar.gz"
    [hacktheplanet]="https://github.com/addy-dclxvi/lightdm-webkit-hacktheplanet/archive/master.tar.gz"
    [matrix]="https://github.com/addy-dclxvi/lightdm-webkit-matrix/archive/master.tar.gz"
    [synthwave]="https://github.com/rototrash/synthwave-lightdm/archive/master.tar.gz"
    [vaporwave]="https://github.com/rototrash/vaporwave-lightdm/archive/master.tar.gz"
    [80s]="https://github.com/addy-dclxvi/lightdm-webkit-80s/archive/master.tar.gz"
    [90s]="https://github.com/addy-dclxvi/lightdm-webkit-90s/archive/master.tar.gz"
    [y2k]="https://github.com/addy-dclxvi/lightdm-webkit-y2k/archive/master.tar.gz"
)

# Check dependencies
check_deps() {
    local missing=()
    command -v lightdm >/dev/null || missing+=("lightdm")
    command -v lightdm-webkit2-greeter >/dev/null || missing+=("lightdm-webkit2-greeter")
    command -v curl >/dev/null || missing+=("curl")
    command -v tar >/dev/null || missing+=("tar")
    command -v sudo >/dev/null || missing+=("sudo")
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "❌ Missing dependencies: ${missing[*]}"
        echo "   Install with:"
        echo "   Debian/Ubuntu: sudo apt install ${missing[*]}"
        echo "   Arch: sudo pacman -S ${missing[*]}"
        echo "   Fedora: sudo dnf install ${missing[*]}"
        exit 1
    fi
}

# Create backup
create_backup() {
    echo "🔒 Creating backup of current theme..."
    sudo mkdir -p "$BACKUP_DIR"
    if [[ -f "$CONF_FILE" ]]; then
        sudo cp "$CONF_FILE" "$BACKUP_DIR/lightdm-webkit2-greeter.conf.bak"
    fi
}

# Restore backup
restore_backup() {
    if [[ -f "$BACKUP_DIR/lightdm-webkit2-greeter.conf.bak" ]]; then
        echo "🔄 Restoring backup..."
        sudo cp "$BACKUP_DIR/lightdm-webkit2-greeter.conf.bak" "$CONF_FILE"
    fi
}

# Install theme
install_theme() {
    local name="$1" url="$2"
    local tmp_dir=$(mktemp -d)
    
    echo "📦 Downloading $name..."
    if ! curl -sL "$url" | tar xz -C "$tmp_dir" --strip-components=1; then
        echo "❌ Failed to download/extract $name"
        rm -rf "$tmp_dir"
        return 1
    fi
    
    # Find the actual theme directory (some archives have nested structure)
    local theme_dir=$(find "$tmp_dir" -type f -name "index.html" -exec dirname {} \; | head -1)
    [[ -z "$theme_dir" ]] && theme_dir="$tmp_dir"
    
    echo "⚙️ Installing $name..."
    sudo mkdir -p "$THEME_BASE/$name"
    sudo cp -r "$theme_dir"/* "$THEME_BASE/$name/"
    
    # Cleanup
    rm -rf "$tmp_dir"
    
    # Set as current theme
    echo "💡 Setting $name as current theme..."
    sudo sed -i "s/^webkit_theme\s*=.*/webkit_theme = $name/" "$CONF_FILE" 2>/dev/null || \
        echo -e "[greeter]\nwebkit_theme = $name" | sudo tee "$CONF_FILE" >/dev/null
    
    echo "✅ $name installed successfully!"
}

# List installed themes
list_themes() {
    echo "🎨 Available Themes:"
    local i=1
    for theme in "$THEME_BASE"/*; do
        if [[ -d "$theme" ]]; then
            echo "  $i. $(basename "$theme")"
            ((i++))
        fi
    done
}

# Main menu
main_menu() {
    while true; do
        echo -e "\n🌈 XFCE LightDM Theme Manager"
        echo "1. Install new theme"
        echo "2. List installed themes"
        echo "3. Restore backup"
        echo "4. Exit"
        
        read -p "❯ Select option (1-4): " choice
        
        case $choice in
            1)
                echo -e "\n📚 Available Themes (${#THEMES[@]} options):"
                local i=1
                for theme in "${!THEMES[@]}"; do
                    echo "  $i. $theme"
                    ((i++))
                done
                
                read -p "❯ Select theme by number or name: " selection
                
                if [[ "$selection" =~ ^[0-9]+$ ]] && (( selection >= 1 && selection <= ${#THEMES[@]} )); then
                    local keys=("${!THEMES[@]}")
                    local selected="${keys[$((selection-1))]}"
                    install_theme "$selected" "${THEMES[$selected]}"
                elif [[ -n "${THEMES[$selection]}" ]]; then
                    install_theme "$selection" "${THEMES[$selection]}"
                else
                    echo "❌ Invalid selection"
                fi
                ;;
            2)
                list_themes
                ;;
            3)
                restore_backup
                ;;
            4)
                echo "👋 Goodbye!"
                exit 0
                ;;
            *)
                echo "❌ Invalid option"
                ;;
        esac
    done
}

# Main execution
check_deps
create_backup
main_menu
