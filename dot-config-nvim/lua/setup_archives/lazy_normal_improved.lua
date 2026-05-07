-- ~/.config/nvim/init.lua

-- Alternative lazy.nvim bootstrap method
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.runtimepath:prepend(lazypath)

-- Set up lazy.nvim
require("lazy").setup({
  -- Core essentials (loaded immediately)
  { 
    "folke/tokyonight.nvim", 
    config = function()
      vim.cmd.colorscheme("tokyonight-night")
    end
  },

  -- Editor settings (loaded immediately)
  { 
    "tpope/vim-sensible", 
    config = function()
      vim.opt.number = true
      vim.opt.signcolumn = "yes"
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.termguicolors = true

      -- Leader key
      vim.g.mapleader = " "

      -- Basic keymaps
      vim.keymap.set("n", "<C-s>", "<cmd>w<cr>")
      vim.keymap.set("i", "jk", "<esc>")
    end
  },

  -- File management
  { 
    "nvim-tree/nvim-tree.lua", 
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>")
    end
  },

  -- Fuzzy finder
  { 
    "nvim-telescope/telescope.nvim", 
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup()
      vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
      vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
      vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
    end
  },

  -- Treesitter (syntax highlighting)
  { 
    "nvim-treesitter/nvim-treesitter", 
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
    end
  },

  -- LSP & Completion
  { 
    "hrsh7th/nvim-cmp", 
    dependencies = { 
      "neovim/nvim-lspconfig", 
      "hrsh7th/cmp-nvim-lsp", 
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",  -- cmp_luasnip
      "rafamadriz/friendly-snippets", -- friendly-snippets
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }),
      })
      -- LSP keymaps
      vim.keymap.set("n", "gd", vim.lsp.buf.definition)
      vim.keymap.set("n", "K", vim.lsp.buf.hover)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
    end
  },

  -- Status line
  { 
    "nvim-lualine/lualine.nvim", 
    config = function()
      require("lualine").setup()
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
    config = function()
      local mark = require("harpoon.mark")
      local ui = require("harpoon.ui")
      vim.keymap.set("n", "<leader>ha", mark.add_file)
      vim.keymap.set("n", "<leader>hh", ui.toggle_quick_menu)
      vim.keymap.set("n", "<leader>hn", ui.nav_next)
      vim.keymap.set("n", "<leader>hp", ui.nav_prev)
    end
  },

  -- LSP Management
  { 
    "williamboman/mason.nvim", 
    config = function()
      require("mason").setup()
    end
  },
  { 
    "williamboman/mason-lspconfig.nvim", 
    dependencies = { "mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "ts_ls", "pyright" },
      })
    end
  },

  -- Oil.nvim (file explorer)
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
})

-- Optional: Additional custom settings for the editor or keybindings (if needed)


-- Keybindings
vim.g.mapleader = ' '
local map = vim.keymap.set
map('n', '<leader>f', '<cmd>Pick files<cr>')
map('n', '<leader>g', '<cmd>Pick grep_live<cr>')
map('n', '<leader>b', '<cmd>Pick buffers<cr>')
map('n', '<leader>e', '<cmd>Oil<cr>')
map('n', '<leader>m', '<cmd>lua require("harpoon.mark").add_file()<cr>')
map('n', '<leader><leader>', '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>')
map('n', '<leader>lm', '<cmd>Mason<cr>')
map('n', '<leader>li', '<cmd>LspInfo<cr>')
map('n', '1', '<cmd>lua require("harpoon.ui").nav_file(1)<cr>')
map('n', '2', '<cmd>lua require("harpoon.ui").nav_file(2)<cr>')
map('n', '3', '<cmd>lua require("harpoon.ui").nav_file(3)<cr>')
map('n', '4', '<cmd>lua require("harpoon.ui").nav_file(4)<cr>')



vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})
