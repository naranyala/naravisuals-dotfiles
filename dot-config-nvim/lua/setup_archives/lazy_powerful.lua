-- ~/.config/nvim/init.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
 vim.fn.system({
   "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath
 })
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
 -- Theme
 { 
   "folke/tokyonight.nvim", 
   priority = 1000,
   config = function()
     vim.cmd.colorscheme("tokyonight-night")
   end
 },

 {
   "VonHeikemen/lsp-zero.nvim",
   branch = "v3.x",
   dependencies = {
     "neovim/nvim-lspconfig",
     "hrsh7th/cmp-nvim-lsp",
     "hrsh7th/nvim-cmp",
     "L3MON4D3/LuaSnip",
     "williamboman/mason.nvim",
     "williamboman/mason-lspconfig.nvim"
   },
   config = function()
     local lsp_zero = require("lsp-zero")
     lsp_zero.extend_lspconfig()

     lsp_zero.on_attach(function(client, bufnr)
       local opts = { buffer = bufnr }
       vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
       vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
       vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
       vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
       vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
     end)

     require("mason").setup()
     require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",               -- Lua
          "clangd",               -- C
          "bashls",               -- Bash
          "kotlin_language_server" -- Kotlin
        },
        automatic_installation = true,
       handlers = { lsp_zero.default_setup }
     })

     local cmp = require("cmp")
     cmp.setup({
       sources = {
         { name = "nvim_lsp" },
         { name = "luasnip" },
         { name = "buffer" }
       },
       mapping = {
         ['<C-p>'] = cmp.mapping.select_prev_item(),
         ['<C-n>'] = cmp.mapping.select_next_item(),
         ['<C-y>'] = cmp.mapping.confirm({ select = true }),
         ['<C-Space>'] = cmp.mapping.complete()
       },
       snippet = {
         expand = function(args)
           require("luasnip").lsp_expand(args.body)
         end
       }
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


 -- File explorer
 -- {
 --   "kelly-lin/ranger.nvim",
 --   config = function()
 --     require("ranger-nvim").setup({
 --       replace_netrw = true,
 --       keybinds = {
 --         ["ov"] = require("ranger-nvim").OPEN_MODE.vsplit,
 --         ["oh"] = require("ranger-nvim").OPEN_MODE.split,
 --         ["ot"] = require("ranger-nvim").OPEN_MODE.tabedit,
 --         ["or"] = require("ranger-nvim").OPEN_MODE.rifle,
 --       }
 --     })
 --   end
 -- },

 -- Fuzzy finder
 -- {
 --   "prochri/telescope-all-recent.nvim",
 --   dependencies = {
 --     "nvim-telescope/telescope.nvim",
 --     "kkharji/sqlite.lua"
 --   },
 --   config = function()
 --     require("telescope").load_extension("all_recent")
 --     require("telescope-all-recent").setup({
 --       default = {
 --         disable = true,
 --         use_cwd = true,
 --         sorting = "recent"
 --       }
 --     })
 --   end
 -- },

 -- Statusline
 {
   "tjdevries/express_line.nvim",
   config = function()
     require("el").setup({
       generator = function()
         return {
           require("el.builtin").mode,
           " ",
           require("el.builtin").file_relative,
           require("el.builtin").filetype,
           require("el.builtin").line_with_width(3),
           "[", require("el.builtin").number_of_windows, "]"
         }
       end
     })
   end
 },

 -- LSP with different manager
 {
   "pmizio/typescript-tools.nvim",
   dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
   config = function()
     require("typescript-tools").setup({})
   end
 },

 -- Alternative LSP installer
 -- {
 --   "anott03/nvim-lspinstall",
 --   config = function()
 --     require("lspinstall").setup()
 --     local lspconfig = require("lspconfig")
 --     local servers = require("lspinstall").installed_servers()
 --    
 --     for _, server in pairs(servers) do
 --       lspconfig[server].setup({})
 --     end
 --   end
 -- },

 -- Completion
 {
   "vigoux/complementree.nvim",
   config = function()
     require("complementree").setup({
       sources = {
         require("complementree.sources").lsp,
         require("complementree.sources").buffer,
         require("complementree.sources").path
       }
     })
   end
 },

 -- Syntax highlighting
 {
   "nvim-treesitter/nvim-treesitter",
   build = ":TSUpdate",
   dependencies = {
     "nvim-treesitter/nvim-treesitter-context",
     "nvim-treesitter/nvim-treesitter-refactor"
   },
   config = function()
     require("nvim-treesitter.configs").setup({
       ensure_installed = { "lua", "python", "rust", "javascript", "typescript", "c", "cpp", "vim" },
       highlight = { enable = true },
       indent = { enable = true },
       refactor = {
         highlight_definitions = { enable = true },
         highlight_current_scope = { enable = true }
       }
     })
     require("treesitter-context").setup({
       enable = true,
       max_lines = 0,
       trim_scope = "outer"
     })
   end
 },

 -- Window management
 {
   "declancm/windex.nvim",
   config = function()
     require("windex").setup({
       default_keymaps = true,
       extra_keymaps = true
     })
   end
 },

 -- Session management
 {
   "jedrzejboczar/possession.nvim",
   dependencies = { "nvim-lua/plenary.nvim" },
   config = function()
     require("possession").setup({
       session_dir = vim.fn.expand("~/.local/share/nvim/sessions/"),
       silent = false,
       load_silent = true,
       debug = false,
       logfile = false,
       prompt_no_cr = false,
       autosave = {
         current = false,
         tmp = false,
         tmp_name = "tmp"
       }
     })
   end
 },

 -- Terminal
 {
   "nikvdp/neomux",
   config = function()
     vim.g.neomux_start_term_split = 1
     vim.g.neomux_winheight = 12
   end
 },

 -- Git
 {
   "NeogitOrg/neogit",
   dependencies = {
     "nvim-lua/plenary.nvim",
     "sindrets/diffview.nvim",
     "nvim-telescope/telescope.nvim"
   },
   config = function()
     require("neogit").setup({
       disable_signs = false,
       disable_hint = false,
       disable_context_highlighting = false,
       disable_commit_confirmation = false,
       auto_refresh = true,
       sort_branches = "-committerdate",
       disable_builtin_notifications = false,
       use_magit_keybindings = false,
       commit_popup = {
         kind = "split"
       },
       preview_buffer = {
         kind = "split"
       },
       popup = {
         kind = "split"
       }
     })
   end
 },

 -- Commenting
 {
   "terrortylor/nvim-comment",
   config = function()
     require("nvim_comment").setup({
       marker_padding = true,
       comment_empty = true,
       comment_empty_trim_whitespace = true,
       create_mappings = true,
       line_mapping = "gcc",
       operator_mapping = "gc",
       comment_chunk_text_object = "ic"
     })
   end
 },

 -- Surround
 {
   "roobert/surround-ui.nvim",
   dependencies = {
     "kylechui/nvim-surround",
     "folke/which-key.nvim"
   },
   config = function()
     require("surround-ui").setup({
       root_key = "S"
     })
   end
 },

 -- Motion
 {
   "RRethy/vim-illuminate",
   config = function()
     require("illuminate").configure({
       providers = {
         "lsp",
         "treesitter",
         "regex"
       },
       delay = 100,
       filetype_overrides = {},
       filetypes_denylist = {
         "dirvish",
         "fugitive"
       },
       filetypes_allowlist = {},
       modes_denylist = {},
       modes_allowlist = {},
       providers_regex_syntax_denylist = {},
       providers_regex_syntax_allowlist = {},
       under_cursor = true
     })
   end
 },

 -- Debugging
 {
   "puremourning/vimspector",
   config = function()
     vim.g.vimspector_enable_mappings = "HUMAN"
     vim.g.vimspector_sidebar_width = 85
     vim.g.vimspector_bottombar_height = 15
     vim.g.vimspector_terminal_maxwidth = 70
   end
 },

 -- Testing
 {
   "vim-test/vim-test",
   config = function()
     vim.g["test#strategy"] = "neovim"
     vim.g["test#neovim#term_position"] = "belowright"
     vim.g["test#neovim#preserve_screen"] = 1
   end
 },

 -- Notifications
 {
   "j-hui/fidget.nvim",
   tag = "legacy",
   config = function()
     require("fidget").setup({
       text = {
         spinner = "pipe",
         done = "✔",
         commenced = "Started",
         completed = "Completed"
       },
       align = {
         bottom = true,
         right = true
       },
       timer = {
         spinner_rate = 125,
         fidget_decay = 2000,
         task_decay = 1000
       },
       window = {
         relative = "win",
         blend = 100,
         zindex = nil,
         border = "none"
       }
     })
   end
 },

 -- Code outline
 {
   "simrat39/symbols-outline.nvim",
   config = function()
     require("symbols-outline").setup({
       highlight_hovered_item = true,
       show_guides = true,
       auto_preview = false,
       position = "right",
       relative_width = true,
       width = 25,
       auto_close = false,
       show_numbers = false,
       show_relative_numbers = false,
       show_symbol_details = true,
       preview_bg_highlight = "Pmenu",
       autofold_depth = nil,
       auto_unfold_hover = true,
       fold_markers = { "", "" },
       wrap = false,
       keymaps = {
         close = { "<Esc>", "q" },
         goto_location = "<Cr>",
         focus_location = "o",
         hover_symbol = "<C-space>",
         toggle_preview = "K",
         rename_symbol = "r",
         code_actions = "a",
         fold = "h",
         unfold = "l",
         fold_all = "W",
         unfold_all = "E",
         fold_reset = "R"
       }
     })
   end
 },

 -- Bookmarks
 {
   "MattesGroeger/vim-bookmarks",
   config = function()
     vim.g.bookmark_sign = "⚑"
     vim.g.bookmark_annotation_sign = "☰"
     vim.g.bookmark_no_default_key_mappings = 1
     vim.g.bookmark_auto_save = 1
     vim.g.bookmark_auto_close = 0
     vim.g.bookmark_manage_per_buffer = 0
     vim.g.bookmark_save_per_working_dir = 0
   end
 },

 -- Dashboard
 {
   "nvimdev/dashboard-nvim",
   config = function()
     require("dashboard").setup({
       theme = "hyper",
       config = {
         week_header = {
           enable = true
         },
         shortcut = {
           { desc = "󰊳 Update", group = "@property", action = "Lazy update", key = "u" },
           { desc = " Files", group = "Label", action = "Telescope find_files", key = "f" },
           { desc = " Apps", group = "DiagnosticHint", action = "Telescope app", key = "a" },
           { desc = " Dotfiles", group = "Number", action = "Telescope dotfiles", key = "d" }
         }
       }
     })
   end
 },

 -- Color picker
 {
   "uga-rosa/ccc.nvim",
   config = function()
     require("ccc").setup({
       highlighter = {
         auto_enable = true,
         lsp = true
       }
     })
   end
 }
})

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500

-- Keybindings
vim.g.mapleader = ' '
local map = vim.keymap.set

-- File operations
map('n', '<leader>e', '<cmd>Oil<cr>')
map('n', '<leader>ff', '<cmd>Telescope find_files<cr>')
map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>')
map('n', '<leader>fb', '<cmd>Telescope buffers<cr>')
map('n', '<leader>fr', '<cmd>Telescope all_recent<cr>')

-- Git
map('n', '<leader>gg', '<cmd>Neogit<cr>')
map('n', '<leader>gs', '<cmd>Neogit kind=split<cr>')
map('n', '<leader>gc', '<cmd>Neogit commit<cr>')
map('n', '<leader>gp', '<cmd>Neogit push<cr>')

-- Sessions
map('n', '<leader>ss', '<cmd>PossessionSave<cr>')
map('n', '<leader>sl', '<cmd>PossessionLoad<cr>')
map('n', '<leader>sd', '<cmd>PossessionDelete<cr>')

-- Terminal
map('n', '<leader>tt', '<cmd>NeomuxHorizontalSplit<cr>')
map('n', '<leader>tv', '<cmd>NeomuxVerticalSplit<cr>')

-- Testing
map('n', '<leader>tn', '<cmd>TestNearest<cr>')
map('n', '<leader>tf', '<cmd>TestFile<cr>')
map('n', '<leader>ts', '<cmd>TestSuite<cr>')
map('n', '<leader>tl', '<cmd>TestLast<cr>')
map('n', '<leader>tv', '<cmd>TestVisit<cr>')

-- Debugging
map('n', '<F5>', '<cmd>call vimspector#Launch()<cr>')
map('n', '<F3>', '<cmd>call vimspector#Stop()<cr>')
map('n', '<F4>', '<cmd>call vimspector#Restart()<cr>')
map('n', '<F6>', '<cmd>call vimspector#Pause()<cr>')
map('n', '<F9>', '<cmd>call vimspector#ToggleBreakpoint()<cr>')
map('n', '<F8>', '<cmd>call vimspector#AddFunctionBreakpoint()<cr>')

-- Outline
map('n', '<leader>o', '<cmd>SymbolsOutline<cr>')

-- Bookmarks
map('n', '<leader>mm', '<cmd>BookmarkToggle<cr>')
map('n', '<leader>mi', '<cmd>BookmarkAnnotate<cr>')
map('n', '<leader>mn', '<cmd>BookmarkNext<cr>')
map('n', '<leader>mp', '<cmd>BookmarkPrev<cr>')
map('n', '<leader>ma', '<cmd>BookmarkShowAll<cr>')
map('n', '<leader>mc', '<cmd>BookmarkClear<cr>')

-- Color picker
map('n', '<leader>cp', '<cmd>CccPick<cr>')

-- Window management
map('n', '<leader>ww', '<cmd>WinShift<cr>')
map('n', '<leader>wx', '<cmd>WinShift swap<cr>')

-- Navigation
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- Quick save and escape
map('n', '<C-s>', '<cmd>w<cr>')
map('i', '<C-s>', '<esc><cmd>w<cr>')
map('i', 'jk', '<esc>')

-- Comments
map('n', '<leader>/', '<cmd>CommentToggle<cr>')
map('v', '<leader>/', '<cmd>CommentToggle<cr>')


vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})
