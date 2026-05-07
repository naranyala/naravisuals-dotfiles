-- ~/.config/nvim/init.lua

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic settings
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 300
vim.opt.completeopt = { "menuone", "noselect" }

-- Plugin configuration
require("lazy").setup({
  -- Colorscheme
  {
    "rebelot/kanagawa.nvim",
    config = function()
      vim.cmd.colorscheme("kanagawa-wave")
    end
  },

  -- Status line
  {
    "freddiehaddad/feline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("feline").setup()
    end
  },

  -- File explorer
  {
    "ms-jpq/chadtree",
    branch = "chad",
    build = "python3 -m chadtree deps",
    config = function()
      vim.keymap.set("n", "<leader>e", "<cmd>CHADopen<cr>")
    end
  },

  -- Fuzzy finder
  {
    "vijaymarupudi/nvim-fzf",
    dependencies = { "vijaymarupudi/nvim-fzf-commands" },
    config = function()
      vim.keymap.set("n", "<leader>ff", "<cmd>FzfFiles<cr>")
      vim.keymap.set("n", "<leader>fg", "<cmd>FzfRg<cr>")
      vim.keymap.set("n", "<leader>fb", "<cmd>FzfBuffers<cr>")
    end
  },

  -- Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua_ls",               -- Lua
          "clangd",               -- C
          "bashls",               -- Bash
          "kotlin_language_server" -- Kotlin
        },
        automatic_installation = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },

  -- LSP setup
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v2.x",
    dependencies = {
      -- LSP Support
      { "neovim/nvim-lspconfig" },
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },

      -- Autocompletion
      { "hrsh7th/nvim-cmp" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "saadparwaiz1/cmp_luasnip" },
      
      -- Snippets
      { "L3MON4D3/LuaSnip" },
    },
    config = function()
      local lsp = require("lsp-zero").preset({
        name = "recommended",
        set_lsp_keymaps = true,
        manage_nvim_cmp = true,
      })

      lsp.ensure_installed({
        "lua_ls",
        "pyright",
        "tsserver",
        "gopls"
      })

      lsp.on_attach(function(client, bufnr)
        local opts = { buffer = bufnr, remap = false }
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
      end)

      lsp.setup()
    end
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end
  },

  -- Terminal integration
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup()
      vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<cr>")
    end
  },

  -- Session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    config = function()
      require("persistence").setup()
      vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end)
      vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end)
    end
  },

  -- Debugging
  {
    "mfussenegger/nvim-dap",
    config = function()
      vim.keymap.set("n", "<leader>dc", function() require("dap").continue() end)
      vim.keymap.set("n", "<leader>ds", function() require("dap").step_over() end)
      vim.keymap.set("n", "<leader>di", function() require("dap").step_into() end)
      vim.keymap.set("n", "<leader>do", function() require("dap").step_out() end)
      vim.keymap.set("n", "<leader>db", function() require("dap").toggle_breakpoint() end)
    end
  },

  -- Quick navigation
  {
    "ggandor/leap.nvim",
    config = function()
      require("leap").add_default_mappings()
    end
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    ft = "markdown",
    config = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end
  }
})

-- Key mappings
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")
vim.keymap.set("n", "<leader>x", "<cmd>x<cr>")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Autocommands
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = "%s/\\s\\+$//e",
})


vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})
