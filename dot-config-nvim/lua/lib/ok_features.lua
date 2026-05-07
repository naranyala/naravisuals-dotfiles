function GoToDefinition()
    -- Check if an LSP client is attached to the current buffer
    if next(vim.lsp.get_active_clients()) then
        -- Execute the built-in LSP command to go to definition
        vim.lsp.buf.definition()
    else
        -- Fallback to Ctags-style navigation if no LSP is available
        -- This uses the standard Vim tag search command
        vim.cmd('tag ' .. vim.fn.expand('<cword>'))
    end
end

function FindReferences()
    -- Check if an LSP client is attached
    if next(vim.lsp.get_active_clients()) then
        -- Execute the built-in LSP command to find references
        vim.lsp.buf.references()
    else
        print("No active LSP client for finding references.")
    end
end

local opts = { noremap = true, silent = true }

-- Go to Definition
vim.keymap.set('n', 'gd', GoToDefinition, opts)

-- Find References
vim.keymap.set('n', 'gr', FindReferences, opts)

function QuickGrep()
  local word = vim.fn.input("Grep for > ")
  if word ~= "" then
    vim.cmd("vimgrep /"..word.."/gj **/*")
    vim.cmd("copen")
  end
end

vim.api.nvim_set_keymap('n', '<leader>fg', ':lua QuickGrep()<CR>', { noremap = true, silent = true })

-- Function to toggle cursor crosshair
local crosshair_enabled = false

function ToggleCursorCrosshair()
  crosshair_enabled = not crosshair_enabled
  
  if crosshair_enabled then
    vim.opt.cursorline = true
    vim.opt.cursorcolumn = true
    vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#404040' })
    vim.api.nvim_set_hl(0, 'CursorColumn', { bg = '#404040' })
    print("Cursor crosshair enabled")
  else
    vim.opt.cursorline = false
    vim.opt.cursorcolumn = false
    print("Cursor crosshair disabled")
  end
end

-- Create a command to call the function
vim.api.nvim_create_user_command('ToggleCrosshair', ToggleCursorCrosshair, {})

-- Map it to a key (e.g., <leader>ch for "crosshair")
vim.keymap.set('n', '<leader>ch', ToggleCursorCrosshair, { desc = 'Toggle cursor crosshair' })


-- ToggleWrap function to switch between 'wrap' and 'nowrap'
function ToggleWrap()
  if vim.wo.wrap then
    vim.wo.wrap = false
    print("Line wrapping disabled")
  else
    vim.wo.wrap = true
    print("Line wrapping enabled")
  end
end

-- Create a command for the function
vim.api.nvim_create_user_command("ToggleWrap", ToggleWrap, {})

-- Optional: Add a keymap (e.g., <leader>w)
vim.keymap.set("n", "<leader>w", ToggleWrap, { desc = "Toggle line wrap" })


-- Generate one paragraph of lorem ipsum
function lorem_paragraph()
  return [[Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
  Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. 
  Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris 
  nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in 
  reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla 
  pariatur. Excepteur sint occaecat cupidatat non proident, sunt in 
  culpa qui officia deserunt mollit anim id est laborum.]]
end


-- init.lua or plugin setup
vim.api.nvim_create_user_command("LoremIpsum", function()
  local text = lorem_paragraph()
  vim.api.nvim_put({ text }, "l", true, true)
end, {})


-- Toggle colorcolumn between "80" and ""
function toggle_colorcolumn()
  local current = vim.opt.colorcolumn:get()
  if current[1] == "" or current[1] == nil then
    vim.opt.colorcolumn = "80"   -- enable at column 80
    -- print("Colorcolumn enabled at 80")
  else
    vim.opt.colorcolumn = ""     -- disable
    -- print("Colorcolumn disabled")
  end
end


toggle_colorcolumn()

vim.api.nvim_create_user_command("ToggleColorColumn", function()
    toggle_colorcolumn()
end, {})
