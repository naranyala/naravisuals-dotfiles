-- ~/.config/nvim/init.lua

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.runtimepath:prepend(lazypath)

-- Basic settings
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

-- Leader key
vim.g.mapleader = ' '

-- Basic keymaps
vim.keymap.set('n', '<C-s>', '<cmd>w<cr>')
vim.keymap.set('i', 'jk', '<esc>')
vim.keymap.set('n', '<esc>', '<cmd>nohlsearch<cr>')
vim.keymap.set('n', '<leader>q', '<cmd>q<cr>')
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>')
vim.keymap.set('n', '<leader>x', '<cmd>x<cr>')
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')
vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>")

-- Auto commands
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- vim.api.nvim_create_autocmd('FileType', {
--   pattern = { 'gitcommit', 'markdown' },
--   callback = function()
--     vim.opt_local.wrap = true
--     vim.opt_local.spell = true
--   end,
-- })

-- Setup lazy.nvim
require("lazy").setup({
  -- Colorscheme: Rose Pine (modern warm theme)
  -- {
  --   "rose-pine/neovim",
  --   name = "rose-pine",
  --   priority = 1000,
  --   config = function()
  --     require('rose-pine').setup({
  --       variant = 'moon',
  --       dark_variant = 'moon',
  --       dim_inactive_windows = true,
  --       extend_background_behind_borders = true,
  --     })
  --     vim.cmd.colorscheme('rose-pine')
  --   end
  -- },

  {
    "navarasu/onedark.nvim",
    priority = 1000, -- ensures it loads before other plugins
    lazy = false,    -- load immediately
    config = function()
      require("onedark").setup {
        style = "darker", -- options: dark, darker, cool, deep, warm, warmer, light
      }
      require("onedark").load()
    end,
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
        ensure_installed = {
          "lua_ls",               -- Lua
          "clangd",               -- C
          "bashls",               -- Bash
          "kotlin_language_server" -- Kotlin
        },
      })
    end
  },

  -- Statusline: Mini.statusline (minimal and fast)
  {
    "echasnovski/mini.statusline",
    version = false,
    event = "VeryLazy",
    config = function()
      require('mini.statusline').setup({
        use_icons = true,
        set_vim_settings = false,
      })
    end
  },

  -- File explorer: Oil.nvim (edit directories like buffers)
	{
		"stevearc/oil.nvim",
		config = function()
			require("oil").setup({
				float = { padding = 4 },
				view_options = { show_hidden = true },
			})
		end,
	},

  -- Fuzzy finder: FZF-Lua (native fzf integration)
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Find buffers" },
      { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help tags" },
      { "<leader>fr", "<cmd>FzfLua resume<cr>", desc = "Resume search" },
      { "<leader>fo", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
    },
    config = function()
      require("fzf-lua").setup({
        winopts = {
          height = 0.85,
          width = 0.80,
          preview = {
            default = 'bat',
            border = 'border',
            wrap = 'nowrap',
            hidden = 'nohidden',
          },
        },
      })
    end
  },

  -- Syntax highlighting: Tree-sitter with context
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-context",
    },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          "lua_ls",               -- Lua
          "clangd",               -- C
          "bashls",               -- Bash
          "kotlin_language_server", -- Kotlin
          'html', 
          'css', 
          'bash', 
          'json', 
          'yaml', 
          'markdown', 
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
      require('treesitter-context').setup({
        enable = true,
        max_lines = 0,
        trim_scope = 'outer',
        patterns = {
          default = {
            'class',
            'function',
            'method',
            'for',
            'while',
            'if',
            'switch',
            'case',
          },
        },
      })
    end
  },

  -- LSP: Native LSP with Lspsaga for enhanced UI
  {
    "glepnir/lspsaga.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require('lspsaga').setup({
        ui = {
          theme = 'round',
          border = 'rounded',
          winblend = 0,
        },
        symbol_in_winbar = {
          enable = true,
        },
        lightbulb = {
          enable = false,
        },
      })

      -- LSP keymaps
      vim.keymap.set('n', 'K', '<cmd>Lspsaga hover_doc<cr>')
      vim.keymap.set('n', 'gd', '<cmd>Lspsaga lsp_finder<cr>')
      vim.keymap.set('n', '<leader>rn', '<cmd>Lspsaga rename<cr>')
      vim.keymap.set('n', '<leader>ca', '<cmd>Lspsaga code_action<cr>')
      vim.keymap.set('n', '<leader>cd', '<cmd>Lspsaga show_line_diagnostics<cr>')
      vim.keymap.set('n', '[d', '<cmd>Lspsaga diagnostic_jump_prev<cr>')
      vim.keymap.set('n', ']d', '<cmd>Lspsaga diagnostic_jump_next<cr>')
      vim.keymap.set('n', '<leader>o', '<cmd>Lspsaga outline<cr>')

      -- Basic LSP setup
      local lspconfig = require('lspconfig')
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      -- lspconfig.lua_ls.setup({
      --   capabilities = capabilities,
      --   settings = {
      --     Lua = {
      --       runtime = { version = 'LuaJIT' },
      --       diagnostics = { globals = { 'vim' } },
      --       workspace = {
      --         library = vim.api.nvim_get_runtime_file('', true),
      --         checkThirdParty = false,
      --       },
      --       telemetry = { enable = false },
      --     },
      --   },
      -- })

      lspconfig.pyright.setup({ capabilities = capabilities })
      lspconfig.ts_ls.setup({ capabilities = capabilities })
      lspconfig.html.setup({ capabilities = capabilities })
      lspconfig.cssls.setup({ capabilities = capabilities })
      lspconfig.bashls.setup({ capabilities = capabilities })
    end
  },

  -- Completion: Blink.cmp (next-gen completion)
  {
    "saghen/blink.cmp",
    lazy = false,
    dependencies = "rafamadriz/friendly-snippets",
    version = "v0.*",
    config = function()
      require('blink.cmp').setup({
        keymap = {
          preset = 'default',
          ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
          ['<C-e>'] = { 'hide' },
          ['<C-y>'] = { 'select_and_accept' },
          ['<C-p>'] = { 'select_prev', 'fallback' },
          ['<C-n>'] = { 'select_next', 'fallback' },
          ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
          ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
          ['<Tab>'] = { 'snippet_forward', 'fallback' },
          ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
        },
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = 'mono'
        },
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
        },
        completion = {
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
          },
        },
      })
    end
  },

  -- Git: Neogit (modern git interface)
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "ibhagwan/fzf-lua",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Open Neogit" },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Git commit" },
      { "<leader>gp", "<cmd>Neogit push<cr>", desc = "Git push" },
      { "<leader>gl", "<cmd>Neogit log<cr>", desc = "Git log" },
    },
    config = function()
      require('neogit').setup({
        integrations = {
          diffview = true,
          fzf_lua = true,
        },
      })
    end
  },

  -- Git signs: Mini.diff (lightweight git signs)
  {
    "echasnovski/mini.diff",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require('mini.diff').setup({
        view = {
          style = 'sign',
          signs = {
            add = '+',
            change = '~',
            delete = '_',
          },
        },
      })
    end
  },

  -- Comments: Mini.comment (simple and effective)
  {
    "echasnovski/mini.comment",
    version = false,
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
    },
    config = function()
      require('mini.comment').setup()
    end
  },

  -- Autopairs: Mini.pairs (lightweight autopairs)
  {
    "echasnovski/mini.pairs",
    version = false,
    event = "InsertEnter",
    config = function()
      require('mini.pairs').setup()
    end
  },

  -- Surround: Mini.surround (modern surround)
  {
    "echasnovski/mini.surround",
    version = false,
    keys = {
      { "sa", mode = { "n", "v" }, desc = "Add surround" },
      { "sd", mode = "n", desc = "Delete surround" },
      { "sf", mode = "n", desc = "Find surround" },
      { "sh", mode = "n", desc = "Highlight surround" },
      { "sr", mode = "n", desc = "Replace surround" },
      { "sn", mode = "n", desc = "Update n_lines" },
    },
    config = function()
      require('mini.surround').setup()
    end
  },

  -- Indentation: Mini.indentscope (animated indent guide)
  {
    "echasnovski/mini.indentscope",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require('mini.indentscope').setup({
        symbol = '│',
        options = { try_as_border = true },
      })
    end
  },

  -- Terminal: Toggleterm with better config
  {
    "akinsho/toggleterm.nvim",
    keys = {
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal float" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal horizontal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=40<cr>", desc = "Terminal vertical" },
    },
    config = function()
      require('toggleterm').setup({
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = 'float',
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = 'curved',
          winblend = 0,
          highlights = {
            border = "Normal",
            background = "Normal",
          },
        },
      })
    end
  },

  -- Buffer management: Mini.bufremove (better buffer deletion)
  {
    "echasnovski/mini.bufremove",
    version = false,
    keys = {
      { "<leader>bd", function() require('mini.bufremove').delete(0, false) end, desc = "Delete buffer" },
      { "<leader>bD", function() require('mini.bufremove').delete(0, true) end, desc = "Delete buffer (force)" },
    },
    config = function()
      require('mini.bufremove').setup()
    end
  },

  -- Notifications: Fidget (LSP progress)
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    config = function()
      require('fidget').setup({
        notification = {
          window = {
            winblend = 100,
          },
        },
      })
    end
  },

  -- Movement: Flash (enhanced navigation)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
    config = function()
      require("flash").setup({
        modes = {
          search = {
            enabled = false,
          },
        },
      })
    end
  },

{
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    plugins = {
      spelling = { enabled = true, suggestions = 20 },
      presets = {
        operators = true,
        motions = true,
        text_objects = true,
        windows = true,
        nav = true,
        z = true,
        g = true,
      },
    },
    window = {
      border = "rounded",
      position = "bottom",
      margin = { 1, 0, 1, 0 },
      padding = { 2, 2, 2, 2 },
    },
    layout = {
      height = { min = 4, max = 25 },
      width = { min = 20, max = 50 },
      spacing = 3,
      align = "left",
    },
    triggers = { { "<leader>", mode = "n" } },
    spec = {
      -- { "<leader>f", group = "File" },
      -- { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      -- { "<leader>fw", "<cmd>Telescope live_grep<cr>", desc = "Find Word" },
      -- { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      -- { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer" },
      --
      -- { "<leader>g", group = "Git" },
      -- { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
      -- { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git Status" },
      --
      -- { "<leader>l", group = "LSP" },
      -- { "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename" },
      -- { "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code Action" },
      -- { "<leader>ld", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      --
      -- { "<leader>m", group = "Markdown" },
      -- { "<leader>ms", "<cmd>set spell!<cr>", desc = "Toggle Spell" },
      -- { "<leader>mf", "<cmd>Format<cr>", desc = "Format Markdown" },
      --
      -- { "<leader>b", group = "Buffers" },
      -- { "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete Buffer" },
      -- { "<leader>bn", "<cmd>enew<cr>", desc = "New Buffer" },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add(opts.spec)
  end,
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
  },


  -- Advanced git history viewer
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = true,
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
      { "<leader>gl", "<cmd>Neogit log<cr>", desc = "Git log" },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Git commit" },
    },
  },

  -- Interactive git history with diff view
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    opts = {
      diff_binaries = false,
      enhanced_diff_hl = true,
      use_icons = true,
      show_help_hints = true,
      view = {
        default = { layout = "diff2_horizontal" },
        merge_tool = { layout = "diff3_horizontal" },
        file_history = { layout = "diff2_horizontal" },
      },
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },
        win_config = {
          position = "left",
          width = 35,
        },
      },
      file_history_panel = {
        log_options = {
          git = {
            single_file = {
              diff_merges = "combined",
            },
            multi_file = {
              diff_merges = "first-parent",
            },
          },
        },
        win_config = {
          position = "bottom",
          height = 16,
        },
      },
    },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
      { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "File history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "Current file history" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
    },
  },

  -- Enhanced git log with fancy UI
  {
    "isakbm/gitgraph.nvim",
    opts = {
      symbols = {
        merge_commit = "◎",
        commit = "●",
        merge_commit_end = "◎",
        commit_end = "●",
        GVER = "│",
        GHOR = "─",
        GCLD = "╮",
        GCRD = "╭",
        GCLU = "╯",
        GCRU = "╰",
        GLRU = "┌",
        GLRD = "┐",
        GLUD = "└",
        GRUD = "┘",
        GFORKU = "┬",
        GFORKD = "┴",
        GRUDCD = "┤",
        GRUDCU = "┤",
        GLUDCD = "├",
        GLUDCU = "├",
        GLRDCL = "┼",
        GLRDCR = "┼",
        GLRUCL = "┼",
        GLRUCR = "┼",
      },
      format = {
        timestamp = "%H:%M:%S %d-%m-%Y",
        fields = { "hash", "timestamp", "author", "branch_name", "tag" },
      },
      hooks = {
        on_select_commit = function(commit)
          vim.cmd("DiffviewOpen " .. commit.hash .. "^!")
        end,
        on_select_range_commit = function(from, to)
          vim.cmd("DiffviewOpen " .. from.hash .. ".." .. to.hash)
        end,
      },
    },
    keys = {
      { "<leader>go", function() require("gitgraph").draw({}, { all = true, max_count = 5000 }) end, desc = "Git graph" },
    },
  },

  -- Telescope git integration
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
            },
            vertical = {
              mirror = false,
            },
          },
          sorting_strategy = "ascending",
          winblend = 0,
        },
        pickers = {
          git_commits = {
            theme = "ivy",
            layout_config = {
              height = 0.4,
            },
          },
          git_bcommits = {
            theme = "ivy",
            layout_config = {
              height = 0.4,
            },
          },
          git_branches = {
            theme = "ivy",
            layout_config = {
              height = 0.4,
            },
          },
        },
      })
    end,
    keys = {
      { "<leader>fc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
      { "<leader>fb", "<cmd>Telescope git_bcommits<cr>", desc = "Buffer commits" },
      { "<leader>fr", "<cmd>Telescope git_branches<cr>", desc = "Git branches" },
      { "<leader>fs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
    },
  },

  -- Advanced git signs with blame
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 1000,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      preview_config = {
        border = "single",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
    },
    keys = {
      { "<leader>gb", "<cmd>Gitsigns blame_line<cr>", desc = "Git blame line" },
      { "<leader>gB", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle line blame" },
      { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview hunk" },
      { "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", desc = "Reset hunk" },
      { "<leader>gR", "<cmd>Gitsigns reset_buffer<cr>", desc = "Reset buffer" },
      { "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>", desc = "Stage hunk" },
      { "<leader>gS", "<cmd>Gitsigns stage_buffer<cr>", desc = "Stage buffer" },
      { "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<cr>", desc = "Undo stage hunk" },
      { "]c", "<cmd>Gitsigns next_hunk<cr>", desc = "Next hunk" },
      { "[c", "<cmd>Gitsigns prev_hunk<cr>", desc = "Prev hunk" },
    },
  },

  -- Git worktree management
  {
    "ThePrimeagen/git-worktree.nvim",
    config = function()
      require("git-worktree").setup()
      require("telescope").load_extension("git_worktree")
    end,
    keys = {
      { "<leader>gwc", "<cmd>Telescope git_worktree create_git_worktree<cr>", desc = "Create worktree" },
      { "<leader>gws", "<cmd>Telescope git_worktree git_worktrees<cr>", desc = "Switch worktree" },
    },
  },


})



-- Additional git mappings
vim.keymap.set("n", "<leader>gw", "<cmd>Gitsigns toggle_word_diff<cr>", { desc = "Toggle word diff" })
vim.keymap.set("n", "<leader>gD", "<cmd>Gitsigns diffthis<cr>", { desc = "Diff this" })
vim.keymap.set("n", "<leader>gt", "<cmd>Gitsigns toggle_deleted<cr>", { desc = "Toggle deleted" })


-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "markdown",
--   callback = function()
--     vim.opt_local.spell = true
--     vim.opt_local.spelllang = "en_us"
--   end,
-- })
