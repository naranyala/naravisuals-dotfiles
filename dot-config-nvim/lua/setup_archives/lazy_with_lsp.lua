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
   "folke/tokyonight.nvim", 
   priority = 1000,
   config = function()
     vim.cmd.colorscheme("tokyonight-night")
   end
 },

 -- Core mini.nvim modules
 { 
   "echasnovski/mini.nvim", 
   config = function()
     require('mini.basics').setup({ 
       options = { extra_ui = true, win_borders = 'single' },
       mappings = { basic = true, option_toggle_prefix = '<leader>t' }
     })
     require('mini.statusline').setup({ use_icons = false })
     require('mini.pick').setup({ window = { config = { border = 'single' } } })
     -- require('mini.files').setup({ windows = { preview = true } })
     require('mini.comment').setup()
     require('mini.pairs').setup()
     require('mini.surround').setup()
     require('mini.git').setup()
     require('mini.diff').setup()
   end
 },

 -- LSP Management
 { 
   "williamboman/mason.nvim", 
   config = function()
     require("mason").setup({ ui = { border = 'single' } })
   end
 },
 { 
   "williamboman/mason-lspconfig.nvim", 
   dependencies = { "mason.nvim", "nvim-lspconfig" },
   config = function()
     require("mason-lspconfig").setup({
        ensure_installed = {
          "markdown",
          "lua_ls",               -- Lua
          "clangd",               -- C
          "bashls",               -- Bash
          "kotlin_language_server" -- Kotlin
        },
        automatic_installation = true,
     })
   end
 },

 -- LSP Configuration
 { 
   "neovim/nvim-lspconfig",
   dependencies = { "hrsh7th/cmp-nvim-lsp" },
   config = function()
     local lspconfig = require('lspconfig')
     local capabilities = require('cmp_nvim_lsp').default_capabilities()
     
     local on_attach = function(client, bufnr)
       local opts = { buffer = bufnr, silent = true }
       vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
       vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
       vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
       vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
       vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
       vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
       vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
       vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
       vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
     end

     -- Auto-setup all servers
     -- require('mason-lspconfig').setup_handlers({
     --   function(server_name)
     --     lspconfig[server_name].setup({
     --       capabilities = capabilities,
     --       on_attach = on_attach
     --     })
     --   end,
     --   ['lua_ls'] = function()
     --     lspconfig.lua_ls.setup({
     --       capabilities = capabilities, on_attach = on_attach,
     --       settings = { Lua = { diagnostics = { globals = {'vim'} } } }
     --     })
     --   end,
     --   ['clangd'] = function()
     --     lspconfig.clangd.setup({
     --       capabilities = capabilities, on_attach = on_attach,
     --       cmd = { 'clangd', '--background-index', '--clang-tidy', '--completion-style=detailed' }
     --     })
     --   end,
     --   ['rust_analyzer'] = function()
     --     lspconfig.rust_analyzer.setup({
     --       capabilities = capabilities, on_attach = on_attach,
     --       settings = {
     --         ['rust-analyzer'] = {
     --           cargo = { allFeatures = true },
     --           checkOnSave = { command = 'clippy' }
     --         }
     --       }
     --     })
     --   end
     -- })
   end
 },

 -- Completion with snippets
 { 
   "hrsh7th/nvim-cmp", 
   dependencies = { 
     "hrsh7th/cmp-nvim-lsp", 
     "hrsh7th/cmp-buffer",
     "hrsh7th/cmp-path",
     "L3MON4D3/LuaSnip",
     "saadparwaiz1/cmp_luasnip",
     "rafamadriz/friendly-snippets"
   },
   config = function()
     local cmp = require("cmp")
     local luasnip = require("luasnip")
     require("luasnip.loaders.from_vscode").lazy_load()
     
     cmp.setup({
       snippet = {
         expand = function(args)
           luasnip.lsp_expand(args.body)
         end,
       },
       mapping = {
         ['<C-n>'] = cmp.mapping.select_next_item(),
         ['<C-p>'] = cmp.mapping.select_prev_item(),
         ['<C-y>'] = cmp.mapping.confirm({ select = true }),
         ['<C-Space>'] = cmp.mapping.complete(),
         ['<Tab>'] = cmp.mapping(function(fallback)
           if luasnip.expand_or_jumpable() then 
             luasnip.expand_or_jump()
           else 
             fallback() 
           end
         end, { 'i', 's' }),
       },
       sources = {
         { name = 'nvim_lsp' },
         { name = 'luasnip' },
         { name = 'buffer' },
         { name = 'path' }
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
       ensure_installed = { 'c', 'cpp', 'rust', 'go', 'zig', 'python', 'lua', 'bash', 'cmake', 'make', 'javascript', 'typescript', 'vim', 'vimdoc' },
       highlight = { enable = true },
       indent = { enable = true }
     })
   end
 },

 -- Git integration
 { 
   "lewis6991/gitsigns.nvim", 
   config = function()
     require("gitsigns").setup()
   end
 },

 -- Project navigation
 { 
   "ThePrimeagen/harpoon", 
   dependencies = { "nvim-lua/plenary.nvim" },
   config = function()
     require("harpoon").setup()
   end
 },

 -- Oil.nvim file explorer
 { 
   "stevearc/oil.nvim", 
   config = function()
     require("oil").setup({
       float = { padding = 4 },
       view_options = { show_hidden = true }
     })
   end
 }
})

-- Keybindings
vim.g.mapleader = ' '
local map = vim.keymap.set

-- File operations (using mini.pick)
map('n', '<leader>ff', '<cmd>Pick files<cr>')
map('n', '<leader>fg', '<cmd>Pick grep_live<cr>')
map('n', '<leader>fb', '<cmd>Pick buffers<cr>')
-- map('n', '<leader>e', '<cmd>lua MiniFiles.open()<cr>')
map('n', '<leader>e', '<cmd>Oil<cr>')

-- Harpoon
map('n', '<leader>ha', '<cmd>lua require("harpoon.mark").add_file()<cr>')
map('n', '<leader><leader>', '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>')
map('n', '<leader>hn', '<cmd>lua require("harpoon.ui").nav_next()<cr>')
map('n', '<leader>hp', '<cmd>lua require("harpoon.ui").nav_prev()<cr>')

-- LSP management
map('n', '<leader>lm', '<cmd>Mason<cr>')
map('n', '<leader>li', '<cmd>LspInfo<cr>')

-- Git
map('n', '<leader>gs', '<cmd>lua MiniGit.show_at_cursor()<cr>')
map('n', '<leader>gd', '<cmd>lua MiniDiff.toggle_overlay()<cr>')

-- Quick save and escape
map('n', '<C-s>', '<cmd>w<cr>')
map('i', '<C-s>', '<esc><cmd>w<cr>')
map('i', 'jk', '<esc>')

 map('n', '1', '<cmd>lua require("harpoon.ui").nav_file(1)<cr>')
 map('n', '2', '<cmd>lua require("harpoon.ui").nav_file(2)<cr>')
 map('n', '3', '<cmd>lua require("harpoon.ui").nav_file(3)<cr>')
 map('n', '4', '<cmd>lua require("harpoon.ui").nav_file(4)<cr>')
