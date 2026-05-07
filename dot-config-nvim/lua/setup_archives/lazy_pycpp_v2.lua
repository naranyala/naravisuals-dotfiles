-- init.lua
-- Modern Neovim config for Python/C++ with Rust-based tools

local ensure_lazy = function()
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
  -- ======================
  -- Modern Core Enhancements
  -- ======================
  { "nvim-lua/plenary.nvim" }, -- Still the best utilities library

  -- Next-gen editing
  { "echasnovski/mini.nvim", version = false, config = function()
    require("mini.ai").setup() -- Advanced text objects
    require("mini.comment").setup() -- Faster commenting
    require("mini.surround").setup() -- Modern surround
    require("mini.pairs").setup() -- Smarter auto-pairs
    require("mini.move").setup() -- Better line/block moving
  end },


	{
		"ThePrimeagen/harpoon",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("harpoon").setup()
		end,
	},

  { "gbprod/substitute.nvim", config = true }, -- Improved substitution
  { "gbprod/yanky.nvim", config = true }, -- Modern yank management
  { "smjonas/live-command.nvim" }, -- Preview commands like norm

  -- =============
  -- Rust Toolchain
  -- =============
  { "mrcjkb/rustaceanvim", ft = "rust" }, -- Most modern Rust integration
  { "Saecki/crates.nvim", event = "BufRead Cargo.toml", opts = {
    null_ls = { enabled = true },
    src = { cmp = { enabled = true } },
  }},

  -- ============
  -- Python Tools
  -- ============
  { "astral-sh/ruff-lsp" }, -- The fastest Python linter
  { "David-Kunz/jester" }, -- Better Python test integration
  { "AckslD/swenv.nvim" }, -- Python environment switcher

  -- =========
  -- C++ Tools
  -- =========
  { "p00f/clangd_extensions.nvim" }, -- Still the best C++ extension
  { "Badhi/nvim-treesitter-cpp-tools", dependencies = { "nvim-treesitter/nvim-treesitter" }},

  -- ==================
  -- UI & Navigation
  -- ==================
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 }, -- Modern colorscheme
  { "stevearc/oil.nvim", opts = {} }, -- File explorer as buffer
  { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = {
    "nvim-lua/plenary.nvim",
    "debugloop/telescope-undo.nvim",
    "nvim-telescope/telescope-live-grep-args.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  }},
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },
  { "luukvbaal/statuscol.nvim", config = true }, -- Modern status column
  { "Bekaboo/dropbar.nvim" }, -- Modern breadcrumbs
  { "utilyre/barbecue.nvim", dependencies = {
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons",
  }, config = true },

  -- =====================
  -- LSP & Completion
  -- =====================
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "VonHeikemen/lsp-zero.nvim", branch = "v3.x" }, -- Modern LSP setup
  { "hrsh7th/nvim-cmp", dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "saadparwaiz1/cmp_luasnip",
    "L3MON4D3/LuaSnip",
    "rafamadriz/friendly-snippets",
    "onsails/lspkind.nvim",
  }},
  { "j-hui/fidget.nvim", tag = "legacy", opts = {} },
  { "lvimuser/lsp-inlayhints.nvim", opts = {} }, -- Modern inlay hints

  -- ===========
  -- Debugging
  -- ===========
  { "mfussenegger/nvim-dap" },
  -- { "rcarriga/nvim-dap-ui" },
  { "theHamsta/nvim-dap-virtual-text" },
  { "LiadOz/nvim-dap-repl-highlights" },
  { "ofirgall/open.nvim" }, -- Modern test runner integration

  -- =================
  -- Productivity
  -- =================
  { "chrisgrieser/nvim-early-retirement" }, -- Auto-close unused buffers
  { "chrisgrieser/nvim-recorder" }, -- Better macro management
  { "axkirillov/hbac.nvim", opts = {} }, -- Smart buffer closing
  { "toppair/reach.nvim", opts = {} }, -- Modern buffer/jump navigation
  { "Wansmer/treesj", opts = { use_default_keymaps = false }}, -- Smart split/join
  { "ziontee113/syntax-tree-surfer" }, -- AST-based navigation
})

-- =====================
-- Modern Core Settings
-- =====================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes:1"
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 100
vim.opt.timeoutlen = 300
vim.opt.inccommand = "split"
vim.opt.list = true
vim.opt.listchars = { tab = '▸ ', trail = '·', nbsp = '␣' }
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
vim.opt.winbar = "%=%m %f"

-- Modern colorscheme
require("catppuccin").setup({
  flavour = "mocha",
  integrations = {
    barbecue = { bold_basename = true, dim_context = false },
    dropbar = { enabled = true, color_mode = true },
    mason = true,
    which_key = true,
  }
})
vim.cmd.colorscheme("catppuccin")

-- ==============
-- Key Bindings
-- ==============
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Plugin keymaps
map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "File explorer" })


map("n", "<leader>m", '<cmd>lua require("harpoon.mark").add_file()<cr>', { desc = "Harpoon Mark" })
map("n", "<leader><leader>", '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>', { desc = "Show Harpoon" })
map("n", "1", '<cmd>lua require("harpoon.ui").nav_file(1)<cr>', { desc = "Move #1" })
map("n", "2", '<cmd>lua require("harpoon.ui").nav_file(2)<cr>', { desc = "Move #2" })
map("n", "3", '<cmd>lua require("harpoon.ui").nav_file(3)<cr>', { desc = "Move #3" })
map("n", "4", '<cmd>lua require("harpoon.ui").nav_file(4)<cr>', { desc = "Move #4" })

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep_args<cr>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
map("n", "<leader>fu", "<cmd>Telescope undo<cr>", { desc = "Undo tree" })
map("n", "<leader>fp", function()
  require("telescope").extensions.projects.projects()
end, { desc = "Find projects" })

-- LSP keymaps
map("n", "gD", vim.lsp.buf.declaration, opts)
map("n", "gd", "<cmd>Telescope lsp_definitions<cr>", opts)
map("n", "K", vim.lsp.buf.hover, opts)
map("n", "gi", "<cmd>Telescope lsp_implementations<cr>", opts)
map("n", "<C-k>", vim.lsp.buf.signature_help, opts)
map("n", "<leader>rn", vim.lsp.buf.rename, opts)
map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
map("n", "gr", "<cmd>Telescope lsp_references<cr>", opts)
map("n", "<leader>f", function() vim.lsp.buf.format { async = true } end, opts)

-- Debugging keymaps
map("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", opts)
map("n", "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", opts)
map("n", "<leader>do", "<cmd>lua require'dap'.step_over()<cr>", opts)
map("n", "<leader>di", "<cmd>lua require'dap'.step_into()<cr>", opts)
map("n", "<leader>du", "<cmd>lua require'dap'.step_out()<cr>", opts)

-- =================
-- Modern Plugin Configs
-- =================

-- LSP Zero (Modern LSP setup)
local lsp_zero = require('lsp-zero').preset({})
lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

lsp_zero.setup()

-- Mason (Modern LSP/DAP installer)
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "ruff", "pyright" },
  handlers = {
    lsp_zero.default_setup,
  },
})

-- Modern completion
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'buffer' },
  },
  mapping = cmp.mapping.preset.insert({
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    ['<Tab>'] = cmp_action.luasnip_supertab(),
    ['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
  }),
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
})

-- Modern LSP servers
require('lspconfig').ruff.setup({
  init_options = {
    settings = {
      args = {
        "--select=E,W,F",
        "--ignore=F401",
        "--line-length=120",
      }
    }
  }
})

require('lspconfig').pyright.setup({
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      }
    }
  }
})



-- Modern auto-commands
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.colorcolumn = "120"
    -- vim.opt_local.foldmethod = "indent"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cpp", "c", "h", "hpp" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    -- vim.opt_local.foldmethod = "syntax"
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.py", "*.cpp", "*.h", "*.c", "*.hpp" },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
