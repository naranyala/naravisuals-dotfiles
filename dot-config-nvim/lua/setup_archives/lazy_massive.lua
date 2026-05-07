-- ~/.config/nvim/init.lua

-- Bootstrap lazy.nvim with a twist
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.notify("🚀 Installing lazy.nvim...")
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Cosmic settings that defy conventions
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.autochdir = true  -- Change directory to current file
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0    -- Same as tabstop
vim.opt.expandtab = true
vim.opt.breakindent = true
vim.opt.linebreak = true  -- Wrap at words
vim.opt.showbreak = "↪ "
vim.opt.list = true
vim.opt.listchars = {
  tab = "▸ ",
  trail = "·",
  nbsp = "␣",
  extends = "❯",
  precedes = "❮"
}

-- Plugin constellation
require("lazy").setup({
  -- UI Revolution
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
        integrations = {
          aerial = true,
          dap = { enabled = true, enable_ui = true },
          mason = true,
          neotree = true,
          telescope = true,
          which_key = true
        }
      })
      vim.cmd.colorscheme("catppuccin")
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
        automatic_installation = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },


  -- Revolutionary editing
  {
    "chrisgrieser/nvim-various-textobjs",
    config = function() require("various-textobjs").setup({ useDefaultKeymaps = true }) end
  },
  {
    "gbprod/substitute.nvim",
    config = function()
      require("substitute").setup({
        exchange = {
          motion = false,
          visual_mode = false,
        }
      })
      vim.keymap.set("n", "s", require("substitute").operator)
      vim.keymap.set("n", "ss", require("substitute").line)
      vim.keymap.set("x", "s", require("substitute").visual)
    end
  },
  {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function() require("treesj").setup() end
  },

  -- Unconventional navigation
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end },
    },
  },
  {
    "stevearc/aerial.nvim",
    config = function()
      require("aerial").setup({
        layout = { min_width = 28 },
        filter_kind = false,
        on_attach = function(bufnr)
          vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
          vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end
      })
      vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
    end
  },

  -- File management reimagined
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        window = { width = 30 },
        filesystem = { filtered_items = { visible = true } }
      })
      vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>")
    end
  },

  -- Fuzzy finding evolved
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "debugloop/telescope-undo.nvim",
      "nvim-telescope/telescope-live-grep-args.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local lga_actions = require("telescope-live-grep-args.actions")
      
      telescope.setup({
        defaults = { file_ignore_patterns = { "node_modules", ".git" } },
        extensions = {
          undo = { use_delta = false },
          live_grep_args = {
            auto_quoting = true,
            mappings = {
              i = { ["<C-k>"] = lga_actions.quote_prompt() }
            }
          }
        }
      })
      
      telescope.load_extension("undo")
      telescope.load_extension("live_grep_args")
      
      vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
      vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep_args<cr>")
      vim.keymap.set("n", "<leader>fu", "<cmd>Telescope undo<cr>")
    end
  },

  -- LSP & AI-powered coding
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v2.x",
    dependencies = {
      -- LSP
      {"neovim/nvim-lspconfig"},
      {"williamboman/mason.nvim"},
      {"williamboman/mason-lspconfig.nvim"},
      
      -- Autocompletion
      {"hrsh7th/nvim-cmp"},
      {"hrsh7th/cmp-nvim-lsp"},
      {"hrsh7th/cmp-buffer"},
      {"hrsh7th/cmp-path"},
      {"L3MON4D3/LuaSnip"},
      
      -- AI
      {"Exafunction/codeium.nvim"},
    },
    config = function()
      local lsp = require("lsp-zero").preset({
        name = "recommended",
        set_lsp_keymaps = { omit = {"K"} },  -- We'll use noice for hover
        manage_nvim_cmp = {
          set_sources = "recommended",
          set_basic_mappings = true,
          set_extra_mappings = false,
        }
      })
      
      lsp.on_attach(function(client, bufnr)
        lsp.default_keymaps({buffer = bufnr, preserve_mappings = false})
        
        local opts = {buffer = bufnr, remap = false}
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format({async = true}) end, opts)
        vim.keymap.set("n", "<leader>la", function() vim.lsp.buf.code_action() end, opts)
      end)
      
      lsp.setup()
      
      -- AI completion
      require("codeium").setup({})
    end
  },

  -- Next-gen UI components
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
          hover = { silent = true }
        },
        presets = {
          command_palette = true,
          long_message_to_split = true,
          lsp_doc_border = true,
        }
      })
    end
  },

  -- Visual debugging
  {
    "andrewferrier/debugprint.nvim",
    config = function()
      require("debugprint").setup({ create_keymaps = false })
      vim.keymap.set("n", "g?p", function() require("debugprint").debugprint() end)
      vim.keymap.set("n", "g?P", function() require("debugprint").debugprint({ above = true }) end)
    end
  },

  -- Session teleportation
  {
    "olimorris/persisted.nvim",
    config = function()
      require("persisted").setup({
        save_dir = vim.fn.stdpath("data") .. "/sessions/",
        silent = false,
        use_git_branch = true,
        autosave = true,
        should_autosave = function()
          return not vim.tbl_contains({"", "NvimTree"}, vim.bo.filetype)
        end
      })
      vim.keymap.set("n", "<leader>ss", "<cmd>Telescope persisted<cr>")
    end
  },

  -- Time travel
  {
    "mbbill/undotree",
    config = function()
      vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
    end
  },

  -- Zen mode
  {
    "folke/zen-mode.nvim",
    config = function()
      require("zen-mode").setup({
        window = { width = 0.85 }
      })
      vim.keymap.set("n", "<leader>z", "<cmd>ZenMode<cr>")
    end
  }
})

-- Cosmic keymaps
vim.keymap.set("n", "<leader>sv", "<cmd>source $MYVIMRC<cr>")
vim.keymap.set("n", "<leader>ev", "<cmd>vsplit $MYVIMRC<cr>")
vim.keymap.set("n", "<leader>ww", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>qq", "<cmd>q<cr>")
vim.keymap.set("n", "<leader>xx", "<cmd>x<cr>")

-- Window navigation with vim-tmux-navigator behavior
local function navigate(direction)
  local win = vim.fn.winnr()
  vim.cmd("wincmd " .. direction)
  if win == vim.fn.winnr() then
    local tmux = os.getenv("TMUX")
    if tmux ~= nil then
      vim.fn.system("tmux select-pane -" .. direction:sub(1, 1):upper())
    end
  end
end

vim.keymap.set("n", "<C-h>", function() navigate("h") end)
vim.keymap.set("n", "<C-j>", function() navigate("j") end)
vim.keymap.set("n", "<C-k>", function() navigate("k") end)
vim.keymap.set("n", "<C-l>", function() navigate("l") end)

-- Terminal escape
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]])

-- Autocommands for cosmic behavior
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    vim.cmd([[%s/\s\+$//e]])
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "qf", "help", "man", "lspinfo", "spectre_panel" },
  callback = function()
    vim.cmd([[
      nnoremap <silent> <buffer> q :close<CR>
      set nobuflisted
    ]])
  end
})

-- Cosmic statusline
local function statusline()
  local mode = "%{%v:lua.string.upper(v:lua.vim.fn.mode())%}"
  local file = "%f"
  local modified = "%m"
  local align = "%="
  local line = "%l"
  local column = "%c"
  local percent = "%p%%"
  
  return string.format(
    "%%#StatusLine# %s %s%s %%#StatusLineNC# %s:%s %s ",
    mode, file, modified, line, column, percent
  )
end

vim.opt.statusline = "%!v:lua.statusline()"


vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})
