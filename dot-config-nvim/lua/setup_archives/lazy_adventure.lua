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
   "EdenEast/nightfox.nvim",
   priority = 1000,
   config = function()
     vim.cmd.colorscheme("carbonfox")
   end
 },

  { 
    "stevearc/oil.nvim", 
    config = function()
      require("oil").setup({
        view_options = {
          show_hidden = true,
        },
      })
      vim.keymap.set("n", "<leader>o", "<cmd>Oil<cr>")
    end
  },


 -- File explorer
 -- {
 --   "ms-jpq/chadtree",
 --   build = "python3 -m chadtree deps",
 --   config = function()
 --     vim.g.chadtree_settings = {
 --       view = { width = 25 },
 --       theme = { text_colour_set = "nerdtree_syntax_dark" }
 --     }
 --   end
 -- },

 -- Fuzzy finder
 {
   "ibhagwan/fzf-lua",
   dependencies = { "nvim-tree/nvim-web-devicons" },
   config = function()
     require("fzf-lua").setup({
       winopts = {
         height = 0.85,
         width = 0.80,
         preview = { default = "bat" }
       }
     })
   end
 },

 -- Statusline
 {
   "feline-nvim/feline.nvim",
   dependencies = { "nvim-tree/nvim-web-devicons" },
   config = function()
     require("feline").setup({
       theme = "default",
       vi_mode_colors = {
         NORMAL = "green",
         INSERT = "blue",
         VISUAL = "yellow",
         COMMAND = "red"
       }
     })
   end
 },

 -- LSP with different setup
 {
   "VonHeikemen/lsp-zero.nvim",
   branch = "v3.x",
   dependencies = {
     "neovim/nvim-lspconfig",
     "hrsh7th/cmp-nvim-lsp",
     "hrsh7th/nvim-cmp",
     "L3MON4D3/LuaSnip",
     "williamboman/mason.nvim",
     "williamboman/mason-lspconfig.nvim"
   },
   config = function()
     local lsp_zero = require("lsp-zero")
     lsp_zero.extend_lspconfig()

     lsp_zero.on_attach(function(client, bufnr)
       local opts = { buffer = bufnr }
       vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
       vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
       vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
       vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
       vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
     end)

     require("mason").setup()
     require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",               -- Lua
          "clangd",               -- C
          "bashls",               -- Bash
          "kotlin_language_server" -- Kotlin
        },
        automatic_installation = true,
       handlers = { lsp_zero.default_setup }
     })

     local cmp = require("cmp")
     cmp.setup({
       sources = {
         { name = "nvim_lsp" },
         { name = "luasnip" },
         { name = "buffer" }
       },
       mapping = {
         ['<C-p>'] = cmp.mapping.select_prev_item(),
         ['<C-n>'] = cmp.mapping.select_next_item(),
         ['<C-y>'] = cmp.mapping.confirm({ select = true }),
         ['<C-Space>'] = cmp.mapping.complete()
       },
       snippet = {
         expand = function(args)
           require("luasnip").lsp_expand(args.body)
         end
       }
     })
   end
 },

 -- Treesitter alternative
 {
   "nvim-treesitter/nvim-treesitter",
   build = ":TSUpdate",
   dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
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
       textobjects = {
         select = {
           enable = true,
           lookahead = true,
           keymaps = {
             ["af"] = "@function.outer",
             ["if"] = "@function.inner",
             ["ac"] = "@class.outer",
             ["ic"] = "@class.inner"
           }
         }
       }
     })
   end
 },

 -- Session management
 {
   "rmagatti/auto-session",
   config = function()
     require("auto-session").setup({
       log_level = "error",
       auto_session_suppress_dirs = { "~/", "~/Downloads", "/" }
     })
   end
 },

 -- Terminal
 {
   "akinsho/toggleterm.nvim",
   config = function()
     require("toggleterm").setup({
       size = 20,
       open_mapping = [[<c-\>]],
       direction = "float",
       float_opts = { border = "curved" }
     })
   end
 },

 -- Commenting
 {
   "tpope/vim-commentary",
   config = function()
     vim.keymap.set('n', '<leader>/', '<cmd>Commentary<cr>')
     vim.keymap.set('v', '<leader>/', '<cmd>Commentary<cr>')
   end
 },

 -- Surround
 {
   "kylechui/nvim-surround",
   config = function()
     require("nvim-surround").setup()
   end
 },

 -- Git
 {
   "tpope/vim-fugitive",
   config = function()
     vim.keymap.set('n', '<leader>gs', '<cmd>Git<cr>')
     vim.keymap.set('n', '<leader>gd', '<cmd>Gdiffsplit<cr>')
     vim.keymap.set('n', '<leader>gc', '<cmd>Git commit<cr>')
     vim.keymap.set('n', '<leader>gp', '<cmd>Git push<cr>')
   end
 },

 -- Indent guides
 {
   "lukas-reineke/indent-blankline.nvim",
   main = "ibl",
   config = function()
     require("ibl").setup({
       indent = { char = "│" },
       scope = { enabled = false }
     })
   end
 },

 -- Leap motion
 {
   "ggandor/leap.nvim",
   config = function()
     require("leap").add_default_mappings()
   end
 },

 -- Colorizer
 {
   "norcalli/nvim-colorizer.lua",
   config = function()
     require("colorizer").setup()
   end
 },

 -- Trouble diagnostics
 {
   "folke/trouble.nvim",
   dependencies = { "nvim-tree/nvim-web-devicons" },
   config = function()
     require("trouble").setup()
   end
 },

 -- Bufferline
 {
   "akinsho/bufferline.nvim",
   dependencies = { "nvim-tree/nvim-web-devicons" },
   config = function()
     require("bufferline").setup({
       options = {
         diagnostics = "nvim_lsp",
         show_buffer_close_icons = false,
         show_close_icon = false
       }
     })
   end
 }
})

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50

-- Keybindings
vim.g.mapleader = ' '
local map = vim.keymap.set

-- File operations
map('n', '<leader>e', '<cmd>Oil<cr>')
map('n', '<leader>ff', '<cmd>FzfLua files<cr>')
map('n', '<leader>fg', '<cmd>FzfLua live_grep<cr>')
map('n', '<leader>fb', '<cmd>FzfLua buffers<cr>')
map('n', '<leader>fh', '<cmd>FzfLua helptags<cr>')
map('n', '<leader>fr', '<cmd>FzfLua oldfiles<cr>')

-- Diagnostics
map('n', '<leader>xx', '<cmd>TroubleToggle<cr>')
map('n', '<leader>xw', '<cmd>TroubleToggle workspace_diagnostics<cr>')
map('n', '<leader>xd', '<cmd>TroubleToggle document_diagnostics<cr>')

-- Navigation
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- Buffer navigation
map('n', '<S-l>', '<cmd>BufferLineCycleNext<cr>')
map('n', '<S-h>', '<cmd>BufferLineCyclePrev<cr>')
map('n', '<leader>bd', '<cmd>bdelete<cr>')

-- Sessions
map('n', '<leader>ss', '<cmd>SessionSave<cr>')
map('n', '<leader>sr', '<cmd>SessionRestore<cr>')

-- Quick save and escape
map('n', '<C-s>', '<cmd>w<cr>')
map('i', '<C-s>', '<esc><cmd>w<cr>')
map('i', 'jk', '<esc>')

-- Clear search highlight
map('n', '<leader>h', '<cmd>nohlsearch<cr>')

-- Move lines
map('v', 'J', ":m '>+1<CR>gv=gv")
map('v', 'K', ":m '<-2<CR>gv=gv")


vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})
