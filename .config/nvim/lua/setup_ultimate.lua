
-- UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true

-- Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Performance
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400

-- Clipboard integration
vim.opt.clipboard = "unnamedplus"

-- Split ergonomics
vim.opt.splitbelow = true
vim.opt.splitright = true


-- init.lua
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  require("_shared_other_modules"),
  -- require("_shared_mason_lsp_treesitter"),
  -- require("_shared_mason_lsp_treesitter2"),
  require("_shared_mason_lsp_treesitter3"),


  -----------------------------------------------------------
  -- LSP + Mason
  -----------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local mason = require("mason")
      local mason_lspconfig = require("mason-lspconfig")

      mason.setup()
      mason_lspconfig.setup({
        ensure_installed = { "clangd", "zls", "rust_analyzer" },
      })

      local on_attach = function(_, bufnr)
        local opts = { noremap=true, silent=true, buffer=bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      end

      vim.lsp.config("clangd", { on_attach = on_attach })
      vim.lsp.config("zls", { on_attach = on_attach })
      vim.lsp.config("rust_analyzer", {
        on_attach = on_attach,
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = { command = "clippy" },
          },
        },
      })
      vim.lsp.enable({ "clangd", "zls", "rust_analyzer" })

      vim.diagnostic.config({
        virtual_text = { spacing = 4, prefix = "●" },
        float = { border = "rounded" },
        severity_sort = true,
      })
    end,
  },

  -----------------------------------------------------------
  -- Autocompletion
  -----------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
          { name = "nvim_lua" },
          { name = "luasnip" },
          { name = "nvim_lsp_signature_help" },
        }),
      })
    end,
  },

  -----------------------------------------------------------
  -- Treesitter
  -----------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
},
    config = function()
      -- require("nvim-treesitter.configs").setup({
      --   ensure_installed = { "c", "zig", "rust", "lua" },
      --   highlight = { enable = true },
      --   incremental_selection = {
      --     enable = true,
      --     keymaps = {
      --       init_selection = "gnn",
      --       node_incremental = "grn",
      --       scope_incremental = "grc",
      --       node_decremental = "grm",
      --     },
      --   },
      -- })
    end,
  },


    -- Oil.nvim (alternative to neo-tree/nvim-tree)
    {
        "stevearc/oil.nvim",
        dependencies = {
            -- "nvim-tree/nvim-web-devicons"

        },
        keys = {
            -- { "<leader><leader>", "<cmd>Oil<cr>", desc = "Open file explorer" },
            { "<leader>e", "<cmd>Oil<cr>", desc = "Open file explorer" },
            { "-",         "<cmd>Oil<cr>", desc = "Open parent directory" },
        },
        config = function()
            require("oil").setup({
                columns = { "icon" },
                view_options = { show_hidden = true },
                float = { padding = 10 },
                keymaps = {
                    ["<C-h>"] = false,
                    ["<C-l>"] = false,
                    ["<C-s>"] = "actions.select_split",
                    ["<C-v>"] = "actions.select_vsplit",
                },
            })
        end,
    },


  -----------------------------------------------------------
  -- Essentials
  -----------------------------------------------------------
  { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
  -- { "nvim-tree/nvim-tree.lua" }, -- file explorer
  { "nvim-lualine/lualine.nvim" }, -- statusline
  { "lewis6991/gitsigns.nvim" }, -- git signs in gutter
  { "numToStr/Comment.nvim", config = true }, -- easy commenting
  { "mhartington/formatter.nvim" }, -- formatting
  { "folke/which-key.nvim", config = true }, -- keymap hints
  { "akinsho/toggleterm.nvim", config = true }, -- integrated terminal
})


-- Auto-reload config on save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = vim.fn.stdpath("config") .. "/**/*.lua",
  command = "source <afile>",
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank({ higroup="IncSearch", timeout=200 }) end,
})

-- Format on save for system languages
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.c", "*.cpp", "*.h", "*.rs", "*.zig" },
  callback = function() vim.lsp.buf.format({ async = false }) end,
})

-- Terminal ergonomics
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})


-- Leader key
vim.g.mapleader = " "

-- Quick save/quit
vim.keymap.set("n", "<leader>w", ":w<CR>", { silent=true })
vim.keymap.set("n", "<leader>q", ":q<CR>", { silent=true })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Resize splits
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>")
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>")
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>")
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>")

-- Telescope shortcuts
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>")
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>")
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>")
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>")

-- Nvim-tree toggle
-- vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

-- Toggle terminal
vim.keymap.set("n", "<leader>t", ":ToggleTerm<CR>")
vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>")


