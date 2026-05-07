-- ~/.config/nvim/init.lua
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

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.cursorline = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.laststatus = 2

-- Plugins
require("lazy").setup({
  -- File explorer
  {
    "preservim/nerdtree",
    cmd = { "NERDTree", "NERDTreeToggle", "NERDTreeFind" },
    keys = {
      { "<leader>e", "<cmd>NERDTreeToggle<cr>", desc = "Toggle NERDTree" },
    },
    config = function()
      vim.g.NERDTreeWinSize = 30
      vim.g.NERDTreeMinimalUI = 1
      vim.g.NERDTreeDirArrows = 1
      vim.g.NERDTreeShowHidden = 1
      vim.g.NERDTreeAutoDeleteBuffer = 1
    end,
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


  -- Git
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiff", "Glog" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
      { "<leader>gd", "<cmd>Gdiff<cr>", desc = "Git diff" },
    },
  },

  -- Text manipulation
  {
    "tpope/vim-surround",
    event = "VeryLazy",
  },

  {
    "tpope/vim-commentary",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Toggle comment" },
      { "<leader>/", "gcc", desc = "Comment line", remap = true },
    },
  },

  -- Auto pairs
  {
    "jiangmiao/auto-pairs",
    event = "InsertEnter",
  },

  -- Fuzzy finder
  {
    "junegunn/fzf.vim",
    dependencies = { "junegunn/fzf" },
    cmd = { "Files", "Buffers", "Rg", "History" },
    keys = {
      { "<leader>f", "<cmd>Files<cr>", desc = "Find files" },
      { "<leader>b", "<cmd>Buffers<cr>", desc = "Find buffers" },
      { "<leader>r", "<cmd>Rg<cr>", desc = "Live grep" },
    },
    config = function()
      vim.g.fzf_layout = { down = "~40%" }
    end,
  },

  -- Status line
  {
    "itchyny/lightline.vim",
    event = "VeryLazy",
    config = function()
      vim.g.lightline = {
        colorscheme = "wombat",
        active = {
          left = { { "mode", "paste" }, { "readonly", "filename", "modified" } },
          right = { { "lineinfo" }, { "percent" }, { "filetype" } },
        },
      }
    end,
  },

  -- Syntax highlighting
  {
    "sheerun/vim-polyglot",
    event = "BufReadPre",
  },

  -- Colorscheme
  {
    "morhetz/gruvbox",
    priority = 1000,
    config = function()
      vim.g.gruvbox_contrast_dark = "medium"
      vim.cmd("colorscheme gruvbox")
    end,
  },
})

-- Keymaps
local keymap = vim.keymap.set

-- Better escape
keymap("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- Save and quit
keymap("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
keymap("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

-- Clear search
keymap("n", "<leader>h", "<cmd>noh<cr>", { desc = "Clear highlights" })

-- Buffer navigation
keymap("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
keymap("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
keymap("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Close buffer" })

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize windows
keymap("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
keymap("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
keymap("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
keymap("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Better indenting
keymap("v", "<", "<gv", { desc = "Unindent line" })
keymap("v", ">", ">gv", { desc = "Indent line" })

-- Move text up and down
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move text down" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move text up" })

-- Better join
keymap("n", "J", "mzJ`z", { desc = "Join lines" })

-- Keep cursor centered
keymap("n", "<C-d>", "<C-d>zz", { desc = "Half page down" })
keymap("n", "<C-u>", "<C-u>zz", { desc = "Half page up" })
keymap("n", "n", "nzzzv", { desc = "Next search result" })
keymap("n", "N", "Nzzzv", { desc = "Previous search result" })

-- Terminal
keymap("n", "<leader>t", "<cmd>terminal<cr>", { desc = "Open terminal" })
keymap("t", "<C-\\><C-n>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Autocommands
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = "YankHighlight",
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Remove trailing whitespace
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = "TrimWhitespace",
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Restore cursor position
-- augroup("RestoreCursor", { clear = true })
-- autocmd("BufReadPost", {
--   group = "RestoreCursor",
--   pattern = "*",
--   callback = function()
--     local line = vim.fn.line("'\"")
--     if line > 1 and line <= vim.fn.line("$") and vim.bo.filetype ~= "commit" then
--       vim.cmd('normal! g`"')
--     end,
--   end,
-- })

-- File type settings
augroup("FileTypeSettings", { clear = true })
autocmd("FileType", {
  group = "FileTypeSettings",
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

autocmd("FileType", {
  group = "FileTypeSettings",
  pattern = { "go" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
  end,
})

-- Terminal settings
augroup("TerminalSettings", { clear = true })
autocmd("TermOpen", {
  group = "TerminalSettings",
  pattern = "*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})


vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})


