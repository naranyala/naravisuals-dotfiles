-- init.lua
-- Optimized Neovim Config for Python/C++ with Lua fixes

local function ensure_lazy()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--branch=stable",
      "https://github.com/folke/lazy.nvim.git",
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)
end

ensure_lazy()

require("lazy").setup({
  -- ==============
  -- Core Essentials
  -- ==============
  { "nvim-lua/plenary.nvim" },
  { "lewis6991/impatient.nvim" },

  -- =============
  -- Editing Power
  -- =============
  { "echasnovski/mini.nvim", version = false, config = function()
    require("mini.ai").setup()
    require("mini.comment").setup()
    require("mini.surround").setup()
    require("mini.pairs").setup()
  end },

  -- ==============
  -- Syntax & Treesitter
  -- ==============
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "python", "cpp", "lua", "vim", "bash" },
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn",
          node_incremental = "grn",
          scope_incremental = "grc",
          node_decremental = "grm",
        },
      },
    })
  end },

  -- ============
  -- Python Tools
  -- ============
  { "astral-sh/ruff-lsp" },
  { "AckslD/swenv.nvim" },

  -- =========
  -- C++ Tools
  -- =========
  { "p00f/clangd_extensions.nvim" },

  -- ================
  -- UI & Navigation
  -- ================
  { "rebelot/kanagawa.nvim" },
  { "stevearc/oil.nvim", opts = {} },
  { "nvim-telescope/telescope.nvim", dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-live-grep-args.nvim",
  }},
  { "folke/which-key.nvim", opts = {} },
  { "luukvbaal/statuscol.nvim", config = true },

  -- ===================
  -- LSP & Completion
  -- ===================
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/nvim-cmp", dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "onsails/lspkind.nvim",
  }},
  { "j-hui/fidget.nvim", tag = "legacy", opts = {} },
})

-- ====================
-- Core Editor Settings
-- ====================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes:1"
vim.opt.clipboard = "unnamedplus"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 100
vim.opt.list = true
vim.opt.listchars = { tab = '▸ ', trail = '·', nbsp = '␣' }

-- Colorscheme
require('kanagawa').setup({
  undercurl = true,
  commentStyle = { italic = true },
  keywordStyle = { italic = true},
  statementStyle = { bold = true },
})
vim.cmd.colorscheme("kanagawa")

-- ==============
-- Key Bindings
-- ==============
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
vim.g.mapleader = " "

-- Navigation
map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "File explorer" })
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep_args<cr>", { desc = "Live grep" })

-- LSP
map("n", "gd", vim.lsp.buf.definition, opts)
map("n", "gr", vim.lsp.buf.references, opts)
map("n", "<leader>rn", vim.lsp.buf.rename, opts)
map("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)

-- ===================
-- Plugin Configurations
-- ===================

-- Telescope
require('telescope').setup({
  defaults = {
    file_ignore_patterns = { "%.git/", "node_modules/", "%.venv/" },
  },
  extensions = {
    live_grep_args = {
      auto_quoting = true,
    }
  },
})
require('telescope').load_extension('live_grep_args')

-- LSP Setup
local lspconfig = require('lspconfig')
local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'path' },
  }),
})

-- Language Servers
lspconfig.lua_ls.setup({
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
      telemetry = { enable = false },
    }
  }
})

lspconfig.ruff.setup({
  init_options = {
    settings = {
      args = { "--ignore=F401", "--line-length=120" }
    }
  }
})

lspconfig.pyright.setup({
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        useLibraryCodeForTypes = true,
      }
    }
  }
})

lspconfig.clangd.setup({
  cmd = { "clangd", "--background-index", "--clang-tidy" },
})

-- =================
-- Auto Commands
-- =================

-- Filetype-specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt.formatoptions:remove("c") -- Don't auto-wrap comments
    vim.opt.formatoptions:remove("r") -- Don't auto-insert comment leader
    vim.opt.formatoptions:remove("o") -- Don't auto-insert comment leader
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    vim.opt_local.colorcolumn = "120"
    map("n", "<leader>pt", "<cmd>lua require('swenv.api').pick_venv()<cr>",
       { buffer = true, desc = "Python venv" })
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end
})

-- Auto-format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.py", "*.lua", "*.cpp", "*.h" },
  callback = function(args)
    if vim.tbl_contains({ "python", "lua", "cpp" }, vim.bo[args.buf].filetype) then
      vim.lsp.buf.format({ async = false })
    end
  end
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end
})
