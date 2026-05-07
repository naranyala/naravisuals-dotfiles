-- ~/.config/nvim/init.lua

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.loop or vim.uv).fs_stat(lazypath) then
  if vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
        "https://github.com/folke/lazy.nvim.git", lazypath }) ~= 0 then
    error("Failed to clone lazy.nvim")
  end
end
vim.opt.rtp:prepend(lazypath)

-- Core settings
vim.g.mapleader, vim.g.maplocalleader = " ", "\\"
local opt = vim.opt
opt.number, opt.relativenumber = true, true
opt.tabstop, opt.shiftwidth, opt.expandtab = 2, 2, true
opt.smartindent, opt.cursorline, opt.signcolumn = true, true, "yes"
opt.ignorecase, opt.smartcase, opt.hlsearch = true, true, true
opt.splitright, opt.splitbelow = true, true
opt.scrolloff, opt.updatetime = 5, 200
opt.wrap, opt.termguicolors = false, true
opt.hidden, opt.undofile = true, true
opt.completeopt = "menu,menuone,noselect"
opt.colorcolumn = "80"

-- Helper function
local map = function(m, l, r, d) vim.keymap.set(m, l, r, { desc = d, silent = true }) end

-- Essential keymaps
map("n", "<leader>w", ":w<CR>", "Save")
map("n", "<leader>q", ":q<CR>", "Quit")
map("n", "<Esc>", ":noh<CR>", "Clear search")
map("n", "<S-h>", ":bp<CR>", "Prev buffer")
map("n", "<S-l>", ":bn<CR>", "Next buffer")
map("n", "<leader>bd", ":bd<CR>", "Delete buffer")

-- Window navigation
map("n", "<C-h>", "<C-w>h", "Left window")
map("n", "<C-j>", "<C-w>j", "Bottom window")
map("n", "<C-k>", "<C-w>k", "Top window")
map("n", "<C-l>", "<C-w>l", "Right window")

-- Toggles
map("n", "<leader>rn", function() opt.relativenumber = not opt.relativenumber:get() end, "Toggle relative numbers")
map("n", "<leader>rs", function() vim.cmd("source $MYVIMRC") end, "Reload config")

-- Dune commands
local dune = function(cmd) return function() vim.cmd("vsplit | term " .. cmd) end end
map("n", "<leader>db", dune("dune build"), "Dune build")
map("n", "<leader>dr", dune("dune exec " .. vim.fn.expand("%")), "Run file")
map("n", "<leader>dt", dune("dune runtest"), "Run tests")

-- Plugin setup
require("lazy").setup({
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufRead", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "ocaml", "lua", "json" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },

  -- LSP
  { "williamboman/mason.nvim", cmd = "Mason",                          opts = {} },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = "mason.nvim",
    opts = { ensure_installed = { "ocamllsp", "lua_ls" } }
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-lspconfig.nvim", "cmp-nvim-lsp" },
    config = function()
      local lsp = require("lspconfig")
      local cap = require("cmp_nvim_lsp").default_capabilities()

      lsp.ocamllsp.setup({
        capabilities = cap,
        filetypes = { "ocaml", "ocaml.interface", "reason", "dune" },
        root_dir = lsp.util.root_pattern("*.opam", "dune-project", ".git")
      })

      lsp.lua_ls.setup({
        capabilities = cap,
        settings = { Lua = { diagnostics = { globals = { "vim" } } } }
      })
    end
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip", "rafamadriz/friendly-snippets"
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
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
        sources = { { name = "nvim_lsp" }, { name = "luasnip" }, { name = "path" }, { name = "buffer" } },
      })
    end
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = {
      formatters_by_ft = { ocaml = { "ocamlformat" }, lua = { "stylua" } },
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
    }
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local function file_stats()
        local buf = vim.api.nvim_get_current_buf()
        if vim.api.nvim_buf_get_option(buf, 'buftype') ~= '' then
          return '' -- Skip for non-file buffers
        end

        -- Line count
        local lines = vim.api.nvim_buf_line_count(buf)

        -- Word count
        local words = 0
        local content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        for _, line in ipairs(content) do
          for _ in line:gmatch('%S+') do
            words = words + 1
          end
        end

        -- Character count
        local chars = #table.concat(content, '')

        return string.format('lines %d | words %d | chars %d', lines, words, chars)
      end

      require('lualine').setup({
        options = {
          theme = 'auto',
          component_separators = '',
          section_separators = '',
          disabled_filetypes = {},
          globalstatus = true,
        },
        sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            {
              'filename',
              path = 2, -- 2 = absolute path
              symbols = {
                modified = '[+]',
                readonly = '[-]',
                unnamed = '[No Name]',
              }
            }
          },
          lualine_x = {},
          lualine_y = {},
          lualine_z = {
            { file_stats }
          }
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            {
              'filename',
              path = 2, -- Absolute path for inactive buffers too
            }
          },
          lualine_x = {},
          lualine_y = {},
          lualine_z = {}
        },
        extensions = {}
      })
    end,
  },
  { "lewis6991/gitsigns.nvim", event = { "BufReadPre", "BufNewFile" }, opts = {} },

  -- File explorer with oil.nvim
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      default_file_explorer = true, -- Replace netrw
      columns = { "icon" },         -- Show file icons
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
      -- Keymaps for oil.nvim
      map("n", "<leader>e", ":Oil<CR>", "Open oil file explorer")
      map("n", "<leader>E", function() require("oil").open(vim.fn.expand("%:p:h")) end, "Open oil in current dir")
    end
  },

  -- File switching with harpoon
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      -- Keymaps for harpoon
      map("n", "<leader>a", function() harpoon:list():add() end, "Add file to harpoon")
      map("n", "<leader><leader>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, "Toggle harpoon menu")
      for i = 1, 9 do
        map("n", tostring(i), function() harpoon:list():select(i) end, "Go to harpoon file " .. i)
      end
    end
  },

  -- Welcome screen with oil.nvim and harpoon guide
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- Remove header
      dashboard.section.header.val = {}

      -- Remove buttons
      dashboard.section.buttons.val = {}

      -- Oil.nvim and harpoon usage guide
      dashboard.section.footer.val = {
        "                                                     ",
        "🗂️  File Navigation Guide (oil.nvim & harpoon):     ",
        "                                                     ",
        "   oil.nvim (File Explorer):                         ",
        "   • <Space>e       - Open explorer in cwd            ",
        "   • <Space>E       - Open explorer in current dir    ",
        "   • <CR>           - Open file/directory             ",
        "   • -              - Go to parent directory          ",
        "   • g.             - Toggle hidden files             ",
        "   • g?             - Show help                       ",
        "   • Edit buffer    - Create/rename/delete files      ",
        "                                                     ",
        "   harpoon (Quick File Switching):                   ",
        "   • <Space>a       - Add file to harpoon list        ",
        "   • <Space><Space> - Toggle harpoon menu            ",
        "   • 1              - Go to 1st marked file          ",
        "   • 2              - Go to 2nd marked file          ",
        "   • ...                                      ",
        "   • 9              - Go to 9th marked file          ",
        "                                                     ",
        "   Press <Space>e to start browsing files...        ",
        "                                                     ",
      }

      alpha.setup(dashboard.opts)
    end
  },

  -- Tools
  {
    "nvim-telescope/telescope.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    keys = {
      { "<leader>ff", ":Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", ":Telescope live_grep<CR>",  desc = "Live grep" },
      { "<leader>fb", ":Telescope buffers<CR>",    desc = "Buffers" },
    }
  },
  { "akinsho/toggleterm.nvim", keys = "<C-\\>", opts = { open_mapping = "<C-\\>" } },
}, {
  install = { colorscheme = { "habamax" } },
  performance = {
    rtp = { disabled_plugins = { "gzip", "netrwPlugin", "tarPlugin", "zipPlugin" } }
  }
})

-- Autocommands
local au = vim.api.nvim_create_autocmd
local ag = vim.api.nvim_create_augroup

-- Disable alpha for non-empty buffers or when files are passed
au({ "User" }, {
  pattern = "AlphaReady",
  callback = function()
    if vim.fn.argc() > 0 then
      require("alpha").start(false, require("alpha").default_config)
      vim.cmd("bd")
    end
  end
})

-- Highlight yank
au("TextYankPost", {
  group = ag("YankHL", { clear = true }),
  callback = function() vim.highlight.on_yank({ timeout = 200 }) end
})

-- Trim whitespace
au("BufWritePre", {
  group = ag("TrimWS", { clear = true }),
  pattern = "*.{ml,mli,lua,py,rs}",
  callback = function()
    local pos = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", pos)
  end
})

-- Restore cursor
au("BufReadPost", {
  group = ag("RestoreCursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end
})

-- Ensure TreeSitter highlighting for files opened via oil.nvim or harpoon
au({ "BufEnter" }, {
  pattern = { "*.ml", "*.mli", "*.lua", "*.json" },
  callback = function()
    vim.api.nvim_command("doautocmd BufReadPost")
    vim.api.nvim_command("TSBufEnable highlight")
  end,
})

-- LSP keymaps
au("LspAttach", {
  callback = function(args)
    local bmap = function(m, l, r, d) vim.keymap.set(m, l, r, { buffer = args.buf, desc = d }) end
    bmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
    bmap("n", "gr", vim.lsp.buf.references, "References")
    bmap("n", "K", vim.lsp.buf.hover, "Hover docs")
    bmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
    bmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code actions")
    bmap("n", "<leader>f", function() require("conform").format({ async = true }) end, "Format")
    bmap("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
    bmap("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
  end
})

-- Diagnostic config
vim.diagnostic.config({
  virtual_text = { prefix = "●" },
  signs = true,
  underline = true,
  float = { border = "rounded" }
})
