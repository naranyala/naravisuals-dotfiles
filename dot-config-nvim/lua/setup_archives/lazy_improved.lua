-- ~/.config/nvim/init.lua

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.runtimepath:prepend(lazypath)

-- Helper function to create key mappings
local map = function(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Basic editor settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.signcolumn = 'yes'
vim.opt.termguicolors = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 8

-- Auto commands
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'gitcommit', 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Set up lazy.nvim
require("lazy").setup({
  -- Core dependencies
  { "nvim-lua/plenary.nvim", lazy = true }, -- Dependency for Telescope, etc.
  { "nvim-tree/nvim-web-devicons", lazy = true }, -- Icons for Oil, Lualine

  -- Colorscheme
  { 
    "rebelot/kanagawa.nvim",
    config = function()
      vim.cmd.colorscheme('kanagawa')
    end
  },

  -- Statusline
  { 
    "nvim-lualine/lualine.nvim",
    event = "VimEnter",
    config = function()
      require('lualine').setup({
        options = {
          theme = 'kanagawa',
          component_separators = '|',
          section_separators = { left = '', right = '' },
        },
      })
    end
  },

  -- File navigation
  { 
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
      { "<leader>e", "<CMD>Oil<CR>", desc = "Open file explorer" },
    },
    config = function()
      require('oil').setup({
        default_file_explorer = true,
        keymaps = {
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.select",
          ["<C-s>"] = "actions.select_vsplit",
          ["<C-h>"] = "actions.select_split",
          ["<C-t>"] = "actions.select_tab",
          ["<C-p>"] = "actions.preview",
          ["<C-c>"] = "actions.close",
          ["<C-l>"] = "actions.refresh",
          ["-"] = "actions.parent",
          ["_"] = "actions.open_cwd",
          ["`"] = "actions.cd",
          ["~"] = "actions.tcd",
          ["gs"] = "actions.change_sort",
          ["gx"] = "actions.open_external",
          ["g."] = "actions.toggle_hidden",
        },
        use_default_keymaps = false,
      })
    end
  },

  -- Quick file navigation
  { 
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>a", function() require("harpoon"):list():add() end, desc = "Add file to harpoon" },
      { "<leader>h", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Show harpoon menu" },
      { "<leader>1", function() require("harpoon"):list():select(1) end, desc = "Harpoon mark 1" },
      { "<leader>2", function() require("harpoon"):list():select(2) end, desc = "Harpoon mark 2" },
      { "<leader>3", function() require("harpoon"):list():select(3) end, desc = "Harpoon mark 3" },
      { "<leader>4", function() require("harpoon"):list():select(4) end, desc = "Harpoon mark 4" },
      { "<C-p>", function() require("harpoon"):list():prev() end, desc = "Previous harpoon mark" },
      { "<C-n>", function() require("harpoon"):list():next() end, desc = "Next harpoon mark" },
    },
    config = function()
      require("harpoon"):setup()
    end
  },

  -- Syntax highlighting
  { 
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua_ls",               -- Lua
          "clangd",               -- C
          "bashls",               -- Bash
          "kotlin_language_server" -- Kotlin
        },
        automatic_installation = true,
        highlight = { enable = true },
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
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { 'i', 's' }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        },
      })
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'path' },
          { name = 'cmdline' },
        },
      })
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'pyright', 'tsserver', 'html', 'cssls', 'bashls' },
      })
      require('lspconfig').lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
            workspace = { library = vim.api.nvim_get_runtime_file('', true) },
            telemetry = { enable = false },
          },
        },
      })
      -- LSP keymaps
      map('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
      map('n', 'K', vim.lsp.buf.hover, { desc = 'Hover documentation' })
      map('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
      map('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
    end
  },

  -- Fuzzy finder
  { 
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    },
    config = function()
      require('telescope').setup({
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
        },
      })
    end
  },

  -- Git integration
  { 
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require('gitsigns').setup({
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
      })
    end
  },

  -- Comments
  { 
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require('Comment').setup()
    end
  },

  -- Autopairs
  { 
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require('nvim-autopairs').setup()
    end
  },

  -- Indent guides
  { 
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require('indent_blankline').setup({ char = '┊', show_trailing_blankline_indent = false })
    end
  },

  -- Terminal integration
  { 
    "akinsho/toggleterm.nvim",
    keys = { { "<c-\\>", desc = "Toggle terminal" } },
    config = function()
      require('toggleterm').setup({ size = 20, open_mapping = [[<c-\>]], direction = 'float' })
    end
  },

  -- UI improvements
  { 
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    config = function()
      require('dressing').setup()
    end
  },
  { 
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons" },
    config = function()
      require('noice').setup()
    end
  },
  { "MunifTanjim/nui.nvim", lazy = true }, -- Dependency for noice.nvim
})

-- General keymaps
map('n', '<leader>q', '<cmd>q<cr>', { desc = 'Quit' })
map('n', '<leader>w', '<cmd>w<cr>', { desc = 'Save' })
map('n', '<leader>x', '<cmd>x<cr>', { desc = 'Save and quit' })


vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})
