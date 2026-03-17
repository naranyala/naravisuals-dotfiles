#!/usr/bin/env bash

set -euo pipefail

CONFIG_DIR="$HOME/.config/nvim/lua/plugins"
PATCH_FILE="$CONFIG_DIR/oil_override.lua"

mkdir -p "$CONFIG_DIR"

cat >"$PATCH_FILE" <<'EOF'
-- Override LazyVim defaults: disable icons, disable neo-tree, enable oil.nvim
return {
  -- Disable icons
  {
    "nvim-tree/nvim-web-devicons",
    enabled = false,
  },

  -- Disable LazyVim’s default explorer (neo-tree)
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },

  -- Add oil.nvim as the new explorer
  {
    "stevearc/oil.nvim",
    opts = {
      default_file_explorer = true,
      view_options = {
        show_hidden = true,
      },
    },
    keys = {
      { "<leader>e", "<CMD>Oil<CR>", desc = "Open Oil file explorer" },
    },
  },
}
EOF

echo "✅ LazyVim override written to: $PATCH_FILE"
echo "Restart Neovim and run :Lazy sync to apply changes."
