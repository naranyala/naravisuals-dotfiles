
-----------------------------------------------------------
-- bootstrap lazy.nvim
-----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------
-- suckless defaults
-----------------------------------------------------------
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.mouse = "a"

-- better defaults
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.clipboard = "unnamedplus"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-----------------------------------------------------------
-- plugin setup
-----------------------------------------------------------
require("lazy").setup({
	require("./_shared/missing_native_apis"),
	require("./_shared/tpope_goodies"),
    require("./_shared/lualine_and_theme"),

  { -- telescope
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  { -- treesitter
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },


  ---------------------------------------------------------
  -- tiny ergonomic plugins (optional but lightweight)
  ---------------------------------------------------------
  { "echasnovski/mini.comment", version = "*", config = true },
  { "echasnovski/mini.surround", version = "*", config = true },
  { "echasnovski/mini.move", version = "*", config = true },
})

-----------------------------------------------------------
-- ergonomic helpers
-----------------------------------------------------------
local function nmap(lhs, rhs)
  vim.keymap.set("n", lhs, rhs, { silent = true })
end
local function imap(lhs, rhs)
  vim.keymap.set("i", lhs, rhs, { silent = true })
end

-----------------------------------------------------------
-- toggles
-----------------------------------------------------------

-- toggle relative number
nmap("<leader>tr", function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end)

-- toggle diagnostics
local diag_enabled = true
nmap("<leader>td", function()
  diag_enabled = not diag_enabled
  if diag_enabled then vim.diagnostic.enable() else vim.diagnostic.disable() end
end)

-- toggle spell
nmap("<leader>ts", function()
  vim.opt.spell = not vim.opt.spell:get()
end)

-----------------------------------------------------------
-- custom functions (pure Lua)
-----------------------------------------------------------

-- fuzzy file picker (no telescope required)
nmap("<leader>p", function()
  local files = vim.fn.systemlist("fd .")
  vim.ui.select(files, { prompt = "File:" }, function(choice)
    if choice then vim.cmd("edit " .. choice) end
  end)
end)

-- buffer navigation
nmap("<leader>bn", ":bnext<CR>")
nmap("<leader>bp", ":bprevious<CR>")
nmap("<leader>bd", ":bdelete<CR>")

-- smart quit (kills last buffer then quits)
nmap("<leader>x", function()
  if #vim.fn.getbufinfo({ buflisted = 1 }) > 1 then
    vim.cmd("bdelete")
  else
    vim.cmd("q")
  end
end)

-- scratch buffer
nmap("<leader>ss", function()
  vim.cmd("enew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
end)

-----------------------------------------------------------
-- telescope keymaps
-----------------------------------------------------------
nmap("<leader>ff", "<cmd>Telescope find_files<CR>")
nmap("<leader>fg", "<cmd>Telescope live_grep<CR>")
nmap("<leader>fb", "<cmd>Telescope buffers<CR>")
nmap("<leader>fh", "<cmd>Telescope help_tags<CR>")

-----------------------------------------------------------
-- windows
-----------------------------------------------------------
nmap("<leader>sv", "<C-w>v")
nmap("<leader>sh", "<C-w>s")

-----------------------------------------------------------
-- mini command palette (pure Lua)
-----------------------------------------------------------
nmap("<leader>cp", function()
  vim.ui.select({
    "Edit init.lua",
    "Reload config",
    "Toggle Diagnostics",
  }, { prompt = "Command:" }, function(choice)
    if choice == "Edit init.lua" then
      vim.cmd("edit ~/.config/nvim/init.lua")
    elseif choice == "Reload config" then
      dofile(vim.fn.stdpath("config") .. "/init.lua")
    elseif choice == "Toggle Diagnostics" then
      diag_enabled = not diag_enabled
      if diag_enabled then vim.diagnostic.enable() else vim.diagnostic.disable() end
    end
  end)
end)

-----------------------------------------------------------
-- basic autocmds
-----------------------------------------------------------
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 80 })
  end,
})
