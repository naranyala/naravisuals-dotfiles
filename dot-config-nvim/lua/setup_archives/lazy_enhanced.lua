-- ~/.config/nvim/init.lua

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.runtimepath:prepend(lazypath)

-- General Neovim settings
vim.o.number = true          -- Show line numbers
vim.o.relativenumber = true  -- Relative line numbers for easy navigation
vim.o.tabstop = 2            -- 2 spaces for tabs
vim.o.shiftwidth = 2         -- 2 spaces for indentation
vim.o.expandtab = true       -- Convert tabs to spaces
vim.o.smartindent = true     -- Smart indentation
vim.o.termguicolors = true   -- Enable true color support
vim.o.cursorline = true      -- Highlight current line
vim.o.clipboard = 'unnamedplus' -- Use system clipboard
vim.o.mouse = 'a'            -- Enable mouse support
vim.o.updatetime = 250       -- Faster updates (for diagnostics, etc.)

-- Leader key setup
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- Set up lazy.nvim
require("lazy").setup({
  -- Colorscheme
  { 
    "folke/tokyonight.nvim",
    config = function()
      vim.cmd('colorscheme tokyonight')
    end
  },

  -- Mini.nvim modules
  { 
    "echasnovski/mini.nvim",
    event = { "BufReadPost", "BufNewFile", "InsertEnter" },
    config = function()
      require('mini.statusline').setup() -- Modern statusline
      require('mini.notify').setup()     -- Notification system
      require('mini.comment').setup()    -- Easy commenting
      require('mini.pairs').setup()      -- Auto-pair brackets, quotes
      require('mini.surround').setup()   -- Surround text with delimiters
    end
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
        automatic_installation = true,
        highlight = { enable = true },
        incremental_selection = { enable = true },
        indent = { enable = true },
      })
    end
  },

  -- LSP and completion
  { 
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = { 
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'ts_ls', 'html', 'cssls', 'pyright' },
      })
      -- local lspconfig = require('nvim-lspconfig')
      -- lspconfig.lua_ls.setup({
      --   capabilities = capabilities,
      --   settings = {
      --     Lua = {
      --       diagnostics = { globals = { 'vim' } },
      --     },
      --   },
      -- })
      lspconfig.tsserver.setup({ capabilities = capabilities })
      lspconfig.html.setup({ capabilities = capabilities })
      lspconfig.cssls.setup({ capabilities = capabilities })
      lspconfig.pyright.setup({ capabilities = capabilities })
    end
  },

  -- Fuzzy finder
  { 
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Find buffers" },
    },
    config = function()
      require('telescope').setup({
        defaults = {
          mappings = {
            i = {
              ['<C-j>'] = 'move_selection_next',
              ['<C-k>'] = 'move_selection_previous',
            },
          },
        },
      })
    end
  },

  -- File explorer
  { 
    "stevearc/oil.nvim",
    keys = { { "<leader>e", "<cmd>Oil<CR>", desc = "Open Oil file explorer" } },
    config = function()
      require('oil').setup({
        view_options = {
          show_hidden = true,
        },
        keymaps = {
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.select",
          ["<C-p>"] = "actions.preview",
          ["<C-c>"] = "actions.close",
          ["<C-r>"] = "actions.refresh",
          ["-"] = "actions.parent",
          ["_"] = "actions.open_cwd",
          ["`"] = "actions.cd",
          ["~"] = "actions.tcd",
        },
        use_default_keymaps = true,
      })
    end
  },

  -- Quick file navigation
  { 
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Add file to Harpoon" },
      { "<leader>hm", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Open Harpoon menu" },
      { "<C-1>", function() require("harpoon"):list():select(1) end, desc = "Go to Harpoon file 1" },
      { "<C-2>", function() require("harpoon"):list():select(2) end, desc = "Go to Harpoon file 2" },
      { "<C-3>", function() require("harpoon"):list():select(3) end, desc = "Go to Harpoon file 3" },
      { "<C-4>", function() require("harpoon"):list():select(4) end, desc = "Go to Harpoon file 4" },
    },
    config = function()
      require('harpoon'):setup({})
    end
  },
})

-- Keymappings
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save file' })
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = 'Quit' })
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to lower window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to upper window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- LSP diagnostic keymaps
vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, { desc = 'Find references' })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show diagnostics' })

-- Autocommand for LSP formatting
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_buf_create_user_command(ev.buf, 'Format', function()
        vim.lsp.buf.format({ async = true })
      end, { desc = 'Format current buffer with LSP' })
      vim.keymap.set('n', '<leader>f', ':Format<CR>', { buffer = ev.buf, desc = 'Format buffer' })
    end
  end,
})

-- Optional: Save plugin snapshot for reproducibility
vim.api.nvim_create_user_command('SaveSnapshot', function()
  vim.notify('Snapshot functionality is not available in lazy.nvim. Consider using :Lazy sync instead.', vim.log.levels.INFO)
end, { desc = 'Save plugin snapshot (lazy.nvim)' })


vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})
