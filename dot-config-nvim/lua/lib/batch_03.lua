

function ToggleLineNumbers()
  if vim.wo.relativenumber then
    vim.wo.number = true
    vim.wo.relativenumber = false
  else
    vim.wo.number = true
    vim.wo.relativenumber = true
  end
end


function NextBuffer()
  vim.cmd("bnext")
end

function PrevBuffer()
  vim.cmd("bprevious")
end

vim.keymap.set('n', '<leader>bn', NextBuffer, { desc = "Next buffer" })
vim.keymap.set('n', '<leader>bp', PrevBuffer, { desc = "Previous buffer" })

function ToggleTerminal()
  local term_buf = vim.fn.bufnr("$TERM_BUF")
  if term_buf == -1 then
    vim.cmd("split | term")
    vim.fn.setbufvar(vim.fn.bufnr(), "term_title", "Terminal")
  else
    vim.cmd("bdelete " .. term_buf)
  end
end

function CopyFilePath(mode)
  local path = vim.fn.expand("%:" .. (mode == "relative" and "." or ":p"))
  vim.fn.setreg("+", path)
  print("Copied: " .. path)
end

vim.keymap.set('n', '<leader>cf', function() CopyFilePath("full") end, { desc = "Copy full file path" })
vim.keymap.set('n', '<leader>cr', function() CopyFilePath("relative") end, { desc = "Copy relative file path" })

function ToggleSpellCheck()
  if vim.wo.spell then
    vim.wo.spell = false
  else
    vim.wo.spell = true
  end
end

function VisualReplace()
  local old_word = vim.fn.expand("<cword>")
  local new_word = vim.fn.input("Replace " .. old_word .. " with: ")
  if new_word ~= "" then
    vim.cmd("%s/" .. old_word .. "/" .. new_word .. "/g")
  end
end

vim.keymap.set('v', '<leader>r', VisualReplace, { desc = "Replace selected text" })

function ToggleWrap()
  if vim.wo.wrap then
    vim.wo.wrap = false
  else
    vim.wo.wrap = true
  end
end

function OpenConfig()
  vim.cmd("edit ~/.config/nvim/init.lua")
end

vim.keymap.set('n', '<leader>vc', OpenConfig, { desc = "Open Neovim config" })

function ClearSearch()
  vim.cmd("nohlsearch")
end

vim.keymap.set('n', '<leader>c', ClearSearch, { desc = "Clear search highlights" })

function ToggleZenMode()
  require("zen-mode").toggle()
end

vim.keymap.set('n', '<leader>z', ToggleZenMode, { desc = "Toggle Zen Mode" })

function ToggleTransparency()
  if vim.g.transparency_enabled then
    vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
    vim.g.transparency_enabled = false
  else
    vim.cmd("hi Normal guibg=#1e1e2e ctermbg=235")
    vim.g.transparency_enabled = true
  end
end

vim.keymap.set('n', '<leader>tt', ToggleTransparency, { desc = "Toggle transparency" })

function NextQuickFix()
  vim.cmd("cnext")
end

function PrevQuickFix()
  vim.cmd("cprev")
end

vim.keymap.set('n', '<leader>qn', NextQuickFix, { desc = "Next quickfix" })
vim.keymap.set('n', '<leader>qp', PrevQuickFix, { desc = "Previous quickfix" })

function InsertDate()
  local date = os.date("%Y-%m-%d")
  vim.api.nvim_put({ date }, "c", true, true)
end

function InsertTime()
  local time = os.date("%H:%M:%S")
  vim.api.nvim_put({ time }, "c", true, true)
end

vim.keymap.set('n', '<leader>id', InsertDate, { desc = "Insert date" })
vim.keymap.set('n', '<leader>it', InsertTime, { desc = "Insert time" })

function ToggleIndentGuides()
  local ok, blankline = pcall(require, "indent_blankline")
  if ok then
    if vim.g.indent_blankline_enabled then
      blankline.disable()
      vim.g.indent_blankline_enabled = false
    else
      blankline.enable()
      vim.g.indent_blankline_enabled = true
    end
  end
end

vim.keymap.set('n', '<leader>ti', ToggleIndentGuides, { desc = "Toggle indent guides" })

function OpenGitHubRepo()
  local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null | tr -d '\n'")
  if git_root ~= "" then
    local remote = vim.fn.system("git remote get-url origin 2>/dev/null | tr -d '\n'")
    if remote:match("github%.com") then
      local repo_url = remote:gsub("git@github%.com:", "https://github.com/"):gsub("%.git$", "")
      vim.fn.jobstart("open " .. repo_url, { detach = true })
    end
  end
end

vim.keymap.set('n', '<leader>gh', OpenGitHubRepo, { desc = "Open GitHub repo" })

function ToggleDiagnosticVirtualText()
  if vim.diagnostic.config().virtual_text then
    vim.diagnostic.config({ virtual_text = false })
  else
    vim.diagnostic.config({ virtual_text = true })
  end
end

vim.keymap.set('n', '<leader>td', ToggleDiagnosticVirtualText, { desc = "Toggle diagnostics" })

function ResizeSplitLeft()
  vim.cmd("vertical resize -2")
end

function ResizeSplitRight()
  vim.cmd("vertical resize +2")
end

function ResizeSplitUp()
  vim.cmd("resize -2")
end

function ResizeSplitDown()
  vim.cmd("resize +2")
end

vim.keymap.set('n', '<C-Left>', ResizeSplitLeft, { desc = "Resize split left" })
vim.keymap.set('n', '<C-Right>', ResizeSplitRight, { desc = "Resize split right" })
vim.keymap.set('n', '<C-Up>', ResizeSplitUp, { desc = "Resize split up" })
vim.keymap.set('n', '<C-Down>', ResizeSplitDown, { desc = "Resize split down" })

function ToggleColorColumn()
  if vim.wo.colorcolumn == "" then
    vim.wo.colorcolumn = "80"
  else
    vim.wo.colorcolumn = ""
  end
end


vim.keymap.set('n', '<leader>tc', ToggleColorColumn, { desc = "Toggle color column" })

function OpenRecentFiles()
  require("telescope.builtin").oldfiles()
end

vim.keymap.set('n', '<leader>fr', OpenRecentFiles, { desc = "Open recent files" })

function ToggleCursorLine()
  if vim.wo.cursorline then
    vim.wo.cursorline = false
  else
    vim.wo.cursorline = true
  end
end

vim.keymap.set('n', '<leader>tl', ToggleCursorLine, { desc = "Toggle cursor line" })

function OpenTerminalInDir()
  local dir = vim.fn.expand("%:p:h")
  vim.cmd("split | term cd " .. dir)
end

vim.keymap.set('n', '<leader>td', OpenTerminalInDir, { desc = "Open terminal in dir" })

function ToggleSignColumn()
  if vim.wo.signcolumn == "yes" then
    vim.wo.signcolumn = "no"
  else
    vim.wo.signcolumn = "yes"
  end
end

vim.keymap.set('n', '<leader>ts', ToggleSignColumn, { desc = "Toggle sign column" })

function OpenFileInDefaultApp()
  local file = vim.fn.expand("%:p")
  vim.fn.jobstart("open " .. file, { detach = true })
end

vim.keymap.set('n', '<leader>od', OpenFileInDefaultApp, { desc = "Open file in default app" })

function ToggleFoldColumn()
  if vim.wo.foldcolumn == "0" then
    vim.wo.foldcolumn = "1"
  else
    vim.wo.foldcolumn = "0"
  end
end

vim.keymap.set('n', '<leader>tf', ToggleFoldColumn, { desc = "Toggle fold column" })

function OpenLazy()
  vim.cmd("Lazy")
end

vim.keymap.set('n', '<leader>pl', OpenLazy, { desc = "Open Lazy plugin manager" })

function ToggleInlayHints()
  local ok, inlay = pcall(vim.lsp.inlay_hint, 0)
  if not ok then
    vim.notify("Inlay hints not supported for this LSP.", vim.log.levels.WARN)
  else
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }))
  end
end

vim.keymap.set('n', '<leader>th', ToggleInlayHints, { desc = "Toggle inlay hints" })

function LspDefinitionSplit()
  vim.cmd("vsplit")
  vim.lsp.buf.definition()
end

vim.keymap.set('n', 'gd', LspDefinitionSplit, { desc = "Go to definition (split)" })

function ToggleAutoFormat()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].auto_format == false then
    vim.b[buf].auto_format = true
    vim.notify("Auto-format enabled for this buffer.", vim.log.levels.INFO)
  else
    vim.b[buf].auto_format = false
    vim.notify("Auto-format disabled for this buffer.", vim.log.levels.INFO)
  end
end

function ToggleBackground()
  if vim.o.background == "dark" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
  vim.cmd("colorscheme " .. vim.g.colors_name)
end

vim.keymap.set('n', '<leader>tb', ToggleBackground, { desc = "Toggle background" })

function OpenHealthCheck()
  vim.cmd("enew | setlocal buftype=nofile bufhidden=wipe noswapfile")
  vim.fn.termopen("nvim --headless -c 'checkhealth' -c 'qa!'")
  vim.cmd("normal! G")
end

vim.keymap.set('n', '<leader>ch', OpenHealthCheck, { desc = "Open health check" })

function ToggleConceal()
  if vim.o.conceallevel == 0 then
    vim.o.conceallevel = 2
  else
    vim.o.conceallevel = 0
  end
end

vim.keymap.set('n', '<leader>tc', ToggleConceal, { desc = "Toggle conceal" })

function OpenLogFile()
  local log_path = vim.fn.stdpath("log") .. "/nvim.log"
  vim.cmd("edit " .. log_path)
end

vim.keymap.set('n', '<leader>nl', OpenLogFile, { desc = "Open Neovim log" })

function ToggleListChars()
  if vim.o.list then
    vim.o.list = false
  else
    vim.o.list = true
    vim.o.listchars = "tab:→ ,trail:·,nbsp:␣"
  end
end

vim.keymap.set('n', '<leader>tl', ToggleListChars, { desc = "Toggle list chars" })

function OpenRuntimeDir()
  local runtime_path = vim.fn.stdpath("config")
  vim.cmd("edit " .. runtime_path)
end

vim.keymap.set('n', '<leader>nr', OpenRuntimeDir, { desc = "Open runtime dir" })

function ToggleDiffMode()
  if vim.wo.diff then
    vim.wo.diff = false
  else
    vim.wo.diff = true
  end
end

vim.keymap.set('n', '<leader>td', ToggleDiffMode, { desc = "Toggle diff mode" })

function OpenManPage(topic)
  vim.cmd("Man " .. topic)
end

vim.keymap.set('n', '<leader>mn', function() OpenManPage(vim.fn.input("Man page: ")) end, { desc = "Open man page" })

function ToggleMouse()
  if vim.o.mouse == "" then
    vim.o.mouse = "a"
  else
    vim.o.mouse = ""
  end
end

vim.keymap.set('n', '<leader>tm', ToggleMouse, { desc = "Toggle mouse" })

function OpenAPIDocs()
  vim.fn.jobstart("open https://neovim.io/doc/user/api.html", { detach = true })
end


vim.keymap.set('n', '<leader>ad', OpenAPIDocs, { desc = "Open API docs" })

function TogglePasteMode()
  if vim.o.paste then
    vim.o.paste = false
  else
    vim.o.paste = true
  end
end

vim.keymap.set('n', '<leader>tp', TogglePasteMode, { desc = "Toggle paste mode" })

function OpenFAQ()
  vim.fn.jobstart("open https://github.com/neovim/neovim/wiki/FAQ", { detach = true })
end


vim.keymap.set('n', '<leader>af', OpenFAQ, { desc = "Open FAQ" })



function ToggleVirtualEdit()
  if vim.o.virtualedit == "all" then
    vim.o.virtualedit = ""
  else
    vim.o.virtualedit = "all"
  end
end

vim.keymap.set('n', '<leader>tv', ToggleVirtualEdit, { desc = "Toggle virtual edit" })

function OpenIssueTracker()
  vim.fn.jobstart("open https://github.com/neovim/neovim/issues", { detach = true })
end

vim.keymap.set('n', '<leader>ai', OpenIssueTracker, { desc = "Open issue tracker" })

function ToggleWrapBreak()
  if vim.o.wrap and vim.o.linebreak then
    vim.o.wrap = false
  else
    vim.o.wrap = true
    vim.o.linebreak = true
  end
end

vim.keymap.set('n', '<leader>tw', ToggleWrapBreak, { desc = "Toggle wrap/break" })

function OpenWiki()
  vim.fn.jobstart("open https://github.com/neovim/neovim/wiki", { detach = true })
end

vim.keymap.set('n', '<leader>aw', OpenWiki, { desc = "Open wiki" })

local harpoon_files = {}

function HarpoonAddFile()
  local file = vim.fn.expand("%:p")
  table.insert(harpoon_files, file)
  vim.notify("Added: " .. file, vim.log.levels.INFO)
end

function HarpoonNavigate(index)
  if harpoon_files[index] then
    vim.cmd("edit " .. harpoon_files[index])
  else
    vim.notify("No file at index " .. index, vim.log.levels.WARN)
  end
end

vim.keymap.set('n', '<leader>ha', HarpoonAddFile, { desc = "Harpoon: Add file" })
vim.keymap.set('n', '<leader>h1', function() HarpoonNavigate(1) end, { desc = "Harpoon: Navigate to 1" })
vim.keymap.set('n', '<leader>h2', function() HarpoonNavigate(2) end, { desc = "Harpoon: Navigate to 2" })
-- Add more as needed

function FuzzyFindBuffers()
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  local names = {}
  for _, buf in ipairs(buffers) do
    table.insert(names, buf.name)
  end
  vim.ui.select(names, {
    prompt = "Select buffer:",
  }, function(choice)
    if choice then
      vim.cmd("edit " .. choice)
    end
  end)
end

vim.keymap.set('n', '<leader>fb', FuzzyFindBuffers, { desc = "Fuzzy find buffers" })

function ToggleComment()
  local ft = vim.bo.filetype
  local comment_strings = {
    lua = "-- ",
    python = "# ",
    javascript = "// ",
    rust = "// ",
    c = "// ",
    cpp = "// ",
    sh = "# ",
  }
  local cs = comment_strings[ft] or "# "
  local line = vim.fn.line(".")
  local lines = vim.fn.getline(line, line)
  if lines[1]:match("^%s*" .. cs) then
    -- Uncomment
    vim.cmd("s/\\v^\\s*" .. vim.fn.escape(cs, "/") .. "//e")
  else
    -- Comment
    vim.cmd("s/^/" .. cs .. "/")
  end
end

vim.keymap.set('n', '<leader>/', ToggleComment, { desc = "Toggle comment" })
vim.keymap.set('v', '<leader>/', ":<C-u>lua ToggleComment()<CR>", { desc = "Toggle comment (visual)" })

function AutoPair(char)
  local pairs = { ["("] = ")", ["["] = "]", ["{"] = "}", ['"'] = '"', ["'"] = "'" }
  local close_char = pairs[char]
  if close_char then
    vim.api.nvim_put({ close_char }, "c", false, true)
    vim.cmd("normal! h")
  end
end


-- vim.api.nvim_create_autocmd("InsertCharPre", {
--   callback = function()
--     local char = vim.fn.nr2char(vim.fn.getchar())
--     AutoPair(char)
--   end,
-- })


function SurroundAdd(delimiter)
  local esc = vim.fn.escape(delimiter, "/\\")
  vim.cmd("normal! `>a" .. esc .. "<ESC>`<i" .. esc .. "<ESC>")
end

function SurroundChange(old, new)
  local esc_old = vim.fn.escape(old, "/\\")
  local esc_new = vim.fn.escape(new, "/\\")
  vim.cmd("%s/" .. esc_old .. "\\(.*\\)" .. esc_old .. "/" .. esc_new .. "\\1" .. esc_new .. "/g")
end

vim.keymap.set('v', '<leader>sa', [[":lua SurroundAdd(vim.fn.input("Delimiter: "))<CR>]], { desc = "Surround: Add" })
vim.keymap.set('n', '<leader>sc', [[:lua SurroundChange(vim.fn.input("Old: "), vim.fn.input("New: "))<CR>]], { desc = "Surround: Change" })

function ShowGitSigns()
  vim.cmd("sign define GitSignAdd text=+ texthl=GitSignsAdd")
  vim.cmd("sign define GitSignChange text=~ texthl=GitSignsChange")
  vim.cmd("sign define GitSignDelete text=_ texthl=GitSignsDelete")
  vim.cmd("sign place 100 line=1 name=GitSignAdd file=" .. vim.fn.expand("%:p"))
end

function ShowSignatureHelp()
  vim.lsp.buf.signature_help()
end

vim.keymap.set('n', '<leader>ls', ShowSignatureHelp, { desc = "LSP: Signature help" })

function OpenTerminalInRoot()
  local root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null | tr -d '\n'")
  if root == "" then
    root = vim.fn.getcwd()
  end
  vim.cmd("split | term cd " .. root)
end

vim.keymap.set('n', '<leader>tr', OpenTerminalInRoot, { desc = "Terminal: Open in root" })

function ToggleDiagnostics()
  vim.diagnostic.setqflist({ open = not vim.fn.getqflist({ size = 1 }).size })
end

vim.keymap.set('n', '<leader>td', ToggleDiagnostics, { desc = "Toggle diagnostics" })

function OpenConfigInTab()
  vim.cmd("tabnew ~/.config/nvim/init.lua")
end

vim.keymap.set('n', '<leader>ct', OpenConfigInTab, { desc = "Open config in tab" })

function ToggleSemanticTokens()
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  for _, client in ipairs(clients) do
    if client.supports_method("textDocument/semanticTokens") then
      client.server_capabilities.semanticTokensProvider = not client.server_capabilities.semanticTokensProvider
      vim.cmd("LspRestart")
    end
  end
end

vim.keymap.set('n', '<leader>ts', ToggleSemanticTokens, { desc = "Toggle semantic tokens" })

function OpenPluginManager()
  vim.cmd("Lazy")
end


vim.keymap.set('n', '<leader>pm', OpenPluginManager, { desc = "Open plugin manager" })

function ToggleCodeLens()
  vim.lsp.codelens.refresh()
  if vim.lsp.codelens.is_enabled() then
    vim.lsp.codelens.clear()
  else
    vim.lsp.codelens.display()
  end
end


vim.keymap.set('n', '<leader>cl', ToggleCodeLens, { desc = "Toggle code lens" })

function OpenHelpSplit(topic)
  vim.cmd("vsplit | help " .. topic)
end

vim.keymap.set('n', '<leader>hs', function() OpenHelpSplit(vim.fn.input("Help topic: ")) end, { desc = "Open help (split)" })

function ToggleInlayHintsBuf()
  local buf = vim.api.nvim_get_current_buf()
  if vim.lsp.inlay_hint.is_enabled({ bufnr = buf }) then
    vim.lsp.inlay_hint.enable(buf, false)
  else
    vim.lsp.inlay_hint.enable(buf, true)
  end
end

vim.keymap.set('n', '<leader>ih', ToggleInlayHintsBuf, { desc = "Toggle inlay hints (buffer)" })


