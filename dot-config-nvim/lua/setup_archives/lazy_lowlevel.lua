-- ~/.config/nvim/init.lua

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.runtimepath:prepend(lazypath)

-- Leader key setup
vim.g.mapleader = ' '

-- Keymapping helper
local map = function(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Autocommand for LSP formatting
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Set up lazy.nvim
require("lazy").setup({
  -- Core dependencies
  { "nvim-lua/plenary.nvim", lazy = true }, -- Dependency for Harpoon

  -- Mini.nvim modules
  { 
    "echasnovski/mini.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require('mini.statusline').setup()
      require('mini.pick').setup()
      require('mini.files').setup()
    end
  },

  -- Syntax highlighting
  { 
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          "lua_ls",               -- Lua
          "clangd",               -- C
          "bashls",               -- Bash
          "kotlin_language_server" -- Kotlin
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },

  -- LSP and completion
  { 
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = { 
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
        }),
      })
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local on_attach = function(_, bufnr)
        local opts = { buffer = bufnr, noremap = true, silent = true }
        map('n', 'gd', vim.lsp.buf.definition, opts)
        map('n', 'K', vim.lsp.buf.hover, opts)
        map('n', '<leader>rn', vim.lsp.buf.rename, opts)
        map('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        map('n', '[d', vim.diagnostic.goto_prev, opts)
        map('n', ']d', vim.diagnostic.goto_next, opts)
      end
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = { "clangd", "rust_analyzer", "gopls", "pyright", "lua_ls", "bashls", "jsonls", "yamlls" },
      })
      local lspconfig = require('lspconfig')
      for _, server in ipairs({
        "clangd", "rust_analyzer", "gopls", "pyright", "lua_ls", "bashls", "jsonls", "yamlls"
      }) do
        lspconfig[server].setup({
          on_attach = on_attach,
          capabilities = capabilities,
        })
      end
    end
  },

  -- File explorer
  { 
    "stevearc/oil.nvim",
    keys = { { "<leader>e", "<cmd>Oil<CR>", desc = "Open Oil file explorer" } },
    config = function()
      require('oil').setup({
        default_file_explorer = true,
        columns = { "icon" },
        view_options = {
          show_hidden = true,
        },
      })
    end
  },

  -- Quick file navigation
  { 
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>a", function() require("harpoon"):list():add() end, desc = "Add file to Harpoon" },
      { "<leader>m", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Open Harpoon menu" },
      { "<leader>1", function() require("harpoon"):list():select(1) end, desc = "Go to Harpoon file 1" },
      { "<leader>2", function() require("harpoon"):list():select(2) end, desc = "Go to Harpoon file 2" },
      { "<leader>3", function() require("harpoon"):list():select(3) end, desc = "Go to Harpoon file 3" },
      { "<leader>4", function() require("harpoon"):list():select(4) end, desc = "Go to Harpoon file 4" },
    },
    config = function()
      require("harpoon"):setup()
    end
  },
})

-- Colorscheme
vim.cmd('colorscheme desert')

-- Keybindings
map("n", "<leader>e", "<cmd>Oil<CR>", { desc = "Open Oil file explorer" })
map("n", "<leader>a", function() require("harpoon"):list():add() end, { desc = "Add file to Harpoon" })
map("n", "<leader>m", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, { desc = "Open Harpoon menu" })
map("n", "<leader>1", function() require("harpoon"):list():select(1) end, { desc = "Go to Harpoon file 1" })
map("n", "<leader>2", function() require("harpoon"):list():select(2) end, { desc = "Go to Harpoon file 2" })
map("n", "<leader>3", function() require("harpoon"):list():select(3) end, { desc = "Go to Harpoon file 3" })
map("n", "<leader>4", function() require("harpoon"):list():select(4) end, { desc = "Go to Harpoon file 4" })


vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})
