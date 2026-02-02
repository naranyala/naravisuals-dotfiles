#!/usr/bin/env bash

# Script to disable icons in LazyVim (smart patch)
# It will create ~/.config/nvim/lua/plugins/no-icons.lua with overrides

NVIM_CONFIG="$HOME/.config/nvim"
PLUGINS_DIR="$NVIM_CONFIG/lua/plugins"
PATCH_FILE="$PLUGINS_DIR/no-icons.lua"

# Ensure plugins directory exists
mkdir -p "$PLUGINS_DIR"

# Write patch file
cat >"$PATCH_FILE" <<'EOF'
-- LazyVim patch: disable icons globally
return {
  -- Disable devicons provider
  {
    "nvim-tree/nvim-web-devicons",
    enabled = false,
  },
  -- Bufferline: no icons
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        show_buffer_icons = false,
        show_buffer_close_icons = false,
        show_tab_indicators = false,
      },
    },
  },
  -- Lualine: no icons
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        icons_enabled = false,
      },
    },
  },
  -- Neo-tree: no icons
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      default_component_configs = {
        icon = {
          enabled = false,
        },
      },
    },
  },
}
EOF

echo "✅ Patch created at $PATCH_FILE"
echo "➡ Restart Neovim to apply changes (icons disabled)."
