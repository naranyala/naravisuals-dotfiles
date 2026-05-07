
function ToggleRelativeNumber()
  if vim.wo.relativenumber then
    vim.wo.relativenumber = false
    vim.wo.number = true
  else
    vim.wo.relativenumber = true
    vim.wo.number = true
  end
end

vim.api.nvim_set_keymap('n', '<leader>rn', ':lua ToggleRelativeNumber()<CR>', { noremap = true, silent = true })


function CopyFilePath()
  local filepath = vim.fn.expand('%:p')
  vim.fn.setreg('+', filepath)
  print("Copied: " .. filepath)
end

vim.api.nvim_set_keymap('n', '<leader>fp', ':lua CopyFilePath()<CR>', { noremap = true, silent = true })


function ReloadConfig()
  for name,_ in pairs(package.loaded) do
    if name:match('^user') then
      package.loaded[name] = nil
    end
  end
  dofile(vim.env.MYVIMRC)
  print("Config reloaded!")
end

vim.api.nvim_set_keymap('n', '<leader>rc', ':lua ReloadConfig()<CR>', { noremap = true, silent = true })


function ToggleSpell()
  vim.opt.spell = not vim.opt.spell:get()
  print("Spell check: " .. tostring(vim.opt.spell:get()))
end

vim.api.nvim_set_keymap('n', '<leader>sp', ':lua ToggleSpell()<CR>', { noremap = true, silent = true })


function TrimWhitespace()
  local save_cursor = vim.fn.getpos(".")
  vim.cmd([[%s/\s\+$//e]])
  vim.fn.setpos(".", save_cursor)
  print("Whitespace trimmed")
end

vim.api.nvim_set_keymap('n', '<leader>tw', ':lua TrimWhitespace()<CR>', { noremap = true, silent = true })


function ToggleTransparency()
  if vim.g.transparent_enabled then
    vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
    vim.g.transparent_enabled = false
    print("Transparency disabled")
  else
    vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
    vim.g.transparent_enabled = true
    print("Transparency enabled")
  end
end

vim.api.nvim_set_keymap('n', '<leader>tt', ':lua ToggleTransparency()<CR>', { noremap = true, silent = true })


function ToggleWrap()
  vim.wo.wrap = not vim.wo.wrap
  print("Wrap mode: " .. tostring(vim.wo.wrap))
end

vim.api.nvim_set_keymap('n', '<leader>ww', ':lua ToggleWrap()<CR>', { noremap = true, silent = true })


function OpenTerminalSplit()
  vim.cmd("split term://$SHELL")
end

vim.api.nvim_set_keymap('n', '<leader>ts', ':lua OpenTerminalSplit()<CR>', { noremap = true, silent = true })


function SaveAndSource()
  vim.cmd("write")
  vim.cmd("source %")
  print("File saved and sourced!")
end

vim.api.nvim_set_keymap('n', '<leader>ss', ':lua SaveAndSource()<CR>', { noremap = true, silent = true })


function ToggleCursorLine()
  vim.wo.cursorline = not vim.wo.cursorline
  print("Cursorline: " .. tostring(vim.wo.cursorline))
end

vim.api.nvim_set_keymap('n', '<leader>cl', ':lua ToggleCursorLine()<CR>', { noremap = true, silent = true })


function YankWord()
  local word = vim.fn.expand("<cword>")
  vim.fn.setreg('+', word)
  print("Yanked word: " .. word)
end

vim.api.nvim_set_keymap('n', '<leader>yw', ':lua YankWord()<CR>', { noremap = true, silent = true })


function TogglePaste()
  vim.o.paste = not vim.o.paste
  print("Paste mode: " .. tostring(vim.o.paste))
end

vim.api.nvim_set_keymap('n', '<leader>pp', ':lua TogglePaste()<CR>', { noremap = true, silent = true })


function CloseOtherBuffers()
  local current = vim.fn.bufnr('%')
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and buf ~= current then
      vim.api.nvim_buf_delete(buf, {})
    end
  end
  print("Closed all other buffers")
end

vim.api.nvim_set_keymap('n', '<leader>bo', ':lua CloseOtherBuffers()<CR>', { noremap = true, silent = true })


function ToggleSearchHighlight()
  vim.o.hlsearch = not vim.o.hlsearch
  print("Search highlight: " .. tostring(vim.o.hlsearch))
end

vim.api.nvim_set_keymap('n', '<leader>sh', ':lua ToggleSearchHighlight()<CR>', { noremap = true, silent = true })


function ToggleColorColumn()
  if vim.wo.colorcolumn ~= "" then
    vim.wo.colorcolumn = ""
    print("Colorcolumn disabled")
  else
    vim.wo.colorcolumn = "80"
    print("Colorcolumn set at 80")
  end
end

vim.api.nvim_set_keymap('n', '<leader>cc', ':lua ToggleColorColumn()<CR>', { noremap = true, silent = true })


function OpenInExplorer()
  local path = vim.fn.expand('%:p:h')
  if vim.fn.has('mac') == 1 then
    vim.fn.jobstart({'open', path})
  elseif vim.fn.has('unix') == 1 then
    vim.fn.jobstart({'xdg-open', path})
  elseif vim.fn.has('win32') == 1 then
    vim.fn.jobstart({'explorer', path})
  end
  print("Opened folder: " .. path)
end

vim.api.nvim_set_keymap('n', '<leader>fe', ':lua OpenInExplorer()<CR>', { noremap = true, silent = true })


function ToggleBackground()
  if vim.o.background == "dark" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
  print("Background set to: " .. vim.o.background)
end

vim.api.nvim_set_keymap('n', '<leader>bg', ':lua ToggleBackground()<CR>', { noremap = true, silent = true })


function InsertDateTime()
  local dt = os.date("%Y-%m-%d %H:%M:%S")
  vim.api.nvim_put({dt}, 'c', true, true)
end

vim.api.nvim_set_keymap('n', '<leader>dt', ':lua InsertDateTime()<CR>', { noremap = true, silent = true })


function ToggleListChars()
  vim.wo.list = not vim.wo.list
  print("Listchars: " .. tostring(vim.wo.list))
end

vim.api.nvim_set_keymap('n', '<leader>lc', ':lua ToggleListChars()<CR>', { noremap = true, silent = true })


function ReloadBuffer()
  vim.cmd("edit!")
  print("Buffer reloaded from disk")
end

vim.api.nvim_set_keymap('n', '<leader>rb', ':lua ReloadBuffer()<CR>', { noremap = true, silent = true })


function ToggleMouse()
  if vim.o.mouse == "a" then
    vim.o.mouse = ""
    print("Mouse disabled")
  else
    vim.o.mouse = "a"
    print("Mouse enabled")
  end
end

vim.api.nvim_set_keymap('n', '<leader>ms', ':lua ToggleMouse()<CR>', { noremap = true, silent = true })


function DiffSaved()
  vim.cmd("diffthis")
  vim.cmd("vsplit | edit # | diffthis")
end

vim.api.nvim_set_keymap('n', '<leader>df', ':lua DiffSaved()<CR>', { noremap = true, silent = true })


function SimpleExplorer()
  vim.cmd("vsplit")
  vim.cmd("Ex")
end

vim.api.nvim_set_keymap('n', '<leader>e', ':lua SimpleExplorer()<CR>', { noremap = true, silent = true })




function NextBuffer()
  vim.cmd("bnext")
end

function PrevBuffer()
  vim.cmd("bprevious")
end

vim.api.nvim_set_keymap('n', '<leader>bn', ':lua NextBuffer()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>bp', ':lua PrevBuffer()<CR>', { noremap = true, silent = true })


function FuzzyFind()
  local file = vim.fn.input("Find file > ")
  if file ~= "" then
    vim.cmd("find " .. file)
  end
end

vim.api.nvim_set_keymap('n', '<leader>ff', ':lua FuzzyFind()<CR>', { noremap = true, silent = true })


function GitStatus()
  vim.cmd("vsplit | term git status")
end

vim.api.nvim_set_keymap('n', '<leader>gs', ':lua GitStatus()<CR>', { noremap = true, silent = true })


function MarkdownPreview()
  local file = vim.fn.expand('%:p')
  vim.fn.jobstart({"xdg-open", file})
  print("Preview opened in browser")
end

vim.api.nvim_set_keymap('n', '<leader>mp', ':lua MarkdownPreview()<CR>', { noremap = true, silent = true })


function ToggleComment()
  local line = vim.fn.getline('.')
  if line:match("^%s*//") then
    vim.fn.setline('.', line:gsub("^%s*//", "", 1))
  else
    vim.fn.setline('.', "// " .. line)
  end
end

vim.api.nvim_set_keymap('n', '<leader>/', ':lua ToggleComment()<CR>', { noremap = true, silent = true })


function SaveSession()
  local session = vim.fn.input("Session name > ")
  if session ~= "" then
    vim.cmd("mksession! " .. session .. ".vim")
    print("Session saved: " .. session)
  end
end

function LoadSession()
  local session = vim.fn.input("Load session > ")
  if session ~= "" then
    vim.cmd("source " .. session .. ".vim")
    print("Session loaded: " .. session)
  end
end

vim.api.nvim_set_keymap('n', '<leader>ss', ':lua SaveSession()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sl', ':lua LoadSession()<CR>', { noremap = true, silent = true })


function SurroundWord(char)
  local word = vim.fn.expand("<cword>")
  vim.fn.setreg('.', word)
  vim.cmd("normal ciw" .. char .. word .. char)
end

vim.api.nvim_set_keymap('n', '<leader>s"', ':lua SurroundWord("\"")<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', "<leader>s'", ":lua SurroundWord(\"'\")<CR>", { noremap = true, silent = true })


function SimpleStatusline()
  vim.o.statusline = "%f %y %m %= %l:%c [%p%%]"
end

SimpleStatusline()


function ToggleFloatTerm()
  if vim.g.float_term_open then
    vim.cmd("bd! term")
    vim.g.float_term_open = false
  else
    vim.cmd("botright split term://$SHELL")
    vim.g.float_term_open = true
  end
end

vim.api.nvim_set_keymap('n', '<leader>tt', ':lua ToggleFloatTerm()<CR>', { noremap = true, silent = true })


function HighlightTodos()
  vim.cmd("syntax match Todo /TODO/")
  vim.cmd("syntax match Fixme /FIXME/")
  vim.cmd("highlight Todo ctermfg=Yellow guifg=Yellow")
  vim.cmd("highlight Fixme ctermfg=Red guifg=Red")
end

HighlightTodos()


function QuickNote()
  vim.cmd("tabnew ~/notes.md")
  print("Opened notes.md")
end

vim.api.nvim_set_keymap('n', '<leader>nn', ':lua QuickNote()<CR>', { noremap = true, silent = true })


function ToggleIndentGuides()
  if vim.g.indent_guides_enabled then
    vim.cmd("highlight clear SpecialKey")
    vim.g.indent_guides_enabled = false
    print("Indent guides disabled")
  else
    vim.cmd("highlight SpecialKey ctermfg=DarkGray guifg=DarkGray")
    vim.g.indent_guides_enabled = true
    print("Indent guides enabled")
  end
end

vim.api.nvim_set_keymap('n', '<leader>ig', ':lua ToggleIndentGuides()<CR>', { noremap = true, silent = true })


function InsertPair(open, close)
  vim.api.nvim_feedkeys(open .. close .. "<Left>", "i", true)
end

vim.api.nvim_set_keymap('i', '(', '()<Left>', { noremap = true })
vim.api.nvim_set_keymap('i', '[', '[]<Left>', { noremap = true })
vim.api.nvim_set_keymap('i', '{', '{}<Left>', { noremap = true })
vim.api.nvim_set_keymap('i', '"', '""<Left>', { noremap = true })


function StartupDashboard()
  vim.cmd("echo 'Welcome to Neovim, Fudzer!'")
  vim.cmd("echo 'Press <leader>ff to find files'")
  vim.cmd("echo 'Press <leader>nn for notes'")
end

vim.api.nvim_create_autocmd("VimEnter", { callback = StartupDashboard })


