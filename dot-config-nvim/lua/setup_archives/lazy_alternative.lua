local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
  -- Core settings (loaded immediately)
  {
    "folke/neodev.nvim", -- Optional: Enhances Lua development in Neovim
    config = function()
      require("neodev").setup()
      vim.opt.number = true
      vim.opt.signcolumn = "yes"
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.termguicolors = true
      vim.opt.timeoutlen = 300
      vim.opt.updatetime = 250
      vim.g.mapleader = " "

      -- Basic keymaps
      vim.keymap.set("n", "<C-s>", "<cmd>w<cr>")
      vim.keymap.set("i", "jk", "<esc>")
      vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")
      vim.keymap.set("n", "<leader>bd", "<cmd>bd<cr>")
      vim.keymap.set("n", "<leader>bn", "<cmd>bn<cr>")
      vim.keymap.set("n", "<leader>bp", "<cmd>bp<cr>")
      vim.keymap.set("n", "<C-h>", "<C-w>h")
      vim.keymap.set("n", "<C-j>", "<C-w>j")
      vim.keymap.set("n", "<C-k>", "<C-w>k")
      vim.keymap.set("n", "<C-l>", "<C-w>l")
    end,
  },

  -- Colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },

  -- File manager
  {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup()
    end,
  },

  -- Fuzzy finder
  {
    "ibhagwan/fzf-lua",
    lazy = true,
    keys = { "<leader>ff", "<leader>fg", "<leader>fb" },
    config = function()
      require("fzf-lua").setup()
      vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>")
      vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>")
      vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>")
    end,
  },

  -- Mini.nvim ecosystem
  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.statusline").setup()
      require("mini.pairs").setup()
      require("mini.surround").setup()
      require("mini.icons").setup()
      require("mini.sessions").setup()
      require("mini.comment").setup()
      require("mini.indentscope").setup()
      require("mini.jump").setup()
      require("mini.tabline").setup()
      require("mini.splitjoin").setup()
      require("mini.hipatterns").setup()
      vim.keymap.set("n", "<leader>ss", "<cmd>lua MiniSessions.write()<cr>")
      vim.keymap.set("n", "<leader>sr", "<cmd>lua MiniSessions.select()<cr>")
    end,
  },

  -- LSP
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",               -- Lua
          "clangd",               -- C
          "bashls",               -- Bash
          "kotlin_language_server" -- Kotlin
        },
      })
      local lspconfig = require("lspconfig")
      -- require("mason-lspconfig").setup_handlers({
      --   function(server_name)
      --     lspconfig[server_name].setup({
      --       capabilities = require("blink.cmp").get_lsp_capabilities(),
      --     })
      --   end,
      -- })
      vim.keymap.set("n", "gd", vim.lsp.buf.definition)
      vim.keymap.set("n", "K", vim.lsp.buf.hover)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
    end,
  },
  { "neovim/nvim-lspconfig" },

  -- Completion
  {
    "saghen/blink.cmp",
    lazy = true,
    event = "InsertEnter",
    config = function()
      require("blink.cmp").setup({
        keymap = { preset = "default" },
        nerd_font_variant = "mono",
        sources = {
          providers = { "lsp", "path", "snippets", "buffer" },
        },
      })
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "vimdoc", "javascript", "typescript", "python" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Git integration
  {
    "NeogitOrg/neogit",
    dependencies = { "sindrets/diffview.nvim" },
    lazy = true,
    keys = { "<leader>g" },
    config = function()
      require("neogit").setup()
      vim.keymap.set("n", "<leader>g", "<cmd>Neogit<cr>")
    end,
  },
  { "sindrets/diffview.nvim" },

  -- Formatting
  {
    "mhartington/formatter.nvim",
    lazy = true,
    keys = { "<leader>f" },
    config = function()
      require("formatter").setup({
        logging = true,
        log_level = vim.log.levels.WARN,
        filetype = {
          lua = { require("formatter.filetypes.lua").stylua },
          javascript = { require("formatter.filetypes.javascript").prettier },
          typescript = { require("formatter.filetypes.typescript").prettier },
          python = { require("formatter.filetypes.python").black },
        },
      })
      vim.keymap.set("n", "<leader>f", "<cmd>Format<cr>")
    end,
  },
})



vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>")
