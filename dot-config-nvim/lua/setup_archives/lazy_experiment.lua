-- ~/.config/nvim/init.lua
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.runtimepath:prepend(lazypath)

-- Core settings
vim.opt.number = true
vim.opt.signcolumn = 'yes'
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.timeoutlen = 300
vim.opt.updatetime = 250
vim.g.mapleader = ' '

-- Basic keymaps
vim.keymap.set('n', '<C-s>', '<cmd>w<cr>')
vim.keymap.set('i', 'jk', '<esc>')
vim.keymap.set('n', '<esc>', '<cmd>nohlsearch<cr>')
vim.keymap.set('n', '<leader>bn', '<cmd>bn<cr>')
vim.keymap.set('n', '<leader>bp', '<cmd>bp<cr>')
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- Setup lazy.nvim
require("lazy").setup({
  -- Colorscheme: Oxocarbon (IBM's theme)
  {
    "nyoom-engineering/oxocarbon.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('oxocarbon')
    end
  },

  -- Fuzzy finder: Snap (faster than telescope)
  {
    "camspiers/snap",
    lazy = true,
    keys = {
      { "<leader>ff", function() 
        require('snap').run({
          producer = require('snap').get('producer.ripgrep.file'),
          select = require('snap').get('select.file').select,
          multiselect = require('snap').get('select.file').multiselect,
          views = { require('snap').get('preview.file') }
        }) 
      end, desc = "Find files" },
      { "<leader>fg", function() 
        require('snap').run({
          producer = require('snap').get('producer.ripgrep.vimgrep'),
          select = require('snap').get('select.vimgrep').select,
          multiselect = require('snap').get('select.vimgrep').multiselect,
          views = { require('snap').get('preview.vimgrep') }
        }) 
      end, desc = "Live grep" },
      { "<leader>fb", function() 
        require('snap').run({
          producer = require('snap').get('producer.vim.buffer'),
          select = require('snap').get('select.file').select,
          multiselect = require('snap').get('select.file').multiselect,
          views = { require('snap').get('preview.file') }
        }) 
      end, desc = "Find buffers" },
    },
    config = function()
      require('snap').setup()
    end
  },

  -- Auto-pairs: Pears (tree-sitter based)
  {
    "steelsojka/pears.nvim",
    event = "InsertEnter",
    config = function()
      require('pears').setup()
    end
  },

  -- Surround: Sandwich (more powerful)
  {
    "machakann/vim-sandwich",
    keys = { "sa", "sd", "sr" }
  },

  -- LSP: Lsp-zero (simplified setup)
  {
    "VonHeikemen/lsp-zero.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lsp_zero = require('lsp-zero')
      
      lsp_zero.on_attach(function(client, bufnr)
        lsp_zero.default_keymaps({buffer = bufnr})
      end)
      
      lsp_zero.setup_servers({'lua_ls', 'tsserver', 'pyright'})
      
      local cmp = require('cmp')
      cmp.setup({
        sources = {
          {name = 'nvim_lsp'},
          {name = 'luasnip'},
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({select = true}),
        }),
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
      })
    end
  },

  -- Treesitter: Nvim-ts-context-commentstring (better comments)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
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
        indent = { enable = true },
      })
      -- require('ts_context_commentstring').setup({
      --   enable_autocmd = false,
      -- })
    end
  },

  -- Comments: Comment.nvim with treesitter integration
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
    },
    config = function()
      require('Comment').setup({
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      })
    end
  },

  -- Git: Diffview (better git diff)
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git diff" },
      { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "Git history" },
    },
    config = function()
      require('diffview').setup()
    end
  },

  -- Formatting: None-ls (null-ls successor)
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      { "<leader>f", vim.lsp.buf.format, desc = "Format buffer" },
    },
    config = function()
      local null_ls = require('null-ls')
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.formatting.black,
        },
      })
    end
  },

  -- Session: Possession (lightweight sessions)
  {
    "jedrzejboczar/possession.nvim",
    cmd = { "PossessionSave", "PossessionLoad" },
    keys = {
      { "<leader>ss", "<cmd>PossessionSave<cr>", desc = "Save session" },
      { "<leader>sr", "<cmd>PossessionLoad<cr>", desc = "Load session" },
    },
    config = function()
      require('possession').setup()
    end
  },

  -- Indentation: Ibl (indent-blankline successor)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require('ibl').setup()
    end
  },

  -- Terminal: Toggleterm (floating terminal)
  {
    "akinsho/toggleterm.nvim",
    keys = { "<leader>t" },
    config = function()
      require('toggleterm').setup({
        open_mapping = [[<leader>t]],
        direction = 'float',
      })
    end
  },

  -- Movement: Leap (fast navigation)
  {
    "ggandor/leap.nvim",
    keys = { "s", "S", "gs" },
    config = function()
      require('leap').add_default_mappings()
    end
  },

  -- Buffers: Bufdelete (better buffer closing)
  {
    "famiu/bufdelete.nvim",
    cmd = { "Bdelete", "Bwipeout" },
    keys = {
      { "<leader>bd", "<cmd>Bdelete<cr>", desc = "Delete buffer" },
    },
  },
})


vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})
