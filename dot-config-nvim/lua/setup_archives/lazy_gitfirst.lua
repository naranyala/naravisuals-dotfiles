-- ~/.config/nvim/init.lua

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Configure lazy.nvim
require("lazy").setup({
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


  -- Syntax highlighting
  { 
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
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

  -- Colorscheme for better git highlighting
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
      },
      sidebars = { "qf", "help", "terminal", "packer" },
      day_brightness = 0.3,
      hide_inactive_statusline = false,
      dim_inactive = false,
      lualine_bold = false,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd("colorscheme tokyonight")
    end,
  },
})

-- Basic vim settings
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250

-- Additional git mappings
vim.keymap.set("n", "<leader>gw", "<cmd>Gitsigns toggle_word_diff<cr>", { desc = "Toggle word diff" })
vim.keymap.set("n", "<leader>gD", "<cmd>Gitsigns diffthis<cr>", { desc = "Diff this" })
vim.keymap.set("n", "<leader>gt", "<cmd>Gitsigns toggle_deleted<cr>", { desc = "Toggle deleted" })


vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})
