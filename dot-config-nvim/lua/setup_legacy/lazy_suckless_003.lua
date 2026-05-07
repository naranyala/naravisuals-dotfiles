
-- ~/.config/nvim/init.lua

-- Set leader key
vim.g.mapleader = " "

-- Install lazy.nvim if not present
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

-- Load plugins with lazy.nvim
require("lazy").setup({

	require("./_shared/missing_native_apis"),
	require("./_shared/tpope_goodies"),
    require("./_shared/lualine_and_theme"),

  -- Essential plugins
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "javascript", "typescript", "html", "css" },
        highlight = { enable = true },
      })
    end,
  },
  -- {
  --   "neovim/nvim-lspconfig",
  --   config = function()
  --     local lspconfig = require("lspconfig")
  --     lspconfig.tsserver.setup({})
  --     lspconfig.html.setup({})
  --     lspconfig.cssls.setup({})
  --   end,
  -- },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
  -- Ergonomic plugins
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })
    end,
  },
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },
}, {
  install = { colorscheme = { "habamax" } },
  ui = { border = "rounded" },
})

-- Basic editor settings
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

-- Keymaps for navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase split height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease split height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease split width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase split width" })

-- Keymaps for file operations
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>x", ":x<CR>", { desc = "Save and quit" })
-- vim.keymap.set("n", "<leader>e", ":e ~/<CR>", { desc = "Open file" })
vim.keymap.set("n", "<leader>t", ":terminal<CR>", { desc = "Open terminal" })
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Keymaps for quickfix/location list
vim.keymap.set("n", "<leader>cn", ":cnext<CR>", { desc = "Next quickfix item" })
vim.keymap.set("n", "<leader>cp", ":cprev<CR>", { desc = "Previous quickfix item" })
vim.keymap.set("n", "<leader>ln", ":lnext<CR>", { desc = "Next location list item" })
vim.keymap.set("n", "<leader>lp", ":lprev<CR>", { desc = "Previous location list item" })

-- Custom functions
function ToggleRelativeNumbers()
  if vim.opt.relativenumber:get() then
    vim.opt.relativenumber = false
  else
    vim.opt.relativenumber = true
  end
end

function CreateFileAndParents()
  local file = vim.fn.input("New file: ")
  if file ~= "" then
    local dir = vim.fn.fnamemodify(file, ":p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
    vim.cmd("e " .. file)
  end
end

function ToggleSpellCheck()
  if vim.opt.spell:get() then
    vim.opt.spell = false
  else
    vim.opt.spell = true
  end
end

function DeleteBuffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" then
    vim.cmd("enew")
  else
    vim.cmd("bd")
  end
end

-- Keymaps for custom functions
vim.keymap.set("n", "<leader>rn", ToggleRelativeNumbers, { desc = "Toggle relative numbers" })
vim.keymap.set("n", "<leader>cf", CreateFileAndParents, { desc = "Create file (with parents)" })
vim.keymap.set("n", "<leader>sc", ToggleSpellCheck, { desc = "Toggle spell check" })
vim.keymap.set("n", "<leader>bd", DeleteBuffer, { desc = "Delete buffer" })
