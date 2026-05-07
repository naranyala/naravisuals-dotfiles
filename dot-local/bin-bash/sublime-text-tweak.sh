#!/usr/bin/env bash
set -euo pipefail

# Define paths
SUBLIME_CONFIG="$HOME/.config/sublime-text"
PACKAGES_DIR="$SUBLIME_CONFIG/Installed Packages"
USER_DIR="$SUBLIME_CONFIG/Packages/User"
BACKUP_DIR="$SUBLIME_CONFIG/Backup-$(date +%F_%H-%M-%S)"

# Check if Sublime Text is installed
if ! command -v subl &> /dev/null; then
    echo "❌ Sublime Text not found. Please install it first."
    exit 1
fi

echo "🚀 Setting up Sublime Text..."

# Backup existing configuration
if [[ -d "$SUBLIME_CONFIG" ]]; then
    echo "🔄 Backing up existing configuration..."
    mkdir -p "$BACKUP_DIR"
    cp -r "$SUBLIME_CONFIG"/* "$BACKUP_DIR" 2>/dev/null || true
fi

# Create directories
mkdir -p "$PACKAGES_DIR" "$USER_DIR"

# Install Package Control
echo "📦 Installing Package Control..."
if [[ ! -f "$PACKAGES_DIR/Package Control.sublime-package" ]]; then
    wget -q --tries=3 --timeout=10 \
        "https://packagecontrol.io/Package%20Control.sublime-package" \
        -O "$PACKAGES_DIR/Package Control.sublime-package" || {
        echo "❌ Failed to download Package Control"
        exit 1
    }
fi

# Configure packages
echo "🎨 Installing essential packages..."
cat > "$USER_DIR/Package Control.sublime-settings" <<EOF
{
    "bootstrapped": true,
    "in_process_packages": [],
    "installed_packages": [
        "Dracula Color Scheme",
        "A File Icon",
        "Terminus",
        "Sidebar Enhancements",
        "GitGutter",
        "BracketHighlighter",
        "AutoFileName",
        "Emmet",
        "LSP",
        "LSP-pyright",
        "LSP-typescript",
        "SublimeLinter",
        "SublimeLinter-pylint",
        "SublimeLinter-eslint",
        "MarkdownPreview"
    ]
}
EOF

# Verify package installation
echo "🔍 Verifying Dracula Color Scheme installation..."
if [[ ! -d "$SUBLIME_CONFIG/Packages/Dracula Color Scheme" ]]; then
    echo "⚠️ Dracula Color Scheme not found. It will be installed on Sublime Text restart."
fi

# Main preferences with dark Adaptive theme and Dracula colorscheme
echo "⚙️ Configuring preferences..."
cat > "$USER_DIR/Preferences.sublime-settings" <<EOF
{
    "theme": "Adaptive.sublime-theme",
    "color_scheme": "Dracula.sublime-color-scheme",
    "fallback_color_scheme": "Monokai.sublime-color-scheme",

    "font_face": "JetBrains Mono",
    "font_size": 14,
    "font_options": ["gray_antialias", "subpixel_antialias"],

    "line_padding_top": 4,
    "line_padding_bottom": 4,

    "highlight_line": true,
    "highlight_modified_tabs": true,
    "line_numbers": true,
    "rulers": [80, 120],
    "word_wrap": "auto",
    "wrap_width": 120,

    "tab_size": 4,
    "translate_tabs_to_spaces": true,
    "trim_trailing_white_space_on_save": "all",
    "ensure_newline_at_eof_on_save": true,

    "show_tab_close_buttons": true,
    "show_definitions": true,
    "preview_on_click": false,
    "tree_animation_enabled": false,
    "animation_enabled": false,
    "save_on_focus_lost": true,

    "ignored_packages": ["Vintage"],
    "index_files": true,
    "show_encoding": true,
    "show_line_endings": true,
    "auto_complete_commit_on_tab": true,
    "copy_with_empty_selection": false,
    "dark_theme": true
}
EOF

# Keybindings
echo "⌨️ Setting up keybindings..."
cat > "$USER_DIR/Default (Linux).sublime-keymap" <<EOF
[
    {
        "keys": ["ctrl+shift+t"],
        "command": "terminus_open",
        "args": {
            "cmd": "bash",
            "cwd": "\${file_path:\${folder}}",
            "panel_name": "Terminal",
            "auto_close": false
        }
    },
    {
        "keys": ["ctrl+shift+r"],
        "command": "show_overlay",
        "args": {"overlay": "goto", "show_files": true}
    },
    {
        "keys": ["ctrl+shift+b"],
        "command": "build",
        "args": {"select": true}
    },
    {
        "keys": ["ctrl+alt+f"],
        "command": "lsp_format_document"
    },
    {
        "keys": ["ctrl+."],
        "command": "lsp_code_actions"
    }
]
EOF

# Language-specific settings
echo "📝 Configuring language settings..."
cat > "$USER_DIR/Python.sublime-settings" <<EOF
{
    "tab_size": 4,
    "rulers": [79, 120],
    "extensions": ["py"],
    "lsp_format_on_save": true
}
EOF

cat > "$USER_DIR/JavaScript.sublime-settings" <<EOF
{
    "tab_size": 2,
    "rulers": [80, 120],
    "extensions": ["js", "jsx", "ts", "tsx"],
    "lsp_format_on_save": true
}
EOF

cat > "$USER_DIR/Markdown.sublime-settings" <<EOF
{
    "tab_size": 2,
    "rulers": [80],
    "extensions": ["md", "markdown"],
    "enable_table_editor": true,
    "spell_check": true
}
EOF

# LSP settings
echo "🛠️ Configuring LSP settings..."
cat > "$USER_DIR/LSP-pyright.sublime-settings" <<EOF
{
    "enabled": true,
    "command": ["pyright", "--stdio"],
    "scopes": ["source.python"],
    "languageId": "python"
}
EOF

cat > "$USER_DIR/LSP-typescript.sublime-settings" <<EOF
{
    "enabled": true,
    "command": ["typescript-language-server", "--stdio"],
    "scopes": ["source.js", "source.jsx", "source.ts", "source.tsx"],
    "languageId": "javascript"
}
EOF

# SublimeLinter settings
echo "🔍 Configuring SublimeLinter..."
cat > "$USER_DIR/SublimeLinter.sublime-settings" <<EOF
{
    "linters": {
        "pylint": {
            "executable": "pylint",
            "working_directory": "\${folder}",
            "filter_errors": "E,F"
        },
        "eslint": {
            "executable": "eslint",
            "working_directory": "\${folder}"
        }
    }
}
EOF

# Delay to allow Package Control to initialize
echo "⏳ Waiting for Package Control to initialize..."
sleep 5

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Restart Sublime Text to apply dark theme and package changes"
echo "2. Install required dependencies:"
echo "   - JetBrains Mono font"
echo "   - Node.js (for LSP-typescript and eslint)"
echo "   - Python (for LSP-pyright and pylint)"
echo "   - Run: npm install -g typescript-language-server eslint"
echo "   - Run: pip install pyright pylint"
echo "3. Verify Dracula Color Scheme is installed in Sublime Text"
echo ""
echo "New features:"
echo "• Dark Adaptive theme with Dracula colorscheme for code blocks (fallback to Monokai)"
echo "• LSP support for Python and JavaScript/TypeScript"
echo "• Linting with SublimeLinter (pylint, eslint)"
echo "• Markdown editing improvements"
echo "• Improved keybindings (formatting, code actions)"
echo "• Better file indexing and autocomplete"
echo "• Backup of existing configuration"
echo ""
if [[ -d "$BACKUP_DIR" ]]; then
    echo "📜 Previous configuration backed up to: $BACKUP_DIR"
fi
