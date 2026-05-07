
-- Disable all tabline-related features and plugins
local M = {}

function M.disable_tabline()
  -- 1. Disable Neovim's built-in tabline
  vim.opt.showtabline = 0

  -- 2. Disable bufferline.nvim if loaded
  pcall(function()
    require("bufferline").setup({ options = { mode = "tabs" } })
    vim.opt.showtabline = 0
  end)

  -- 3. Disable lualine.nvim tabline components if loaded
  pcall(function()
    require("lualine").setup({
      options = {
        sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
        },
      },
    })
  end)

  -- 4. Disable tabline.nvim if loaded
  pcall(function()
    require("tabline").setup({ enable = false })
  end)

  -- 5. Disable custom tabline (if set)
  vim.opt.tabline = ""

  -- 6. Print confirmation
  print("Tabline disabled for all plugins and built-in features.")
end

-- Auto-disable tabline when this file is loaded
M.disable_tabline()

return M
