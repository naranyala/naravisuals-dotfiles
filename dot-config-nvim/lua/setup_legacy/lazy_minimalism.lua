-- ~/.config/nvim/init.lua
-- Minimalist Neovim config - Essential plugins only

-- Set leader key before lazy
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Core settings - carefully chosen defaults
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.cursorline = true
vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.list = true
vim.opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }

-- Plugin specifications - Only the essentials
require("lazy").setup({
  -- Colorscheme - Clean and minimal
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        styles = {
          comments = { italic = true },
          keywords = { italic = false },
          sidebars = "dark",
          floats = "dark",
        },
      })
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },

  -- Fuzzy finder - Core navigation tool
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>f", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>g", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>b", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>h", "<cmd>Telescope help_tags<cr>", desc = "Help" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = { prompt_position = "top" },
          sorting_strategy = "ascending",
        },
      })
    end,
  },

  -- Treesitter - Essential for syntax
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "vimdoc", "python", "javascript", "typescript", "rust", "go", "markdown" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

 -- LSP with Mason (modern vim.lsp.config API)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "folke/neodev.nvim",
      "nvimdev/lspsaga.nvim",
    },
    config = function()
      require("neodev").setup()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright", "ts_ls", "rust_analyzer" },
      })

      require("lspsaga").setup({
        ui = { border = "rounded" },
        symbol_in_winbar = { enable = true },
        lightbulb = { enable = false },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<cr>", opts)
          vim.keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<cr>", opts)
          vim.keymap.set("n", "gr", "<cmd>Lspsaga finder<cr>", opts)
          vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<cr>", opts)
          vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<cr>", opts)
          vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<cr>", opts)
          vim.keymap.set("n", "<leader>o", "<cmd>Lspsaga outline<cr>", opts)
          vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)
        end,
      })

      -- Modern API: Use vim.lsp.config for Neovim 0.11+
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        pyright = {},
        ts_ls = {},
        rust_analyzer = {},
      }

      for server, config in pairs(servers) do
        if vim.fn.has("nvim-0.11") == 1 then
          if not vim.tbl_isempty(config) then
            vim.lsp.config(server, config)
          end
          vim.lsp.enable(server)
        else
          local lspconfig = require("lspconfig")
          lspconfig[server].setup(config)
        end
      end
    end,
  },

  -- Completion - Simple and effective
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
      })
    end,
  },

  -- Git signs - Minimal git integration
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
      })
    end,
  },

  -- Auto pairs - Just the basics
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },


  -- Oil.nvim (alternative to neo-tree/nvim-tree)
  {
    "stevearc/oil.nvim",
    dependencies = {
      -- "nvim-tree/nvim-web-devicons"

    },
    keys = {
      { "<leader>e", "<cmd>Oil<cr>", desc = "Open file explorer" },
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
    config = function()
      require("oil").setup({
        columns = { "icon" },
        view_options = { show_hidden = true },
        float = { padding = 10 },
        keymaps = {
          ["<C-h>"] = false,
          ["<C-l>"] = false,
          ["<C-s>"] = "actions.select_split",
          ["<C-v>"] = "actions.select_vsplit",
        },
      })
    end,
  },

  -- Comment - Simple commenting
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },


  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      -- "nvim-tree/nvim-web-devicons"
    },
    config = function()
      local function file_stats()
        local buf = vim.api.nvim_get_current_buf()
        if vim.api.nvim_buf_get_option(buf, "buftype") ~= "" then
          return "" -- Skip for non-file buffers
        end

        -- Line count
        local lines = vim.api.nvim_buf_line_count(buf)

        -- Word count
        local words = 0
        local content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        for _, line in ipairs(content) do
          for _ in line:gmatch("%S+") do
            words = words + 1
          end
        end

        -- Character count
        local chars = #table.concat(content, "")

        return string.format("lines %d | words %d | chars %d", lines, words, chars)
      end

      require("lualine").setup({
        options = {
          theme = "auto",
          component_separators = "",
          section_separators = "",
          disabled_filetypes = {},
          globalstatus = true,
        },
        sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            {
              "filename",
              path = 2, -- 2 = absolute path
              symbols = {
                modified = "[+]",
                readonly = "[-]",
                unnamed = "[No Name]",
              },
            },
          },
          lualine_x = {},
          lualine_y = {},
          lualine_z = {
            { file_stats },
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            {
              "filename",
              path = 2, -- Absolute path for inactive buffers too
            },
          },
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        extensions = {},
      })
    end,
  },


  -- Mini.nvim - Lightweight utilities
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      -- Surround text objects
      require("mini.surround").setup()

      -- Better statusline (replaces lualine)
      -- local statusline = require("mini.statusline")
      -- statusline.setup({ use_icons = true })

      -- File explorer (replaces nvim-tree/neo-tree)
      -- require("mini.files").setup()
      -- vim.keymap.set("n", "<leader>e", function()
        -- require("mini.files").open()
      -- end, { desc = "File explorer" })
    end,
  },
})

-- Essential keymaps - Keep it simple
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Buffer navigation
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>")
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>")

-- Move lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor centered
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Diagnostic navigation
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>D", vim.diagnostic.setloclist)

-- Quickfix navigation
vim.keymap.set("n", "[q", "<cmd>cprev<cr>")
vim.keymap.set("n", "]q", "<cmd>cnext<cr>")

-- Auto commands
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight on yank",
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Remove trailing whitespace",
  group = vim.api.nvim_create_augroup("trim_whitespace", { clear = true }),
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Disable builtin plugins we don't need
local disabled_built_ins = {
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "rrhelper",
  "spellfile_plugin",
  "matchit",
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end
