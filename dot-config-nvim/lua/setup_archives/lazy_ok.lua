-- ~/.config/nvim/init.lua

-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Configure plugins with lazy.nvim
require("lazy").setup({
  -- Mini.nvim collection (loaded immediately)
  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.basics").setup({ options = { extra_ui = true } })
      require("mini.statusline").setup({ use_icons = false })
      require("mini.comment").setup()
      require("mini.pairs").setup()
      require("mini.surround").setup()
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


  -- File picker (replacing mini.pick)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      vim.keymap.set("n", "<leader>f", "<cmd>Telescope find_files<cr>")
      vim.keymap.set("n", "<leader>g", "<cmd>Telescope live_grep<cr>")
      vim.keymap.set("n", "<leader>b", "<cmd>Telescope buffers<cr>")
    end
  },

  -- Completion stack
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path"
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = {
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" }
        }
      })
    end
  },

  -- LSP and treesitter
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- local lsp_servers = { "lua_ls", "pyright", "rust_analyzer", "ts_ls" } -- Note: changed 'ts_ls' to 'tsserver'
      local lsp_servers = { "pyright", "rust_analyzer", "ts_ls" } -- Note: changed 'ts_ls' to 'tsserver'
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      for _, server in ipairs(lsp_servers) do
        require("lspconfig")[server].setup({ capabilities = capabilities })
      end
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true }
      })
    end
  },

  -- File management (oil.nvim and harpoon)
  {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup({ float = { padding = 4 } })
    end
  },
  {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("harpoon").setup()
      vim.keymap.set("n", "<leader>m", '<cmd>lua require("harpoon.mark").add_file()<cr>')
      vim.keymap.set("n", "<leader><leader>", '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>')
      for i = 1, 4 do
        vim.keymap.set("n", "<leader>" .. i, '<cmd>lua require("harpoon.ui").nav_file(' .. i .. ')<cr>')
      end
    end
  }
})

-- Basic settings (previously in mini.basics)
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>")


vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})
