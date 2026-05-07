-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ==========================
-- Default Neovim Tweaks
-- ==========================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 300
vim.opt.scrolloff = 8
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true

-- ==========================
-- Plugins via lazy.nvim
-- ==========================
require("lazy").setup({
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim", config = true },
    { "williamboman/mason-lspconfig.nvim" },
    { "hrsh7th/nvim-cmp", dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
    }},
    { "glepnir/lspsaga.nvim", branch = "main" },
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    { "lewis6991/gitsigns.nvim" },
    { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },
    { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
    { "numToStr/Comment.nvim", config = true },
    { "rcarriga/nvim-notify" },
    { "folke/which-key.nvim", config = true },
    { "catppuccin/nvim", name = "catppuccin" },
})

vim.cmd.colorscheme("catppuccin")

require("nvim-treesitter.configs").setup {
  ensure_installed = { "kotlin", "java", "lua", "vim", "python", "bash", "markdown", "json", "yaml" },
  highlight = { enable = true },
  indent = { enable = true },
}
require("gitsigns").setup()
require("nvim-tree").setup()
require("lualine").setup { options = { theme = "catppuccin" } }
require("notify")
vim.notify = require("notify")

require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = { "kotlin_language_server", "jdtls", "lua_ls" },
}
local lspconfig = require("lspconfig")
lspconfig.kotlin_language_server.setup {}
lspconfig.jdtls.setup {}
lspconfig.lua_ls.setup {}

require('lspsaga').setup({ lightbulb = { enable = false } })

local cmp = require'cmp'
cmp.setup({
  snippet = { expand = function(args) require'luasnip'.lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' }, { name = 'luasnip' }
  })
})

-- ==========================
-- Ergonomic Keymaps
-- ==========================
vim.g.mapleader = " "
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- LSP
map('n', 'gd', '<cmd>Lspsaga goto_definition<CR>', { desc = 'Go to definition' })
map('n', 'gD', '<cmd>Lspsaga peek_definition<CR>', { desc = 'Peek definition' })
map('n', 'gr', '<cmd>Lspsaga finder<CR>', { desc = 'LSP references/implementations' })
map('n', 'K', '<cmd>Lspsaga hover_doc<CR>', { desc = 'Hover Documentation' })
map('n', '<leader>ca', '<cmd>Lspsaga code_action<CR>', { desc = 'Code Action' })
map('n', '[d', '<cmd>Lspsaga diagnostic_jump_prev<CR>', { desc = 'Prev Diagnostic' })
map('n', ']d', '<cmd>Lspsaga diagnostic_jump_next<CR>', { desc = 'Next Diagnostic' })
map('n', '<leader>rn', '<cmd>Lspsaga rename<CR>', { desc = 'Rename Symbol' })
map('n', '<leader>o', '<cmd>Lspsaga outline<CR>', { desc = 'Symbol Outline' })

-- File explorer, search, buffer, etc.
map('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle File Explorer' })
map('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = 'Find Files' })
map('n', '<leader>fr', '<cmd>Telescope oldfiles<CR>', { desc = 'Recent Files' })
map('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { desc = 'Grep' })
map('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { desc = 'Buffers' })
map('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', { desc = 'Help tags' })
map('n', '<leader>fw', '<cmd>Telescope grep_string<CR>', { desc = 'Current Word' })
map('n', '<leader>fm', '<cmd>Telescope marks<CR>', { desc = 'Marks' })
map('n', '<leader>fc', '<cmd>Telescope commands<CR>', { desc = 'Commands' })

-- Window management
map('n', '<C-h>', '<C-w>h', opts) -- Move to left split
map('n', '<C-j>', '<C-w>j', opts) -- Move to below split
map('n', '<C-k>', '<C-w>k', opts) -- Move to above split
map('n', '<C-l>', '<C-w>l', opts) -- Move to right split
map('n', '<leader>sv', '<C-w>v', { desc = 'Split Vertical' })
map('n', '<leader>sh', '<C-w>s', { desc = 'Split Horizontal' })
map('n', '<leader>sx', '<cmd>close<CR>', { desc = 'Close Split' })

-- Tabs
map('n', '<leader>tn', '<cmd>tabnew<CR>', { desc = 'New Tab' })
map('n', '<leader>tc', '<cmd>tabclose<CR>', { desc = 'Close Tab' })
map('n', '<leader>to', '<cmd>tabonly<CR>', { desc = 'Only Tab' })
map('n', '<leader>tp', '<cmd>tabprevious<CR>', { desc = 'Prev Tab' })
map('n', '<leader>tn', '<cmd>tabnext<CR>', { desc = 'Next Tab' })

-- Buffer navigation
map('n', '<Tab>', ':bnext<CR>', opts)
map('n', '<S-Tab>', ':bprev<CR>', opts)
map('n', '<leader>bd', ':bdelete<CR>', { desc = "Delete Buffer" })

-- Quick save & quit
map('n', '<leader>w', ':w<CR>', { desc = "Save File" })
map('n', '<leader>q', ':q<CR>', { desc = "Quit" })
map('n', '<leader>Q', ':qa!<CR>', { desc = "Quit All (Force)" })

-- Comment
map('n', '<leader>c', '<cmd>lua require("Comment.api").toggle.linewise.current()<CR>', { desc = 'Toggle Comment' })
map('v', '<leader>c', '<esc><cmd>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>', { desc = 'Toggle Comment (Visual)' })

-- Move lines up/down (visual mode)
map('v', '<A-j>', ":m '>+1<CR>gv=gv", opts)
map('v', '<A-k>', ":m '<-2<CR>gv=gv", opts)

-- Select all
map('n', '<C-a>', 'ggVG', { desc = "Select All" })

-- Clear search highlight
map('n', '<leader>h', ':nohlsearch<CR>', { desc = "Clear Highlight" })

-- Toggle relative number
map('n', '<leader>rn', function()
    vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "Toggle Relative Number" })

-- System clipboard yank/paste
map({'n', 'v'}, '<leader>y', '"+y', { desc = "Yank to system clipboard" })
map({'n', 'v'}, '<leader>p', '"+p', { desc = "Paste from system clipboard" })

-- WhichKey show all
map('n', '<leader>?', '<cmd>WhichKey<CR>', { desc = "Show All Keymaps" })
