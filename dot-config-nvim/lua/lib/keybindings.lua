vim.api.nvim_set_keymap('n', '<leader>n', ':lua ToggleLineNumbers()<CR>', { noremap = true })

function ToggleLineNumbers()
  if vim.wo.number then
    vim.wo.number = false
    vim.wo.relativenumber = false
  else
    vim.wo.number = true
    vim.wo.relativenumber = true
  end
end

vim.api.nvim_set_keymap('n', '<A-j>', ':lua MoveLineDown()<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<A-k>', ':lua MoveLineUp()<CR>', { noremap = true })

function MoveLineDown()
  local line = vim.fn.line('.')
  local total_lines = vim.fn.line('$')
  if line ~= total_lines then
    vim.cmd('m +1')
  end
end

function MoveLineUp()
  local line = vim.fn.line('.')
  if line ~= 1 then
    vim.cmd('m -2')
  end
end

vim.api.nvim_set_keymap('n', '<leader>d', ':lua DuplicateLine()<CR>', { noremap = true })

function DuplicateLine()
  vim.cmd('t .')
end

vim.api.nvim_set_keymap('n', '<leader>vs', ':lua OpenFileVSplit()<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>hs', ':lua OpenFileHSplit()<CR>', { noremap = true })

function OpenFileVSplit()
  vim.cmd('vsplit')
  vim.cmd('Explore')
end

function OpenFileHSplit()
  vim.cmd('split')
  vim.cmd('Explore')
end

vim.api.nvim_set_keymap('n', '<leader>h', ':lua ToggleHighlightSearch()<CR>', { noremap = true })

function ToggleHighlightSearch()
  if vim.v.hlsearch == 1 then
    vim.cmd('set nohlsearch')
  else
    vim.cmd('set hlsearch')
  end
end

vim.api.nvim_set_keymap('n', '<leader>m', ':lua MaximizeWindow()<CR>', { noremap = true })

function MaximizeWindow()
  vim.cmd('only')
end

vim.api.nvim_set_keymap('n', '<leader>wa', ':lua SaveAllBuffers()<CR>', { noremap = true })

function SaveAllBuffers()
  vim.cmd('wa')
end

vim.api.nvim_set_keymap('n', '<leader>f', ':lua FormatBuffer()<CR>', { noremap = true })

function FormatBuffer()
  vim.lsp.buf.format()
end

vim.api.nvim_set_keymap('n', '<leader>w', ':lua ToggleWrap()<CR>', { noremap = true })

function ToggleWrap()
  if vim.wo.wrap then
    vim.wo.wrap = false
  else
    vim.wo.wrap = true
  end
end

vim.api.nvim_set_keymap('n', '<leader>e', ':lua ToggleNvimTree()<CR>', { noremap = true })

function ToggleNvimTree()
  require('nvim-tree.api').tree.toggle()
end

vim.api.nvim_set_keymap('n', '<leader>t', ':lua OpenTerminal()<CR>', { noremap = true })

function OpenTerminal()
  vim.cmd('terminal')
end

vim.api.nvim_set_keymap('n', '<leader>bo', ':lua CloseOtherBuffers()<CR>', { noremap = true })

function CloseOtherBuffers()
  vim.cmd('%bd|e#')
end

vim.api.nvim_set_keymap('n', '<leader>s', ':lua ToggleSpellCheck()<CR>', { noremap = true })

function ToggleSpellCheck()
  if vim.wo.spell then
    vim.wo.spell = false
  else
    vim.wo.spell = true
  end
end

vim.api.nvim_set_keymap('n', '<leader>bn', ':lua MoveToNextBuffer()<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>bp', ':lua MoveToPreviousBuffer()<CR>', { noremap = true })

function MoveToNextBuffer()
  vim.cmd('bnext')
end

function MoveToPreviousBuffer()
  vim.cmd('bprevious')
end

vim.api.nvim_set_keymap('n', '<leader>>', ':lua ResizeWindowRight()<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader><', ':lua ResizeWindowLeft()<CR>', { noremap = true })

function ResizeWindowRight()
  vim.cmd('vertical resize +5')
end

function ResizeWindowLeft()
  vim.cmd('vertical resize -5')
end
