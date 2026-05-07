function ToggleTSHighlight()
  local ts = vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()]
  if ts then
    vim.cmd("TSDisable highlight")
    print("Treesitter highlighting OFF")
  else
    vim.cmd("TSEnable highlight")
    print("Treesitter highlighting ON")
  end
end

vim.keymap.set("n", "<leader>tt", ToggleTSHighlight, { desc = "Toggle Treesitter highlighting" })


-- In your init.lua
-- vim.filetype.add({
--   extension = {
--     c3 = "c",  -- treat .c3 files as C
--   },
-- })


vim.filetype.add({
  extension = {
    c3 = "c3",
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "c3",
  callback = function()
    vim.cmd([[
      " --- Keywords ---
      syntax keyword c3Keyword fn let struct enum union module import typedef sizeof alignof typeof
      syntax keyword c3Conditional if else switch case default
      syntax keyword c3Repeat for foreach while do break continue return
      syntax keyword c3Boolean true false null
      syntax keyword c3Type i8 i16 i32 i64 u8 u16 u32 u64 f32 f64 bool string void char auto int float uint double
      syntax keyword c3Modifier const static inline extern volatile restrict
      syntax keyword c3Attribute @align @deprecated @test @inline @extern @packed
      syntax keyword c3Error try catch throw panic
      syntax keyword c3Namespace using namespace io

      " --- Operators ---
      syntax match c3Operator "[+\-*/%=&|<>!]=\?"
      syntax match c3Operator "&&\||"

      " --- Numbers ---
      syntax match c3Number "\<\d\+\>"
      syntax match c3Float "\<\d\+\.\d\+\([eE][-+]\d\+\)\?\>"

      " --- Strings ---
      syntax region c3String start=+"+ skip=+\\.+ end=+"+

      " --- Comments ---
      syntax region c3Comment start="//" end="$"
      syntax region c3Comment start="/\*" end="\*/"

      " --- Highlight links ---
      highlight link c3Keyword Keyword
      highlight link c3Conditional Conditional
      highlight link c3Repeat Repeat
      highlight link c3Boolean Boolean
      highlight link c3Type Type
      highlight link c3Modifier StorageClass
      highlight link c3Attribute PreProc
      highlight link c3Error Exception
      highlight link c3Namespace Identifier
      highlight link c3Operator Operator
      highlight link c3Number Number
      highlight link c3Float Float
      highlight link c3String String
      highlight link c3Comment Comment
    ]])
  end,
})



-- Set leader key (if not already set)
vim.g.mapleader = ' '

-- Custom function: Toggle diagnostics (errors/warnings)
local function toggle_diagnostics()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
  print('Diagnostics ' .. (vim.diagnostic.is_enabled() and 'enabled' or 'disabled'))
end

-- Custom function: Smart auto-format on save (requires null-ls or LSP)
local function format_on_save()
  if vim.bo.filetype == 'lua' or vim.bo.filetype == 'javascript' or vim.bo.filetype == 'python' then
    vim.lsp.buf.format({ async = false })
  end
end

-- Autocommand: Auto-format on save for specific filetypes
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.lua', '*.js', '*.py' },
  callback = format_on_save,
})

-- Autocommand: Auto-enter insert mode in terminal
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  command = 'startinsert',
})

-- Autocommand: Smart indentation for new lines
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*',
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions
      - 'o' -- Don't continue comments with o/O
      + 'r' -- Insert comment leader after Enter
  end,
})

-- Keymaps
-- Clear search highlights on Esc (normal mode)
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })

-- Toggle diagnostics
vim.keymap.set('n', '<leader>d', toggle_diagnostics, { desc = 'Toggle diagnostics' })

-- Smart splits navigation (Ctrl + h/j/k/l)
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left split' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom split' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to top split' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right split' })

-- Close buffer but keep window layout
vim.keymap.set('n', '<leader>q', '<cmd>bp|bd #<CR>', { desc = 'Close buffer and keep window' })

-- Quick save with Ctrl + s
vim.keymap.set('n', '<C-s>', '<cmd>w<CR>', { desc = 'Save file' })
vim.keymap.set('i', '<C-s>', '<Esc><cmd>w<CR>', { desc = 'Save file (insert mode)' })

-- Toggle relative line numbers
vim.wo.relativenumber = true
vim.keymap.set('n', '<leader>rn', function()
  vim.wo.relativenumber = not vim.wo.relativenumber
end, { desc = 'Toggle relative line numbers' })
