-- ~/.config/nvim/init.lua
-- Ultimate 2025 single-file config for C • Rust • Zig systems programming
-- No debugger, pure editing power + smart custom helpers

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({


  require("_shared_other_modules"),
  require("_shared_mason_lsp_treesitter"),
  -- require("_shared_mason_lsp_treesitter2"),
  -- require("_shared_mason_lsp_treesitter3"),


  -- Performance
  { "lewis6991/impatient.nvim", priority = 10000 },

  -- Colorscheme (fast, beautiful, perfect contrast)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        term_colors = true,
        integrations = {
          treesitter = true,
          lsp = true,
          cmp = true,
          gitsigns = true,
          telescope = true,
          neotree = false,
          nvimtree = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },


  -- Telescope – best fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>" },
      { "<leader>fr", "<cmd>Telescope lsp_references<cr>" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>" },
    },
  },

  -- Git
  { "lewis6991/gitsigns.nvim", event = "BufReadPre", config = true },
  { "tpope/vim-fugitive" },

  -- Statusline
  -- { "nvim-lualine/lualine.nvim", event = "VimEnter",
  --   config = function() require("lualine").setup({ options = { theme = "catppuccin" } }) end },

  -- File tree
  -- { "nvim-tree/nvim-tree.lua",
  --   keys = { { "<leader>e", "<cmd>NvimTreeToggle<cr>" } },
  --   config = function() require("nvim-tree").setup({ update_focused_file = { enable = true } }) end },

  -- Essentials
  { "numToStr/Comment.nvim", config = true },
  { "kylechui/nvim-surround", event = "VeryLazy", config = true },
  { "mcauley-penney/tidy.nvim", event = "BufWritePre", config = true },

  -- Extra quality of life
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
})

-- === Neovim core settings ===
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes:1"
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.updatetime = 200
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 10
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.shortmess:append("cI")

-- === Keymaps ===
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- LSP keymaps on attach
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local buf = ev.buf
    local map = function(m, lhs, rhs) vim.keymap.set(m, lhs, rhs, { buffer = buf }) end
    map("n", "gd", vim.lsp.buf.definition)
    map("n", "gD", vim.lsp.buf.declaration)
    map("n", "gr", vim.lsp.buf.references)
    map("n", "gi", vim.lsp.buf.implementation)
    map("n", "K",  vim.lsp.buf.hover)
    map("n", "<leader>ca", vim.lsp.buf.code_action)
    map("n", "<leader>rn", vim.lsp.buf.rename)
    map("n", "<leader>D", vim.lsp.buf.type_definition)
  end,
})

-- === Custom functions for systems programming ===

-- 1. Build & run current C/Zig/Rust file (single key!)
vim.keymap.set("n", "<leader>r", function()
  local ft = vim.bo.filetype
  local file = vim.fn.expand("%")
  local bin = vim.fn.expand("%:t:r")

  local cmd
  if ft == "c" or ft == "cpp" then
    cmd = string.format("clang %s -o %s -Wall -Wextra -O2 -lm && ./%s", file, bin, bin)
  elseif ft == "rust" then
    cmd = "cargo run --quiet"
  elseif ft == "zig" then
    cmd = string.format("zig run %s", file)
  else
    print("No run command for filetype: " .. ft)
    return
  end

  vim.cmd("split | terminal " .. cmd)
  vim.api.nvim_feedkeys("i", "n", false)  -- enter terminal-insert mode
end, { desc = "Build & Run current file" })

-- 2. Quick compile & run with custom flags (prompt)
vim.keymap.set("n", "<leader>R", function()
  local file = vim.fn.expand("%")
  local flags = vim.fn.input("Compile flags: ", "-Wall -Wextra -O2 -g ")
  local bin = "/tmp/" .. vim.fn.fnamemodify(file, ":t:r")
  vim.cmd("silent !clang " .. file .. " " .. flags .. " -o " .. bin .. " && " .. bin)
end, { desc = "Quick compile & run C with custom flags" })

-- 3. Insert common headers / attributes
vim.keymap.set("n", "<leader>ih", function()
  local ft = vim.bo.filetype
  if ft == "c" or ft == "cpp" then
    vim.api.nvim_put({ "#include <stdio.h>", "#include <stdlib.h>", "#include <string.h>", "" }, "l", true, true)
  elseif ft == "rust" then
    vim.api.nvim_put({ '#[allow(dead_code)]', '#[allow(unused_variables)]', '#[allow(unused_mut)]' }, "l", true, true)
  elseif ft == "zig" then
    vim.api.nvim_put({ "const std = @import(\"std\");", "const print = std.debug.print;", "" }, "l", true, true)
  end
end, { desc = "Insert common headers/imports" })

-- 4. Toggle relative/absolute line numbers (great for yanking exact lines)
vim.keymap.set("n", "<leader>N", function()
  vim.o.relativenumber = not vim.o.relativenumber
end, { desc = "Toggle relative numbers" })

-- 5. Open current file's directory in system file manager
vim.keymap.set("n", "<leader>E", ":silent !xdg-open %:p:h<CR>", { desc = "Open folder in file manager" })

print("Ultimate C/Rust/Zig config loaded – <leader>r to run!")
