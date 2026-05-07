-- $HOME/.config/nvim/init.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
vim.fn.system({
  "git", "clone", "--filter=blob:none", "--single-branch",
  "https://github.com/folke/lazy.nvim.git", lazypath})
end
vim.opt.runtimepath:prepend(lazypath)

-- Custom functions for enhanced ergonomics
local M = {}

-- Toggle relative/absolute line numbers
M.toggle_number = function()
if vim.wo.number then
  vim.wo.number = false
  vim.wo.relativenumber = false
else
  vim.wo.number = true
  vim.wo.relativenumber = true
end
end

-- Smart buffer closing (don't close last buffer)
M.close_buffer = function()
local bufnr = vim.api.nvim_get_current_buf()
local buflist = vim.api.nvim_list_bufs()
if #buflist > 1 then
  vim.api.nvim_buf_delete(bufnr, { force = false })
else
  vim.cmd.enew()
end
end

-- Toggle between windows with Ctrl+hjkl
M.setup_window_navigation = function()
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Go to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Go to lower window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Go to upper window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Go to right window' })
end

-- Resize splits with Ctrl+Shift+arrow
M.setup_split_resizing = function()
vim.keymap.set('n', '<C-S-Up>', '<cmd>resize +2<CR>', { desc = 'Increase window height' })
vim.keymap.set('n', '<C-S-Down>', '<cmd>resize -2<CR>', { desc = 'Decrease window height' })
vim.keymap.set('n', '<C-S-Left>', '<cmd>vertical resize -2<CR>', { desc = 'Decrease window width' })
vim.keymap.set('n', '<C-S-Right>', '<cmd>vertical resize +2<CR>', { desc = 'Increase window width' })
end

-- Quick save and quit shortcuts
M.setup_save_quit = function()
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', { desc = 'Save' })
vim.keymap.set('n', '<leader>q', '<cmd>q<cr>', { desc = 'Quit' })
vim.keymap.set('n', '<leader>Q', '<cmd>qall!<cr>', { desc = 'Quit all without saving' })
vim.keymap.set('n', '<leader>W', '<cmd>wqall<cr>', { desc = 'Save and quit all' })
end

-- Add new line without entering insert mode
M.setup_quick_newline = function()
vim.keymap.set('n', '<leader>o', 'o<Esc>', { desc = 'New line below' })
vim.keymap.set('n', '<leader>O', 'O<Esc>', { desc = 'New line above' })
end

-- Toggle terminal in a floating window
M.toggle_floating_term = function()
local Terminal = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new({
  cmd = 'lazygit',
  hidden = true,
  direction = 'float',
  float_opts = { border = 'rounded' },
  on_open = function(term)
    vim.cmd('startinsert!')
    vim.api.nvim_buf_set_keymap(term.bufnr, 't', '<esc>', '<C-\\><C-n>', { noremap = true, silent = true })
  end,
})
lazygit:toggle()
end

require("lazy").setup({
      require("./_shared/missing_native_apis"),
      require("./_shared/tpope_goodies"),
  require("./_shared/lualine_and_theme"),

{ "nvim-lua/plenary.nvim" },
{ "nvim-tree/nvim-web-devicons", opts = {} },

-- Enhanced telescope with more functionality
{ "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    defaults = {
      layout_strategy = "horizontal",
      layout_config = { prompt_position = "top" },
      sorting_strategy = "ascending",
      winblend = 0,
    },
    pickers = {
      find_files = { theme = "dropdown" },
      live_grep = { additional_args = { "--hidden" } },
    }
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Find help" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
    { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Find in current buffer" },
  }
},

-- Treesitter with more languages
{ "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    ensure_installed = { 
      "c", "lua", "vim", "vimdoc", "query", 
      "javascript", "typescript", "python", "html", "css"
    },
    highlight = { enable = true },
    indent = { enable = true },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
    vim.schedule(function()
      require("nvim-treesitter.install").update({ with_sync = true })
    end)
  end
},

-- Toggle terminal for quick shell access
{ "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    size = 10,
    open_mapping = [[<c-\>]],
    hide_numbers = true,
    shade_filetypes = {},
    shade_terminals = true,
    start_in_insert = true,
    persist_size = true,
    direction = "horizontal",
    close_on_exit = true,
    shell = vim.o.shell,
    float_opts = {
      border = "curved",
      winblend = 0,
      highlights = { border = "Normal", background = "Normal" },
    },
  },
  keys = {
    { "<leader>t", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    { "<leader>g", "<cmd>lua require('config').toggle_floating_term()<cr>", desc = "Open lazygit" },
  }
},

-- Better comments highlighting
{ "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = { signs = false },
  keys = {
    { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
    { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
  }
},

-- Smooth scrolling
{ "karb94/neoscroll.nvim",
  opts = { 
    mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>', '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
    hide_cursor = true,
    stop_eof = true,
  }
},

-- Auto pairs for brackets/quotes
{ "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    check_ts = true,
    ts_config = { lua = { 'string' }, javascript = { 'template_string' } },
  }
},

-- Status line (minimal)
{ "nvim-lualine/lualine.nvim",
dependencies = { "nvim-tree/nvim-web-devicons" },
opts = {
  options = {
    theme = 'auto',
    component_separators = '|',
    section_separators = '',
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  }
}
},

-- File explorer (optional - use telescope instead)
-- { "nvim-tree/nvim-tree.lua",
--   dependencies = { "nvim-tree/nvim-web-devicons" },
--   cmd = "NvimTreeToggle",
--   keys = { { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file explorer" } },
  --   opts = {
  --     view = { width = 30 },
  --     renderer = { group_empty = true },
  --     filters = { dotfiles = false },
  --   }
  -- },
  
  -- Indent guides
  -- { "lukas-reineke/indent-blankline.nvim",
  --   opts = {
  --     char = "│",
  --     show_trailing_blankline_indent = false,
  --     show_current_context = true,
  --   }
  -- },
  
  -- Auto session management
  { "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" } },
    keys = {
      { "<leader>sl", function() require("persistence").load() end, desc = "Restore session for current dir" },
      { "<leader>sd", function() require("persistence").stop() end, desc = "Don't save current session" },
    }
  },
}, {
  ui = { border = "rounded" },
  change_detection = { notify = false }
})

-- Apply custom functions
M.setup_window_navigation()
M.setup_split_resizing()
M.setup_save_quit()
M.setup_quick_newline()

-- Additional keymaps
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy Manager" })
vim.keymap.set("n", "<leader>n", "<cmd>lua require('config').toggle_number()<cr>", { desc = "Toggle line numbers" })
vim.keymap.set("n", "<leader>x", "<cmd>lua require('config').close_buffer()<cr>", { desc = "Close buffer" })
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Essential settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.clipboard = "unnamedplus"  -- Use system clipboard
vim.opt.completeopt = "menuone,noselect"
vim.opt.mouse = "a"  -- Enable mouse in all modes

-- Expose functions globally
_G.config = M
