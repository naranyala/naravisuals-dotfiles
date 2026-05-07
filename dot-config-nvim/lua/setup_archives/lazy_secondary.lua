local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
  -- Core settings and mini.nvim essentials
  {
    "folke/neodev.nvim",
    config = function()
      require("neodev").setup()
      require("mini.basics").setup()
      require("mini.statusline").setup()
      require("mini.comment").setup()
      require("mini.pairs").setup()
      require("mini.surround").setup()

      -- Basic settings
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
      vim.opt.cursorline = true
      vim.opt.signcolumn = "yes"
      vim.opt.updatetime = 300
      vim.opt.timeoutlen = 500
      vim.opt.clipboard = "unnamedplus"
      vim.opt.mouse = "a"
      vim.opt.scrolloff = 8
      vim.opt.sidescrolloff = 8
      vim.opt.undofile = true
      vim.opt.undolevels = 10000
      vim.opt.backup = false
      vim.opt.writebackup = false
      vim.opt.swapfile = false
      vim.opt.splitright = true
      vim.opt.splitbelow = true
      vim.opt.pumheight = 10
      vim.opt.conceallevel = 0
      vim.opt.fileencoding = "utf-8"
      vim.opt.cmdheight = 1
      vim.opt.completeopt = { "menuone", "noselect" }
      vim.opt.laststatus = 3
      vim.opt.showtabline = 2
      vim.g.mapleader = " "

      -- Autocommands
      local augroup = vim.api.nvim_create_augroup
      local autocmd = vim.api.nvim_create_autocmd

      augroup("YankHighlight", { clear = true })
      autocmd("TextYankPost", {
        group = "YankHighlight",
        callback = function()
          vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
        end,
      })

      augroup("TrimWhitespace", { clear = true })
      autocmd("BufWritePre", {
        group = "TrimWhitespace",
        pattern = "*",
        command = "%s/\\s\\+$//e",
      })

      augroup("ResizeSplits", { clear = true })
      autocmd("VimResized", {
        group = "ResizeSplits",
        callback = function()
          vim.cmd("tabdo wincmd =")
        end,
      })

      augroup("CloseWithQ", { clear = true })
      autocmd("FileType", {
        group = "CloseWithQ",
        pattern = { "help", "man", "lspinfo", "qf", "oil" },
        callback = function(event)
          vim.bo[event.buf].buflisted = false
          vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
        end,
      })

      augroup("CheckExternalChange", { clear = true })
      autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
        group = "CheckExternalChange",
        callback = function()
          if vim.o.buftype ~= "nofile" then
            vim.cmd("checktime")
          end
        end,
      })

      -- Additional keybindings
      vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")
      vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
      vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")
      vim.keymap.set("n", "<leader>x", "<cmd>x<cr>")
      vim.keymap.set("n", "<C-h>", "<C-w>h")
      vim.keymap.set("n", "<C-j>", "<C-w>j")
      vim.keymap.set("n", "<C-k>", "<C-w>k")
      vim.keymap.set("n", "<C-l>", "<C-w>l")
      vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>")
      vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>")
      vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>")
      vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>")
      vim.keymap.set("v", "<", "<gv")
      vim.keymap.set("v", ">", ">gv")
      vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv")
      vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv")
      vim.keymap.set("n", "J", "mzJ`z")
      vim.keymap.set("n", "<C-d>", "<C-d>zz")
      vim.keymap.set("n", "<C-u>", "<C-u>zz")
      vim.keymap.set("n", "n", "nzzzv")
      vim.keymap.set("n", "N", "Nzzzv")
    end,
  },

  -- LSP and completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "neovim/nvim-lspconfig",
    },
    event = "InsertEnter",
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      lspconfig.lua_ls.setup({ capabilities = capabilities })
      lspconfig.pyright.setup({ capabilities = capabilities })
      lspconfig.rust_analyzer.setup({ capabilities = capabilities })
      lspconfig.ts_ls.setup({ capabilities = capabilities })
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua_ls",               -- Lua
          "clangd",               -- C
          "bashls",               -- Bash
          "kotlin_language_server" -- Kotlin
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Oil.nvim
  {
    "stevearc/oil.nvim",
    keys = { "<leader>e", "<leader>of" },
    config = function()
      require("oil").setup({
        columns = { "icon", "permissions", "size", "mtime" },
        view_options = { show_hidden = true },
        float = { padding = 2, max_width = 90, max_height = 0 },
      })
      vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>")
      vim.keymap.set("n", "<leader>of", "<cmd>Oil --float<cr>")
    end,
  },

  -- Harpoon
  {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = { "<leader>hh", "<leader><leader>", "<leader>hn", "<leader>hp", "1", "2", "3", "4" },
    config = function()
      require("harpoon").setup()
      vim.keymap.set("n", "<leader>hh", "<cmd>lua require('harpoon.mark').add_file()<cr>")
      vim.keymap.set("n", "<leader><leader>", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>")
      vim.keymap.set("n", "<leader>hn", "<cmd>lua require('harpoon.ui').nav_next()<cr>")
      vim.keymap.set("n", "<leader>hp", "<cmd>lua require('harpoon.ui').nav_prev()<cr>")
      vim.keymap.set("n", "1", "<cmd>lua require('harpoon.ui').nav_file(1)<cr>")
      vim.keymap.set("n", "2", "<cmd>lua require('harpoon.ui').nav_file(2)<cr>")
      vim.keymap.set("n", "3", "<cmd>lua require('harpoon.ui').nav_file(3)<cr>")
      vim.keymap.set("n", "4", "<cmd>lua require('harpoon.ui').nav_file(4)<cr>")
    end,
  },

  -- Mini.pick
  {
    "echasnovski/mini.nvim",
    name = "mini-pick",
    keys = { "<leader>ff", "<leader>fg", "<leader>fb" },
    config = function()
      require("mini.pick").setup()
      vim.keymap.set("n", "<leader>ff", "<cmd>Pick files<cr>")
      vim.keymap.set("n", "<leader>fg", "<cmd>Pick grep_live<cr>")
      vim.keymap.set("n", "<leader>fb", "<cmd>Pick buffers<cr>")
    end,
  },
})


vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})
