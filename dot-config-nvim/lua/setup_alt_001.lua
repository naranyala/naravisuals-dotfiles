-- ~/.config/nvim/init.lua
-- Minimal, opinionated config for C / Rust / Zig systems programming.
-- No DAP, no fluff, extra custom helpers at the bottom.

----------------------------------------------------------
-- 1. VIM OPTIONS
----------------------------------------------------------
vim.g.mapleader      = ' '
vim.g.maplocalleader = ' '

vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.signcolumn     = 'yes'
vim.opt.cursorline     = true
vim.opt.expandtab      = false        -- tabs for kernel / zig style
vim.opt.shiftwidth     = 4
vim.opt.tabstop        = 4
vim.opt.softtabstop    = 4
vim.opt.smartindent    = true
vim.opt.wrap           = false
vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.undofile       = true
vim.opt.swapfile       = false
vim.opt.termguicolors  = true
vim.opt.completeopt    = { 'menu', 'menuone', 'noselect' }
vim.opt.shortmess:append 'c'

----------------------------------------------------------
-- 2. LAZY.NVIM BOOTSTRAP
----------------------------------------------------------
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath
  }
end
vim.opt.rtp:prepend(lazypath)

----------------------------------------------------------
-- 3. PLUGIN SPEC
----------------------------------------------------------
require('lazy').setup({

  require("_shared_other_modules"),
  require("_shared_mason_lsp_treesitter"),
  -- require("_shared_mason_lsp_treesitter2"),
  -- require("_shared_mason_lsp_treesitter3"),

  -- colours & eye-candy
  { 'folke/tokyonight.nvim', priority = 1000, config = function() vim.cmd.colorscheme 'tokyonight-night' end },
  -- { 'nvim-lualine/lualine.nvim',  opts = { theme = 'tokyonight' } },
  { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {} },

  -- finder
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find files' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>',  desc = 'Live grep' },
      { '<leader>fb', '<cmd>Telescope buffers<cr>',    desc = 'Buffers' },
    },
    opts = {},
  },


  -- quality-of-life
  { 'tpope/vim-sleuth' },               -- detect indent settings
  { 'numToStr/Comment.nvim', config = function() require('Comment').setup() end },
  { 'tpope/vim-eunuch' },               -- :Move :Rename :SudoWrite
}, { ui = { border = 'rounded' } })

----------------------------------------------------------
-- 4. SMALL KEYMAP OVERRIDES
----------------------------------------------------------
-- window nav
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- quick save / quit
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>')
vim.keymap.set('n', '<leader>q', '<cmd>q<cr>')

----------------------------------------------------------
-- 5. CUSTOM FUNCTIONS
----------------------------------------------------------
-- 5a) Toggle between header/source (C/C++/Zig)
local function toggle_hpp_cpp()
  local name = vim.fn.expand '%:t'
  local base, ext = name:match '^([^%.]+)%.(.*)$'
  if not base then return end
  local partner = (ext == 'h' or ext == 'hpp') and 'c' or (ext == 'c' and 'h')
  if ext == 'zig' then partner = (base:match '_test$') and base:gsub('_test$', '') or base .. '_test' end
  local partner_file = vim.fn.expand '%:p:h' .. '/' .. base .. '.' .. (partner or 'h')
  if vim.fn.filereadable(partner_file) == 1 then
    vim.cmd.edit(partner_file)
  else
    vim.notify('Partner file not found', vim.log.levels.WARN)
  end
end
vim.keymap.set('n', '<leader>a', toggle_hpp_cpp, { desc = 'Alternate header/source' })

-- 5b) Insert or update a license header if missing
local license_text = {
  '/*',
  ' * Copyright (c) ' .. os.date '%Y' .. ' [author]',
  ' * SPDX-License-Identifier: MIT',
  ' */',
  '',
}
local function ensure_license()
  local lines = vim.api.nvim_buf_get_lines(0, 0, 4, false)
  if lines[1]:match '^/%*' and lines[3]:match 'SPDX' then
    vim.notify 'License already present'
    return
  end
  vim.api.nvim_buf_set_lines(0, 0, 0, false, license_text)
end
vim.keymap.set('n', '<leader>L', ensure_license, { desc = 'Add MIT license header' })

-- 5c) Strip trailing whitespace on save for C/C++/Rust/Zig
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.c', '*.h', '*.cpp', '*.hpp', '*.rs', '*.zig' },
  callback = function()
    local view = vim.fn.winsaveview()
    vim.cmd [[keeppatterns %s/\s\+$//e]]
    vim.fn.winrestview(view)
  end,
})

----------------------------------------------------------
-- 6. PROJECT-LOCAL COMPILATION DATABASE
----------------------------------------------------------
-- Automatically set cwd to the folder that contains compile_commands.json
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local root = vim.fs.find('compile_commands.json', { upward = true, type = 'file', path = vim.fn.expand '%:p' })[1]
    if root then vim.cmd.cd(vim.fn.fnamemodify(root, ':h')) end
  end,
})
