vim.g.mapleader = " "
vim.g.maplocalleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({"git","clone","--filter=blob:none","https://github.com/folke/lazy.nvim.git","--branch=stable",lazypath})
end
vim.opt.rtp:prepend(lazypath)


require("lazy").setup({

	require("./_shared/missing_native_apis"),
	require("./_shared/tpope_goodies"),
    require("./_shared/lualine_and_theme"),

  {"tpope/vim-surround"},
  {"tpope/vim-repeat"},
  {"tpope/vim-unimpaired"},
  {"tpope/vim-fugitive"},
  {"numToStr/Comment.nvim", config=true},
  {"junegunn/fzf.vim", depends={"junegunn/fzf", build="fzf#install()"}},
  {"neovim/nvim-lspconfig"},
  {"williamboman/mason.nvim", config=true},
  {"williamboman/mason-lspconfig.nvim"},
  {"nvim-treesitter/nvim-treesitter", build=":TSUpdate", config=function()
    require("nvim-treesitter.configs").setup{
      ensure_installed={"c","lua","vim","vimdoc","rust","javascript","typescript","python","go","bash"},
      highlight={enable=true}, indent={enable=true}, incremental_selection={enable=true},
    }
  end},
  {"luisiacc/gruvbox-baby", priority=1000, lazy=false, config=function() vim.cmd[[colorscheme gruvbox-baby]] end},
})

-- Core options (still suckless)
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0   -- use tabstop value
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 200
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 16
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = {tab = "→ ", trail = "·", nbsp = "␣"}

-- === ERGONOMICS HACKS & CUSTOM FUNCTIONS (zero plugins added) ===

local k = vim.keymap.set
local cmd = vim.cmd
local api = vim.api

-- Better window navigation
k("n", "<C-h>", "<C-w>h")
k("n", "<C-j>", "<C-w>j")
k("n", "<C-k>", "<C-w>k")
k("n", "<C-l>", "<C-w>l")

-- Resize windows with arrow keys
-- k("n", "<Up>",    ":resize +2<CR>")
-- k("n", "<Down>",  ":resize -2<CR>")
-- k("n", "<Left>",  ":vertical resize -2<CR>")
-- k("n", "<Right>", ":vertical resize +2<CR>")

-- Move lines up/down (like VSCode)
k("n", "<A-j>", ":m .+1<CR>==")
k("n", "<A-k>", ":m .-2<CR>==")
k("v", "<A-j>", ":m '>+1<CR>gv=gv")
k("v", "<A-k>", ":m '<-2<CR>gv=gv")

-- Keep cursor in place for common ops
k("n", "J", "mzJ`z")                    -- join lines without moving cursor
k("n", "<C-d>", "<C-d>zz")              -- half-page down + center
k("n", "<C-u>", "<C-u>zz")              -- half-page up + center
k("n", "n", "nzzzv")                    -- next search + center
k("n", "N", "Nzzzv")

-- Better indenting in visual
k("v", "<", "<gv")
k("v", ">", ">gv")

-- Quick save/quit
k("n", "<leader>w", ":w<CR>")
k("n", "<leader>q", ":q<CR>")
k("n", "<leader>x", ":x<CR>")

-- === Custom functions (pure Lua, no plugins) ===

-- Toggle relative/absolute line numbers
k("n", "<leader>un", function()
  vim.o.number = not vim.o.number
  vim.o.relativenumber = vim.o.number
end)

-- Toggle search highlight
k("n", "<leader>uh", function() vim.o.hlsearch = not vim.o.hlsearch end)

-- Quick buffer navigation
k("n", "<leader>bb", ":b#<CR>")         -- alternate buffer
k("n", "<leader>bd", ":bd<CR>")         -- delete buffer
k("n", "[b", ":bprevious<CR>")
k("n", "]b", ":bnext<CR>")

-- Git shortcuts (fugitive)
k("n", "<leader>gs", ":G<CR>")
k("n", "<leader>gc", ":G commit<CR>")
k("n", "<leader>gp", ":G push<CR>")
k("n", "<leader>gl", ":G pull<CR>")

-- FZF power
k("n", "<leader>f",  ":FZF<CR>")
k("n", "<leader>/",  ":Rg<CR>")         -- requires `rg` installed
k("n", "<leader>fb", ":Buffers<CR>")
k("n", "<leader>fh", ":History<CR>")

-- LSP (auto-installed + ergonomic mappings)
require("mason-lspconfig").setup{ensure_installed={"lua_ls","rust_analyzer","tsserver","pyright","gopls"}}
local lsp = require("lspconfig")
local on_attach = function(_, bufnr)
  local b = function(m,l,r) k(m,l,r,{buffer=bufnr}) end
  b("n","gd", vim.lsp.buf.definition)
  b("n","gD", vim.lsp.buf.declaration)
  b("n","gi", vim.lsp.buf.implementation)
  b("n","gr", vim.lsp.buf.references)
  b("n","K",  vim.lsp.buf.hover)
  b("n","<leader>r", vim.lsp.buf.rename)
  b("n","<leader>ca", vim.lsp.buf.code_action)
  b("n","<leader>df", vim.diagnostic.open_float)
  b("n","[d", vim.diagnostic.goto_prev)
  b("n","]d", vim.diagnostic.goto_next)
end
for _, server in ipairs{"lua_ls","rust_analyzer","tsserver","pyright","gopls"} do
  lsp[server].setup{on_attach=on_attach}
end

-- Comment (gcc already works, but visual block too)
local comment = require("Comment.api")
k("n", "gcc", comment.toggle.linewise.current)
k("x", "gc",  comment.toggle.linewise.visual)

-- Auto-install Mason packages on first start
api.nvim_create_autocmd("User", {pattern="LazyInstall", once=true, callback=function() cmd[[MasonUpdate]] end})
