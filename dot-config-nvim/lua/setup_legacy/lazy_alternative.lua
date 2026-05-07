-- ~/.config/nvim/init.lua
-- Alternative advanced config with different plugin choices

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

-- Core settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.undofile = true
vim.opt.scrolloff = 8
vim.opt.cursorline = true
vim.opt.clipboard = "unnamedplus"

-- Plugin specifications
require("lazy").setup({
  -- Catppuccin colorscheme (alternative to tokyonight)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        integrations = {
          cmp = true,
          gitsigns = true,
          treesitter = true,
          notify = true,
          mini = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },


  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        window = { border = "rounded" },
      })
    end,
  },

  -- FZF-lua (alternative to Telescope)
  {
    "ibhagwan/fzf-lua",
    dependencies = {
      -- "nvim-tree/nvim-web-devicons"
    },
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help tags" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
      { "<leader>fc", "<cmd>FzfLua commands<cr>", desc = "Commands" },
      { "<leader>fd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Diagnostics" },
    },
    config = function()
      require("fzf-lua").setup({
        winopts = { height = 0.9, width = 0.9 },
      })
    end,
  },

  -- Treesitter (essential - not replaceable)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "windwp/nvim-ts-autotag",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "vimdoc", "python", "javascript", "typescript", "rust", "go", "json", "yaml", "markdown", "html", "css" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        autotag = { enable = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
            goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
          },
        },
      })
    end,
  },

  -- LSP with Mason (essential - not replaceable)
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
        ensure_installed = { "lua_ls", "pyright", "ts_ls", "rust_analyzer", "gopls" },
      })

      require("lspsaga").setup({
        ui = { border = "rounded" },
        symbol_in_winbar = { enable = true },
        lightbulb = { enable = false },
      })

      local lspconfig = require("lspconfig")
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr }
        vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<cr>", opts)
        vim.keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<cr>", opts)
        vim.keymap.set("n", "gr", "<cmd>Lspsaga finder<cr>", opts)
        vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<cr>", opts)
        vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<cr>", opts)
        vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<cr>", opts)
        vim.keymap.set("n", "<leader>o", "<cmd>Lspsaga outline<cr>", opts)
        vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)
      end

      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = { Lua = { diagnostics = { globals = { "vim" } }, workspace = { checkThirdParty = false }, telemetry = { enable = false } } },
      })
      lspconfig.pyright.setup({ capabilities = capabilities, on_attach = on_attach })
      lspconfig.ts_ls.setup({ capabilities = capabilities, on_attach = on_attach })
      lspconfig.rust_analyzer.setup({ capabilities = capabilities, on_attach = on_attach })
      lspconfig.gopls.setup({ capabilities = capabilities, on_attach = on_attach })
    end,
  },

  -- Coq_nvim (alternative to nvim-cmp)
  {
    "ms-jpq/coq_nvim",
    branch = "coq",
    build = ":COQdeps",
    dependencies = {
      { "ms-jpq/coq.artifacts", branch = "artifacts" },
      { "ms-jpq/coq.thirdparty", branch = "3p" },
    },
    init = function()
      vim.g.coq_settings = {
        auto_start = "shut-up",
        keymap = { recommended = true },
        display = { icons = { mode = "short" } },
      }
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


  -- Barbar (alternative to bufferline)
  {
    "romgrk/barbar.nvim",
    diabled = true,
    dependencies = {
      -- "nvim-tree/nvim-web-devicons"

    },
    config = function()
      require("barbar").setup({
        animation = true,
        auto_hide = false,
        icons = { button = "", separator = { left = "▎" } },
      })
    end,
  },

  -- Diffview (alternative to gitsigns for git diff)
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open diffview" },
      { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "File history" },
      { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
    },
  },

  -- Gitsigns (still useful for inline git info)
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          vim.keymap.set("n", "]c", gs.next_hunk, { buffer = bufnr })
          vim.keymap.set("n", "[c", gs.prev_hunk, { buffer = bufnr })
          vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { buffer = bufnr })
          vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { buffer = bufnr })
          vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { buffer = bufnr })
          vim.keymap.set("n", "<leader>gb", gs.blame_line, { buffer = bufnr })
        end,
      })
    end,
  },

  -- Neogit (alternative to lazygit)
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Git commit" },
    },
    config = true,
  },

  -- Ultimate-autopair (alternative to nvim-autopairs)
  {
    "altermo/ultimate-autopair.nvim",
    event = { "InsertEnter", "CmdlineEnter" },
    config = function()
      require("ultimate-autopair").setup()
    end,
  },

  -- Mini.comment (alternative to Comment.nvim)
  {
    "echasnovski/mini.comment",
    version = false,
    config = function()
      require("mini.comment").setup()
    end,
  },

  -- Leap.nvim (alternative to Flash)
  {
    "ggandor/leap.nvim",
    dependencies = { "tpope/vim-repeat" },
    config = function()
      require("leap").add_default_mappings()
    end,
  },

  -- Legendary.nvim (alternative to which-key)
  {
    "mrjones2014/legendary.nvim",
    priority = 10000,
    lazy = false,
    keys = {
      { "<leader>?", "<cmd>Legendary<cr>", desc = "Legendary" },
    },
    config = function()
      require("legendary").setup({ extensions = { lazy_nvim = true } })
    end,
  },

  -- Mini.indentscope (alternative to indent-blankline)
  {
    "echasnovski/mini.indentscope",
    version = false,
    event = "BufReadPre",
    config = function()
      require("mini.indentscope").setup({
        symbol = "│",
        draw = { animation = require("mini.indentscope").gen_animation.none() },
      })
    end,
  },

  -- Aerial (alternative to trouble for symbols)
  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter",
      -- "nvim-tree/nvim-web-devicons"

    },
    keys = {
      { "<leader>a", "<cmd>AerialToggle!<cr>", desc = "Aerial symbols" },
    },
    config = function()
      require("aerial").setup({
        on_attach = function(bufnr)
          vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = barfnr })
          vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end,
      })
    end,
  },

  -- Fidget (LSP progress)
  {
    "j-hui/fidget.nvim",
    config = function()
      require("fidget").setup()
    end,
  },

  -- Mini.notify (alternative to nvim-notify)
  {
    "echasnovski/mini.notify",
    version = false,
    config = function()
      require("mini.notify").setup()
      vim.notify = require("mini.notify").make_notify()
    end,
  },

  -- Vim-mundo (alternative to undotree)
  {
    "simnalamburt/vim-mundo",
    keys = {
      { "<leader>u", "<cmd>MundoToggle<cr>", desc = "Mundo undo tree" },
    },
  },

  -- Dressing.nvim - Better UI for vim.ui.select and vim.ui.input
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    config = true,
  },

  -- Yanky - Better yank history
  {
    "gbprod/yanky.nvim",
    keys = {
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" } },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" } },
      { "<c-n>", "<Plug>(YankyCycleForward)", desc = "Cycle yank forward" },
      { "<c-p>", "<Plug>(YankyCycleBackward)", desc = "Cycle yank backward" },
      { "<leader>y", "<cmd>FzfLua registers<cr>", desc = "Yank history" },
    },
    config = function()
      require("yanky").setup({
        ring = { history_length = 100 },
        highlight = { timer = 150 },
      })
    end,
  },

  -- Nvim-colorizer (color preview)
  {
    "norcalli/nvim-colorizer.lua",
    event = "BufReadPre",
    config = function()
      require("colorizer").setup()
    end,
  },

  -- Mini.animate (alternative to neoscroll)
  {
    "echasnovski/mini.animate",
    version = false,
    config = function()
      require("mini.animate").setup({
        scroll = { enable = true },
        cursor = { enable = false },
      })
    end,
  },

  -- Vim-matchup (enhanced % matching)
  {
    "andymass/vim-matchup",
    event = "BufReadPost",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },

  -- Nvim-spectre (find and replace)
  {
    "nvim-pack/nvim-spectre",
    keys = {
      { "<leader>sr", '<cmd>lua require("spectre").open()<cr>', desc = "Find and replace" },
      { "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<cr>', desc = "Search current word" },
    },
    config = true,
  },

  -- Ranger.vim (file manager integration)
  {
    "kevinhwang91/rnvimr",
    keys = {
      { "<leader>r", "<cmd>RnvimrToggle<cr>", desc = "Ranger" },
    },
  },

  -- Zen-mode (distraction-free writing)
  {
    "folke/zen-mode.nvim",
    keys = {
      { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen mode" },
    },
    config = function()
      require("zen-mode").setup({
        window = { width = 100 },
      })
    end,
  },

  -- Symbols-outline replacement with better features
  {
    "simrat39/symbols-outline.nvim",
    keys = {
      { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols outline" },
    },
    config = true,
  },

  -- Marks.nvim - Better marks visualization
  {
    "chentoast/marks.nvim",
    event = "VeryLazy",
    config = true,
  },

  -- Nvim-bqf - Better quickfix window
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
  },

  -- Twilight - Dim inactive portions of code
  {
    "folke/twilight.nvim",
    keys = {
      { "<leader>tw", "<cmd>Twilight<cr>", desc = "Twilight" },
    },
    config = true,
  },

  -- Nvim-various-textobjs - More text objects
  {
    "chrisgrieser/nvim-various-textobjs",
    event = "VeryLazy",
    config = function()
      require("various-textobjs").setup({ useDefaultKeymaps = true })
    end,
  },
})

-- Additional keymaps
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Buffer navigation with barbar
vim.keymap.set("n", "<S-l>", "<cmd>BufferNext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-h>", "<cmd>BufferPrevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>BufferClose<cr>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>BufferPin<cr>", { desc = "Pin buffer" })

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- Move lines in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered when scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Auto commands
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight on yank",
  callback = function() vim.highlight.on_yank() end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Remove trailing whitespace on save",
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Terminal mode escape
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
