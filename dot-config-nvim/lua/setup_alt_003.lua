-- ~/.config/nvim/init.lua
-- Compact System Programming Neovim Config (C/Rust/Zig)

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Core settings optimized for system programming
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false -- Tabs for system languages
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 8
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.completeopt = "menu,menuone,noselect"

-- DISABLE VERTICAL SEPARATOR
-- vim.opt.signcolumn = "yes:1"
-- vim.opt.colorcolumn = "80,120"

-- Filetype detection
vim.cmd([[
  filetype plugin indent on
  syntax enable
]])

-- Core plugin set: Minimal but comprehensive for system programming
require("lazy").setup({

  require("_shared_other_modules"),
  require("_shared_mason_lsp_treesitter"),
  -- require("_shared_mason_lsp_treesitter2"),
  -- require("_shared_mason_lsp_treesitter3"),


  -- Colorscheme (minimal, fast)
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        dark_variant = "moon",
        disable_italics = true,
      })
      vim.cmd.colorscheme("rose-pine")
    end,
  },

  -- Statusline (minimal)
  -- {
  --   "nvim-lualine/lualine.nvim",
  --   dependencies = { "nvim-tree/nvim-web-devicons" },
  --   config = function()
  --     require("lualine").setup({
  --       options = { theme = "auto", component_separators = "|", section_separators = "" },
  --       sections = {
  --         lualine_a = { "mode" },
  --         lualine_b = { "branch" },
  --         lualine_c = { "filename" },
  --         lualine_x = { "filetype" },
  --         lualine_y = { "progress" },
  --         lualine_z = { "location" },
  --       },
  --     })
  --   end,
  -- },

  -- Enhanced editing
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function() require("nvim-autopairs").setup({}) end,
  },

  {
    "numToStr/Comment.nvim",
    config = function() require("Comment").setup() end,
  },

  -- Fast navigation
  -- {
  --   "ggandor/leap.nvim",
  --   config = function() require("leap").add_default_mappings() end,
  -- },


  -- Fuzzy finder (Telescope)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      -- vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "gd", builtin.lsp_definitions, { desc = "Go to definition" })
      vim.keymap.set("n", "gr", builtin.lsp_references, { desc = "References" })
    end,
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          vim.keymap.set("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, { buffer = bufnr, expr = true, desc = "Next hunk" })

          vim.keymap.set("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, { buffer = bufnr, expr = true, desc = "Prev hunk" })
        end,
      })
    end,
  },

  -- Build and run integration
  {
    "stevearc/overseer.nvim",
    config = function()
      require("overseer").setup()
      vim.keymap.set("n", "<leader>rr", "<cmd>OverseerRun<cr>", { desc = "Run task" })
      vim.keymap.set("n", "<leader>rt", "<cmd>OverseerToggle<cr>", { desc = "Toggle tasks" })
    end,
  },

  -- Quick terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]],
        direction = "float",
        float_opts = { border = "curved" },
      })
    end,
  },


  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("kanagawa")
    end
  },


  -- END SEETUP
})

-- Custom keymaps
local keymaps = {
  -- Buffer management
  { "n", "<leader>q",  "<cmd>bd<cr>",                                      { desc = "Close buffer" } },
  { "n", "<leader>bn", "<cmd>bn<cr>",                                      { desc = "Next buffer" } },
  { "n", "<leader>bp", "<cmd>bp<cr>",                                      { desc = "Prev buffer" } },

  -- Window navigation
  { "n", "<C-h>",      "<C-w>h",                                           { desc = "Window left" } },
  { "n", "<C-j>",      "<C-w>j",                                           { desc = "Window down" } },
  { "n", "<C-k>",      "<C-w>k",                                           { desc = "Window up" } },
  { "n", "<C-l>",      "<C-w>l",                                           { desc = "Window right" } },

  -- Quick actions
  { "n", "<leader>w",  "<cmd>w<cr>",                                       { desc = "Save" } },
  { "n", "<leader>W",  "<cmd>wa<cr>",                                      { desc = "Save all" } },
  { "n", "<leader>Q",  "<cmd>qa<cr>",                                      { desc = "Quit all" } },

  -- Code actions
  { "v", "<leader>y",  '"+y',                                              { desc = "Yank to system" } },
  { "n", "<leader>Y",  '"+Y',                                              { desc = "Yank line to system" } },
  { "v", "<leader>p",  '"+p',                                              { desc = "Paste from system" } },
  { "n", "<leader>P",  '"+P',                                              { desc = "Paste from system" } },

  -- System programming specific
  { "n", "<leader>cc", "<cmd>!gcc -Wall -Wextra -g % -o %:r && ./%:r<cr>", { desc = "Compile & run C" } },
  { "n", "<leader>cr", "<cmd>!cargo run<cr>",                              { desc = "Cargo run" } },
  { "n", "<leader>ct", "<cmd>!cargo test<cr>",                             { desc = "Cargo test" } },
  { "n", "<leader>cz", "<cmd>!zig build run<cr>",                          { desc = "Zig run" } },

  -- Search
  { "n", "<leader>/",  "<cmd>nohlsearch<cr>",                              { desc = "Clear search" } },

  -- Quick compile commands
  { "n", "<F5>",       "<cmd>lua _G.compile_and_run()<cr>",                { desc = "Compile and run" } },
}

for _, map in ipairs(keymaps) do
  vim.keymap.set(map[1], map[2], map[3], map[4])
end

-- Autocommands
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "rust", "zig" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
    vim.opt_local.colorcolumn = "80,120"
    vim.opt_local.textwidth = 0
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.c", "*.cpp", "*.h", "*.rs", "*.zig", "*.lua" },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Custom functions
_G.compile_and_run = function()
  local ft = vim.bo.filetype
  local file = vim.fn.expand("%")
  local base = vim.fn.expand("%:r")

  if ft == "c" then
    vim.cmd("term gcc -Wall -Wextra -g -o " .. base .. " " .. file .. " && ./" .. base)
  elseif ft == "cpp" then
    vim.cmd("term g++ -std=c++17 -Wall -Wextra -g -o " .. base .. " " .. file .. " && ./" .. base)
  elseif ft == "rust" then
    vim.cmd("term cargo run")
  elseif ft == "zig" then
    vim.cmd("term zig build run")
  else
    print("Unsupported filetype: " .. ft)
  end
end

-- Quick build commands per language
vim.api.nvim_create_user_command("Cbuild", function()
  local file = vim.fn.expand("%")
  local base = vim.fn.expand("%:r")
  vim.cmd("term gcc -Wall -Wextra -g -o " .. base .. " " .. file)
end, { desc = "Build C program" })

vim.api.nvim_create_user_command("Cppbuild", function()
  local file = vim.fn.expand("%")
  local base = vim.fn.expand("%:r")
  vim.cmd("term g++ -std=c++17 -Wall -Wextra -g -o " .. base .. " " .. file)
end, { desc = "Build C++ program" })

-- Show diagnostic on hover
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
-- vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- Print startup message
print("System Programming Neovim ready for C/Rust/Zig")
