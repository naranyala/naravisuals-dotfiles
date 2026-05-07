-- ~/.config/nvim/init.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
 vim.fn.system({
   "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath
 })
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
 -- Theme
 {
   "rebelot/kanagawa.nvim",
   priority = 1000,
   config = function()
     vim.cmd.colorscheme("kanagawa-wave")
   end
 },

 -- File explorer
 {
   "nvim-tree/nvim-tree.lua",
   dependencies = { "nvim-tree/nvim-web-devicons" },
   config = function()
     require("nvim-tree").setup({
       view = { width = 30 },
       renderer = { group_empty = true },
       filters = { dotfiles = false }
     })
   end
 },

 -- Fuzzy finder
 {
   "nvim-telescope/telescope.nvim",
   dependencies = { "nvim-lua/plenary.nvim" },
   config = function()
     require("telescope").setup({
       defaults = {
         prompt_prefix = "🔍 ",
         selection_caret = "➤ ",
         layout_config = { horizontal = { preview_width = 0.55 } }
       }
     })
   end
 },

 -- Statusline
 {
   "nvim-lualine/lualine.nvim",
   dependencies = { "nvim-tree/nvim-web-devicons" },
   config = function()
     require("lualine").setup({
       options = { theme = "kanagawa" },
       sections = {
         lualine_c = {{'filename', path = 1}},
         lualine_x = {'encoding', 'fileformat', 'filetype'}
       }
     })
   end
 },

 -- LSP installer
 {
   "neovim/nvim-lspconfig",
   dependencies = {
     "williamboman/mason.nvim",
     "williamboman/mason-lspconfig.nvim",
     "j-hui/fidget.nvim"
   },
   config = function()
     require("mason").setup()
     require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",               -- Lua
          "clangd",               -- C
          "bashls",               -- Bash
          "kotlin_language_server" -- Kotlin
        },
     })
     require("fidget").setup({})
     
     local lspconfig = require("lspconfig")
     local on_attach = function(client, bufnr)
       local opts = { buffer = bufnr }
       vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
       vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
       vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
       vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
       vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
       vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, opts)
     end

     -- require("mason-lspconfig").setup_handlers({
     --   function(server_name)
     --     lspconfig[server_name].setup({ on_attach = on_attach })
     --   end,
     --   ["lua_ls"] = function()
     --     lspconfig.lua_ls.setup({
     --       on_attach = on_attach,
     --       settings = { Lua = { diagnostics = { globals = {'vim'} } } }
     --     })
     --   end
     -- })
   end
 },

 -- Completion
 {
   "saghen/blink.cmp",
   lazy = false,
   dependencies = "rafamadriz/friendly-snippets",
   version = "v0.*",
   config = function()
     require("blink.cmp").setup({
       keymap = { preset = 'default' },
       appearance = {
         use_nvim_cmp_as_default = true,
         nerd_font_variant = 'mono'
       },
       sources = {
         default = { 'lsp', 'path', 'snippets', 'buffer' }
       }
     })
   end
 },

 -- Treesitter
 {
   "nvim-treesitter/nvim-treesitter",
   build = ":TSUpdate",
   config = function()
     require("nvim-treesitter.configs").setup({
       ensure_installed = { "lua", "python", "rust", "c", "cpp", "javascript", "typescript", "vim" },
       highlight = { enable = true },
       indent = { enable = true }
     })
   end
 },

 -- Comments
 {
   "numToStr/Comment.nvim",
   config = function()
     require("Comment").setup()
   end
 },

 -- Auto pairs
 {
   "windwp/nvim-autopairs",
   config = function()
     require("nvim-autopairs").setup({})
   end
 },

 -- Git signs
 {
   "airblade/vim-gitgutter",
   config = function()
     vim.g.gitgutter_map_keys = 0
   end
 },

 -- Which key
 {
   "folke/which-key.nvim",
   config = function()
     require("which-key").setup({
       window = { border = "rounded" }
     })
   end
 },

 -- Dashboard
 {
   "goolord/alpha-nvim",
   config = function()
     require("alpha").setup(require("alpha.themes.dashboard").config)
   end
 }
})

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"

-- Keybindings
vim.g.mapleader = ' '
local map = vim.keymap.set

-- File operations
map('n', '<leader>e', '<cmd>NvimTreeToggle<cr>')
map('n', '<leader>ff', '<cmd>Telescope find_files<cr>')
map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>')
map('n', '<leader>fb', '<cmd>Telescope buffers<cr>')
map('n', '<leader>fh', '<cmd>Telescope help_tags<cr>')

-- Navigation
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- Git
map('n', '<leader>gn', '<cmd>GitGutterNextHunk<cr>')
map('n', '<leader>gp', '<cmd>GitGutterPrevHunk<cr>')
map('n', '<leader>gs', '<cmd>GitGutterStageHunk<cr>')
map('n', '<leader>gu', '<cmd>GitGutterUndoHunk<cr>')

-- Quick save and escape
map('n', '<C-s>', '<cmd>w<cr>')
map('i', '<C-s>', '<esc><cmd>w<cr>')
map('i', 'jk', '<esc>')

-- Buffer navigation
map('n', '<Tab>', '<cmd>bnext<cr>')
map('n', '<S-Tab>', '<cmd>bprev<cr>')
map('n', '<leader>bd', '<cmd>bdelete<cr>')


vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})
