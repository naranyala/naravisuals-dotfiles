-- ~/.config/nvim/init.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then  -- vim.loop → vim.uv in Neovim 0.10+
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {

    require("./_shared/missing_native_apis"),
    require("./_shared/tpope_goodies"),
    require("./_shared/lualine_and_theme"),

    -- Core UI
    { "folke/which-key.nvim", event = "VeryLazy", opts = {} },
    { "rcarriga/nvim-notify", opts = { stages = "fade" } },

    -- Completion (works without LSP too)
    {
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets",
      },
      config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        require("luasnip.loaders.from_vscode").lazy_load()

        cmp.setup({
          snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
          mapping = cmp.mapping.preset.insert({
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" }),
          }),
          sources = {
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "buffer", keyword_length = 3 },
          },
        })
      end,
    },

    -- LSP + Mason (uncomment when you want it back)
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
      },
      config = function()
        require("mason").setup()
        local lspconfig = require("lspconfig")
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        lspconfig.clangd.setup { capabilities = capabilities }
        lspconfig.rust_analyzer.setup {
          capabilities = capabilities,
          settings = {
            ["rust-analyzer"] = {
              check = { command = "clippy" },
              cargo = { allFeatures = true },
              procMacro = { enable = true },
            },
          },
        }
      end,
    },

    -- Rust-tools (gives you <leader>rr, <leader>re, <leader>rd, etc.)
    {
      "simrat39/rust-tools.nvim",
      ft = { "rust" },
      dependencies = { "neovim/nvim-lspconfig" },
      opts = {
        server = { standalone = false }, -- let lspconfig handle it
      },
    },

    -- Linting (clippy + clang-tidy)
    {
      "mfussenegger/nvim-lint",
      event = "BufWritePost",
      config = function()
        require("lint").linters_by_ft = {
          c = { "clang_tidy" },
          cpp = { "clang_tidy" },
          rust = { "clippy" },
        }
        vim.api.nvim_create_autocmd("BufWritePost", {
          callback = function()
            require("lint").try_lint()
          end,
        })
      end,
    },

    -- Telescope
    {
      "nvim-telescope/telescope.nvim",
      branch = "0.1.x",
      dependencies = { "nvim-lua/plenary.nvim" },
      cmd = "Telescope",
      keys = {
        { "<leader>ff", "<cmd>Telescope find_files<cr>" },
        { "<leader>fg", "<cmd>Telescope live_grep<cr>" },
        { "<leader>fb", "<cmd>Telescope buffers<cr>" },
        { "<leader>fh", "<cmd>Telescope help_tags<cr>" },
      },
    },

    -- Treesitter
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      event = "BufReadPost",
      opts = {
        ensure_installed = { "c", "cpp", "rust", "bash", "make", "cmake" },
        highlight = { enable = true },
        indent = { enable = true },
      },
    },

    -- Git
    { "lewis6991/gitsigns.nvim", event = "BufReadPre", opts = { current_line_blame = true } },

    -- Outline
    { "stevearc/aerial.nvim", opts = {}, keys = { { "<leader>o", "<cmd>AerialToggle<cr>" } } },
  },
  defaults = { lazy = true },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})

-- ===========================================================================
-- General settings & keymaps
-- ===========================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes:2"
vim.opt.updatetime = 100
vim.opt.shortmess:append("I")

local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
end

-- Quickfix navigation
map("n", "[q", ":cprevious<CR>", "Previous quickfix")
map("n", "]q", ":cnext<CR>",     "Next quickfix")

-- Build
map("n", "<leader>mk", "<cmd>make<CR>", "Make")

-- Toggle diagnostics
vim.keymap.set("n", "<leader>td", function()
  if vim.diagnostic.is_disabled() then
    vim.diagnostic.enable()
    vim.notify("Diagnostics enabled")
  else
    vim.diagnostic.disable()
    vim.notify("Diagnostics disabled")
  end
end, { desc = "Toggle diagnostics" })

-- Rust-tools keymaps (only available when rust-tools is loaded)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    vim.keymap.set("n", "<leader>rr", "<cmd>RustRunnables<CR>",      { buffer = true, desc = "Rust runnables" })
    vim.keymap.set("n", "<leader>re", "<cmd>RustExpandMacro<CR>",   { buffer = true, desc = "Expand macro" })
    vim.keymap.set("n", "<leader>rd", "<cmd>RustDebuggables<CR>",   { buffer = true, desc = "Debuggables" })
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,      { buffer = true, desc = "Code actions" })
  end,
})
