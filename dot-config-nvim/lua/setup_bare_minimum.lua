-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Single-File Neovim Config for C/Zig/C3 Systems Programming
-- Place in: ~/.config/nvim/init.lua
-- Requirements: Neovim ≥0.10
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- ============================================================================
-- BASIC SETTINGS
-- ============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.showmode = false
opt.cmdheight = 1
opt.pumheight = 10
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Editing
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.breakindent = true
opt.wrap = false

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Files
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300
opt.lazyredraw = true

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Completion
opt.completeopt = "menu,menuone,noselect"

-- ============================================================================
-- PLUGIN MANAGER (lazy.nvim)
-- ============================================================================
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

-- ============================================================================
-- PLUGINS
-- ============================================================================
require("lazy").setup({



    require("./_shared_other_modules"),
    -- require("./_shared_mason_lsp_treesitter"),

  -- Colorscheme
  -- {
  --   "folke/tokyonight.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("tokyonight").setup({
  --       style = "night",
  --       transparent = false,
  --       styles = {
  --         comments = { italic = true },
  --         keywords = { italic = true },
  --         functions = { bold = true },
  --       },
  --     })
  --     vim.cmd.colorscheme("tokyonight")
  --   end,
  -- },

  -- Treesitter: Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c", "cpp", "zig",
          "bash", "make", "cmake",
          "lua", "vim", "vimdoc",
          "diff", "git_rebase", "gitcommit",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })

      -- C3 external grammar
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.c3 = {
        install_info = {
          url = "https://github.com/c3lang/tree-sitter-c3",
          files = { "src/parser.c", "src/scanner.c" },
          branch = "main",
        },
        filetype = "c3",
      }

      -- Auto-install C3 parser
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "c3",
        once = true,
        callback = function()
          vim.cmd("TSInstall c3")
        end,
      })
    end,
  },

  -- LSP Installer
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = { border = "rounded" },
      })
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "zls" },
        automatic_installation = true,
      })
    end,
  },

  -- LSP Config
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- Diagnostics UI
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded" },
      })

      -- Diagnostic signs
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- LSP handlers with borders
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

      -- Capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      -- Keymaps on LSP attach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf, silent = true }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
          -- vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
        end,
      })

      -- C/C++ - clangd
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
        capabilities = capabilities,
      })

      -- Zig - zls
      vim.lsp.config("zls", {
        cmd = { "zls" },
        filetypes = { "zig" },
        root_markers = { "build.zig", ".git" },
        capabilities = capabilities,
      })

      -- C3 - c3lsp (manual install required)
      -- if vim.fn.executable("c3lsp") == 1 then
      --   vim.lsp.config("c3_lsp", {
      --     cmd = { "c3lsp", "--stdio" },
      --     filetypes = { "c3" },
      --     root_markers = { "project.json", ".git" },
      --     capabilities = capabilities,
      --   })
      -- end

      -- Auto-start LSP
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp", "zig", "c3" },
        callback = function()
          local ft = vim.bo.filetype
          local name = ft == "c3" and "c3_lsp" or ft
          vim.lsp.start({ name = name })
        end,
      })
    end,
  },

  -- Autocomplete
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
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
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },

  -- Fuzzy Finder
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "smart" },
        },
      })
    end,
  },

  -- File Explorer
  -- {
  --   "nvim-tree/nvim-tree.lua",
  --   cmd = "NvimTreeToggle",
  --   keys = {
  --     { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "File explorer" },
  --   },
  --   config = function()
  --     require("nvim-tree").setup({
  --       view = { width = 30 },
  --       renderer = { group_empty = true },
  --       filters = { dotfiles = false },
  --     })
  --   end,
  -- },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
          component_separators = "|",
          section_separators = "",
        },
      })
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
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

  -- Comment
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n", desc = "Comment line" },
      { "gc", mode = { "n", "v" }, desc = "Comment" },
    },
    config = function()
      require("Comment").setup()
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },
})

-- ============================================================================
-- KEYMAPS
-- ============================================================================
local map = vim.keymap.set

-- General
map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<leader>x", "<cmd>bd<CR>", { desc = "Close buffer" })

-- Better window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Resize windows
map("n", "<C-Up>", "<cmd>resize +2<CR>")
map("n", "<C-Down>", "<cmd>resize -2<CR>")
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>")
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>")

-- Buffer navigation
map("n", "<S-l>", "<cmd>bnext<CR>")
map("n", "<S-h>", "<cmd>bprevious<CR>")

-- Visual mode
map("v", "<", "<gv")
map("v", ">", ">gv")
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor centered
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- ============================================================================
-- AUTOCOMMANDS
-- ============================================================================

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.c", "*.h", "*.zig", "*.c3" },
  callback = function()
    vim.cmd([[%s/\s\+$//e]])
  end,
})

-- Set C3 filetype
vim.filetype.add({
  extension = { c3 = "c3", c3i = "c3", c3t = "c3" },
})

-- ============================================================================
-- COMPILE/BUILD SHORTCUTS
-- ============================================================================

-- Quick compile for C
map("n", "<F5>", function()
  local file = vim.fn.expand("%")
  local cmd = string.format("gcc -Wall -Wextra -g %s -o %s.out && ./%s.out",
    file, file:gsub("%.c$", ""), file:gsub("%.c$", ""))
  vim.cmd("!" .. cmd)
end, { desc = "Compile & run C" })

-- Zig build
map("n", "<F6>", "<cmd>!zig build run<CR>", { desc = "Zig build run" })

-- C3 compile
map("n", "<F7>", function()
  local file = vim.fn.expand("%")
  vim.cmd(string.format("!c3c compile %s && ./%s", file, file:gsub("%.c3$", "")))
end, { desc = "Compile & run C3" })



vim.keymap.set("n", "<leader>e", ":Oil", opts)
