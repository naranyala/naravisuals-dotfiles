-- init.lua
-- Enhanced tpope-stack with robust error handling and optimizations

-- === Bootstrap lazy.nvim ===
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- === Core Options (set before plugins) ===
vim.g.mapleader = " "
vim.g.maplocalleader = ","

local opt = vim.opt
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.ignorecase = true
opt.smartcase = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.signcolumn = "yes"
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.undolevels = 10000
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.cursorline = true
opt.mouse = "a"
opt.completeopt = "menu,menuone,noselect"
opt.pumheight = 10
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

-- === Plugin Setup ===
require("lazy").setup({
  -- === Tpope Essentials ===
  { "tpope/vim-sensible" },
  {
    "tpope/vim-surround",
    keys = { "ys", "cs", "ds", { "S", mode = "v" } },
  },
  { "tpope/vim-repeat", event = "VeryLazy" },
  { "tpope/vim-commentary", keys = { "gc", { "gc", mode = "v" } } },
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
      { "<leader>gc", "<cmd>Git commit<cr>", desc = "Git commit" },
      { "<leader>gp", "<cmd>Git push<cr>", desc = "Git push" },
      { "<leader>gl", "<cmd>Git pull<cr>", desc = "Git pull" },
    },
  },
  { "tpope/vim-rhubarb", dependencies = "tpope/vim-fugitive" },
  { "tpope/vim-eunuch", cmd = { "Remove", "Delete", "Move", "Chmod", "Mkdir", "SudoWrite" } },
  { "tpope/vim-unimpaired", event = "VeryLazy" },
  { "tpope/vim-abolish", cmd = { "Abolish", "Subvert" } },
  { "tpope/vim-dispatch", cmd = { "Dispatch", "Make", "Focus", "Start" } },
  { "tpope/vim-endwise", event = "InsertEnter" },
  { "tpope/vim-speeddating", keys = { "<C-a>", "<C-x>" } },
  { "tpope/vim-sleuth" }, -- Auto-detect indentation

  -- === Treesitter ===
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "vimdoc", "python", "javascript", "typescript", "bash", "markdown" },
        auto_install = true,
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
        },
      })
    end,
  },

  -- === LSP ===
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      { "folke/neodev.nvim", opts = {} },
    },
    config = function()
      require("mason").setup({ ui = { border = "rounded" } })
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright", "ts_ls", "rust_analyzer" },
        automatic_installation = true,
      })

      local on_attach = function(_, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
        end
        map("gd", vim.lsp.buf.definition, "Goto Definition")
        map("gr", vim.lsp.buf.references, "Goto References")
        map("gI", vim.lsp.buf.implementation, "Goto Implementation")
        map("K", vim.lsp.buf.hover, "Hover Documentation")
        map("<leader>rn", vim.lsp.buf.rename, "Rename")
        map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
        map("gD", vim.lsp.buf.declaration, "Goto Declaration")
      end

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local servers = { "lua_ls", "pyright", "ts_ls", "rust_analyzer" }

      for _, lsp in ipairs(servers) do
        require("lspconfig")[lsp].setup({
          on_attach = on_attach,
          capabilities = capabilities,
          settings = lsp == "lua_ls" and {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            }
          } or {},
        })
      end

      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded" },
      })
    end,
  },

  -- === Mason (LSP installer) ===
  { "williamboman/mason.nvim", cmd = "Mason", build = ":MasonUpdate" },
  { "williamboman/mason-lspconfig.nvim" },

  -- === Completion ===
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "path", priority = 500 },
        }, {
          { name = "buffer", priority = 250, keyword_length = 3 },
        }),
        formatting = {
          format = function(_, item)
            local icons = {
              Text = "󰉿", Method = "󰆧", Function = "󰊕", Constructor = "",
              Field = "󰜢", Variable = "󰀫", Class = "󰠱", Interface = "",
              Module = "", Property = "󰜢", Unit = "󰑭", Value = "󰎠",
              Enum = "", Keyword = "󰌋", Snippet = "", Color = "󰏘",
              File = "󰈙", Reference = "󰈇", Folder = "󰉋", EnumMember = "",
              Constant = "󰏿", Struct = "󰙅", Event = "", Operator = "󰆕",
              TypeParameter = "",
            }
            item.kind = string.format("%s %s", icons[item.kind] or "", item.kind)
            return item
          end,
        },
      })
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

  -- === UI Enhancements ===
  -- {
  --   "nvim-lualine/lualine.nvim",
  --   event = "VeryLazy",
  --   opts = {
  --     options = {
  --       theme = "tokyonight",
  --       component_separators = "|",
  --       section_separators = "",
  --       globalstatus = true,
  --     },
  --     sections = {
  --       lualine_a = { "mode" },
  --       lualine_b = { "branch", "diff", "diagnostics" },
  --       lualine_c = { { "filename", path = 1 } },
  --       lualine_x = { "encoding", "fileformat", "filetype" },
  --       lualine_y = { "progress" },
  --       lualine_z = { "location" },
  --     },
  --   },
  -- },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({ style = "night", transparent = false })
      vim.cmd.colorscheme("tokyonight")
    end,
  },
  -- {
  --   "rcarriga/nvim-notify",
  --   keys = {
  --     { "<leader>un", function() require("notify").dismiss({ silent = true, pending = true }) end, desc = "Dismiss notifications" },
  --   },
  --   opts = {
  --     timeout = 3000,
  --     max_height = function() return math.floor(vim.o.lines * 0.75) end,
  --     max_width = function() return math.floor(vim.o.columns * 0.75) end,
  --   },
  --   init = function()
  --     vim.notify = require("notify")
  --   end,
  -- },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        map("n", "]h", gs.next_hunk, "Next Hunk")
        map("n", "[h", gs.prev_hunk, "Prev Hunk")
        map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame Line")
      end,
    },
  },
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    opts = { detection_methods = { "pattern" }, patterns = { ".git" } },
    config = function(_, opts)
      require("project_nvim").setup(opts)
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
      window = { border = "rounded" },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register({
        ["<leader>g"] = { name = "+git" },
        ["<leader>h"] = { name = "+hunks" },
        ["<leader>r"] = { name = "+refactor" },
        ["<leader>c"] = { name = "+code" },
        ["<leader>u"] = { name = "+ui" },
      })
    end,
  },
  { "numToStr/Comment.nvim", event = "VeryLazy", opts = {} },
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- === Fuzzy Finder ===
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
    },
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-u>"] = false,
            ["<C-d>"] = false,
          },
        },
      },
    },
  },


  -- File explorer with oil.nvim
  {
    "stevearc/oil.nvim",
    dependencies = {
      -- "nvim-tree/nvim-web-devicons"
    },
    opts = {
      default_file_explorer = true, -- Replace netrw
      columns = { },         -- Show file icons
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["-"] = "actions.parent",
        ["g."] = "actions.toggle_hidden",
      },
      use_default_keymaps = true,
      view_options = { show_hidden = true }, -- Show hidden files by default
    },
    config = function(_, opts)
      require("oil").setup(opts)

	vim.api.nvim_set_keymap('n', '<leader>e', ':Oil<CR>', { noremap = true })
    end
  },

{
    'nvimdev/lspsaga.nvim',
    config = function()
        require('lspsaga').setup({})
    end,
    dependencies = {
        'nvim-treesitter/nvim-treesitter', -- optional
        'nvim-tree/nvim-web-devicons',     -- optional
    }
},
  {'lewis6991/satellite.nvim', config = function() 
    require('satellite').setup()
  end },{
    'lewis6991/hover.nvim', config = function()
require('hover').config({
  providers = {
    {
      module = 'hover.providers.diagnostic',
      priority = 2000,
      name = 'Diags'
    }
  }
})
    end
  }

  -- File management reimagined
  -- {
  --   "nvim-neo-tree/neo-tree.nvim",
  --   branch = "v3.x",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-tree/nvim-web-devicons",
  --     "MunifTanjim/nui.nvim",
  --   },
  --   config = function()
  --     require("neo-tree").setup({
  --       close_if_last_window = true,
  --       window = { width = 30 },
  --       filesystem = { filtered_items = { visible = true } }
  --     })
  --     vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>")
  --   end
  -- },

  -- end of plugins
}, {
  ui = { border = "rounded" },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})

-- === Additional Keymaps ===
local map = vim.keymap.set

-- Better window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move lines
map("n", "<A-j>", ":m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", ":m .-2<cr>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Better paste
map("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Diagnostic keymaps
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic quickfix" })

-- === Autocommands ===
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Auto-create directories when saving
autocmd("BufWritePre", {
  group = augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Close some filetypes with <q>
autocmd("FileType", {
  group = augroup("close_with_q", { clear = true }),
  pattern = { "help", "lspinfo", "man", "qf", "notify" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    map("n", "q", "<cmd>close<cr>", { buffer = event.buf, desc = "Quit buffer" })
  end,
})

-- Show cursor line only in active window
autocmd({ "InsertLeave", "WinEnter" }, {
  group = augroup("auto_cursorline", { clear = true }),
  callback = function()
    if vim.bo.filetype ~= "alpha" then
      vim.opt.cursorline = true
    end
  end,
})
autocmd({ "InsertEnter", "WinLeave" }, {
  group = augroup("auto_cursorline", {}),
  callback = function() vim.opt.cursorline = false end,
})
