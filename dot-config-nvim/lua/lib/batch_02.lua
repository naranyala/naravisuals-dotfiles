-- =============================================
-- 1. Toggle relative/absolute line numbers
-- =============================================
function _G.toggle_relative_number()
  if vim.wo.number == false then
    vim.wo.number = true
    vim.wo.relativenumber = false
  elseif vim.wo.relativenumber then
    vim.wo.relativenumber = false
  else
    vim.wo.relativenumber = true
  end
end

-- Usage example:
-- vim.keymap.set('n', '<leader>un', toggle_relative_number, { desc = "Toggle relative numbers" })


-- =============================================
-- 2. Toggle wrap / virtualedit for easy big movements
-- =============================================
function _G.toggle_wrap_movement()
  if vim.wo.wrap then
    vim.cmd([[set nowrap]])
    vim.cmd([[set virtualedit=]])
  else
    vim.cmd([[set wrap]])
    vim.cmd([[set virtualedit=all]])
  end
end


-- =============================================
-- 3. Smart quit (close buffer or Neovim wisely)
-- =============================================
function _G.smart_quit()
  local bufcount = #vim.fn.getbufinfo({ buflisted = 1 })
  local is_last_buffer = bufcount == 1

  if is_last_buffer then
    local modified = vim.api.nvim_buf_get_option(0, 'modified')
    if modified then
      local choice = vim.fn.confirm("Buffer has unsaved changes. Quit anyway?", "&Yes\n&No", 2)
      if choice == 1 then vim.cmd('qall!') end
    else
      vim.cmd('qall')
    end
  else
    local modified = vim.api.nvim_buf_get_option(0, 'modified')
    if modified then
      vim.cmd('write')
    end
    vim.cmd('bdelete')
  end
end

-- Usage: vim.keymap.set('n', '<leader>q', smart_quit, { desc = "Smart quit" })


-- =============================================
-- 4. Toggle diagnostics (super useful when reading code)
-- =============================================
function _G.toggle_diagnostics()
  if vim.diagnostic.is_disabled() then
    vim.diagnostic.enable()
  else
    vim.diagnostic.disable()
  end
end

-- Usage: vim.keymap.set('n', '<leader>ud', toggle_diagnostics, { desc = "Toggle diagnostics" })


-- =============================================
-- 5. Open current file in GitHub / GitLab / etc (browser)
-- =============================================
function _G.open_in_github()
  local handle = io.popen("git remote -v | grep origin | head -1 | awk '{print $2}'")
  if not handle then return end
  local remote = handle:read("*a"):gsub("\n", "")
  handle:close()

  local branch_handle = io.popen("git rev-parse --abbrev-ref HEAD")
  if not branch_handle then return end
  local branch = branch_handle:read("*a"):gsub("\n", "")
  branch_handle:close()

  local file = vim.fn.expand("%:.")  -- relative path from repo root
  if file == "" then file = "." end

  local line = vim.fn.line(".")

  local url = ""
  if remote:match("github%.com") then
    url = remote:gsub("git@", "https://"):gsub(":.com", ".com/"):gsub("%.git$", "")
                 .. "/blob/" .. branch .. "/" .. file .. "#L" .. line
  elseif remote:match("gitlab%.com") then
    url = remote:gsub("git@", "https://"):gsub(":.com", ".com/"):gsub("%.git$", "")
                 .. "/-/blob/" .. branch .. "/" .. file .. "#L" .. line
  else
    print("Remote not GitHub/GitLab")
    return
  end

  vim.fn.system({ "open" if vim.fn.has("mac") == 1 else "xdg-open", url })
end


-- =============================================
-- 6. Better grep / search word under cursor in project
-- =============================================
function _G.project_grep_word()
  local word = vim.fn.expand("<cword>")
  require("telescope.builtin").grep_string({ search = word })
end

function _G.project_grep_prompt()
  require("telescope.builtin").live_grep()
end

-- Works even without Telescope if you replace with vim.ui.input + vim.cmd.grep


-- =============================================
-- 7. Toggle inlay hints (for lsp that support it)
-- =============================================
function _G.toggle_inlay_hints()
  vim.lsp.inlay_hint.enable(0, not vim.lsp.inlay_hint.is_enabled(0))
end


-- =============================================
-- 8. Trim trailing whitespace on save (as a function you can call)
-- =============================================
function _G.trim_trailing_whitespace()
  if not vim.o.binary and vim.o.filetype ~= 'diff' then
    local current_view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(current_view)
  end
end

-- Hook it automatically:
-- vim.api.nvim_create_autocmd("BufWritePre", { callback = trim_trailing_whitespace })


-- =============================================
-- 9. Quick run current file (supports many languages)
-- =============================================
function _G.quick_run()
  local ft = vim.bo.filetype
  local file = vim.fn.expand("%:p")

  local cmd = {
    python = "python " .. file,
    lua = "lua " .. file,
    javascript = "node " .. file,
    typescript = "ts-node " .. file,
    sh = "bash " .. file,
    go = "go run " .. file,
    rust = "cargo run",
    cpp = "g++ " .. file .. " -o /tmp/a.out && /tmp/a.out",
    c = "gcc " .. file .. " -o /tmp/a.out && /tmp/a.out",
  }

  if cmd[ft] then
    require("toggleterm.terminal").Terminal:new({
      cmd = cmd[ft],
      close_on_exit = true,
      direction = "float",
    }):toggle()
  else
    print("No quick-run for filetype: " .. ft)
  end
end


-- =============================================
-- 10. Copy relative / absolute path to clipboard
-- =============================================
function _G.copy_path(relative)
  local path = relative and vim.fn.expand("%:.") or vim.fn.expand("%:p")
  vim.fn.setreg('+', path)
  print("Copied: " .. path)
end

-- Usage:
-- vim.keymap.set('n', '<leader>cp', function() copy_path(true) end, { desc = "Copy relative path" })
-- vim.keymap.set('n', '<leader>cP', function() copy_path(false) end, { desc = "Copy absolute path" })

-- =============================================
-- 11. Better <C-a>/<C-x>: treat alpha like numbers
-- =============================================
function _G.smart_increment()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local char = line:sub(col + 1, col + 1)  -- char under cursor

  -- If on a letter, increment/decrement alphabetically (a→b, z→a, A→B, Z→A)
  if char:match("[a-z]") or char:match("[A-Z]") then
    local upper = char:match("[A-Z]")
    local new_char = string.char((char:byte() + (vim.v.count1 % 26)) % 26 + (upper and 65 or 97))
    if char:byte() + vim.v.count1 > (upper and 90 or 122) then new_char = upper and "A" or "a" end
    vim.api.nvim_set_current_line(line:sub(1, col) .. new_char .. line:sub(col + 2))
    return
  end

  -- Otherwise fallback to default <C-a>/<C-x> behavior
  vim.cmd("normal! \\<C-a>")
end

function _G.smart_decrement()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-a>", true, true, true), "n", false)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<BS>", true, true, true), "n", false)
  smart_increment()  -- reuse logic with negative count simulation
end

-- Usage:
-- vim.keymap.set("n", "+", smart_increment, { desc = "Smart increment (numbers & letters)" })
-- vim.keymap.set("n", "-", function() vim.cmd("normal! " .. vim.v.count1 .. "-") smart_increment() end)


-- =============================================
-- 12. Jump to last edit position (not just last cursor pos)
-- =============================================
function _G.jump_to_last_change()
  local last_change = vim.fn.getpos("'[")
  if last_change then vim.fn.cursor(last_change[2], last_change[3]) end
end

-- vim.keymap.set("n", "g;", jump_to_last_change, { desc = "Jump to last change" })


-- =============================================
-- 13. Toggle cursor line + column highlight (focus mode)
-- =============================================
function _G.toggle_focus_mode()
  vim.wo.cursorline = not vim.wo.cursorline
  vim.wo.cursorcolumn = not vim.wo.cursorcolumn
  vim.wo.colorcolumn = vim.wo.colorcolumn == "" and "999" or ""
end


-- =============================================
-- 14. Duplicate line/selection (super clean)
-- =============================================
function _G.duplicate_selection()
  local mode = vim.fn.mode()
  if mode == "V" or mode == "" then
    vim.cmd(":'<,'>t'>")
  else
    vim.cmd(":.t.")
  end
end

-- vim.keymap.set({"n", "v"}, "<leader>d", duplicate_selection, { desc = "Duplicate line/selection" })


-- =============================================
-- 15. Move lines up/down (visual + normal mode)
-- =============================================
function _G.move_line_up()
  vim.cmd("silent! move-2")
  vim.cmd("normal! ==)")
end

function _G.move_line_down()
  vim.cmd("silent! move+1")
  vim.cmd("normal! ==)")
end

-- In visual mode:
vim.keymap.set("v", "J", ":move'>+1<CR>gv=gv", { silent = true })
vim.keymap.set("v", "K", ":move'<-2<CR>gv=gv", { silent = true })


-- =============================================
-- 16. Open Neovim config folder instantly
-- =============================================
function _G.edit_config()
  local config_path = vim.fn.stdpath("config")
  require("telescope.builtin").find_files({ cwd = config_path, prompt_title = "Neovim Config" })
  -- Or without Telescope:
  -- vim.cmd("edit " .. config_path)
end

-- vim.keymap.set("n", "<leader>ev", edit_config, { desc = "Edit Neovim config" })


-- =============================================
-- 17. Toggle spellcheck with smart language
-- =============================================
function _G.toggle_spell()
  vim.wo.spell = not vim.wo.spell
  if vim.wo.spell then
    vim.bo.spelllang = "en_us,cjk"  -- ignore Asian chars
    print("Spellcheck ON (en_us + cjk)")
  else
    print("Spellcheck OFF")
  end
end


-- =============================================
-- 18. Quick note / scratch buffer
-- =============================================
function _G.open_scratch()
  vim.cmd("edit ~/notes/scratch.md")
  if vim.fn.filereadable(vim.fn.expand("~/notes/scratch.md")) == 0 then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# Scratch", "", os.date("%Y-%m-%d %H:%M") })
  end
end


-- =============================================
-- 19. Paste with auto-indent (pastes and fixes indent instantly)
-- =============================================
function _G.paste_with_indent()
  local indent = vim.fn.indent(".")
  vim.cmd('normal! "'] .. vim.v.register .. "p")
  vim.cmd("normal! ==")
end

-- vim.keymap.set("n", "<leader>p", paste_with_indent, { desc = "Paste & reindent" })


-- =============================================
-- 20. Toggle quickfix / loclist
-- =============================================
function _G.toggle_quickfix()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then qf_exists = true end
  end
  if qf_exists then
    vim.cmd("cclose")
  else
    vim.cmd("copen")
  end
end

function _G.toggle_loclist()
  local winid = vim.fn.getloclist(0, { winid = 0 }).winid
  if winid == 0 then
    vim.cmd("lopen")
  else
    vim.cmd("lclose")
  end
end

-- <leader>q → quickfix, <leader>l → loclist


-- =============================================
-- Bonus: One-key compile & run for competitive programming
-- =============================================
function _G.cp_run()
  local file = vim.fn.expand("%:p")
  local dir = "/tmp/cp"
  vim.fn.system("mkdir -p " .. dir)
  local bin = dir .. "/" .. vim.fn.expand("%:t:r")

  local cmd = vim.bo.ft == "cpp" and ("g++ -std=c++20 -O2 -Wall " .. file .. " -o " .. bin .. " && " .. bin)
           or vim.bo.ft == "c"   and ("gcc -O2 -Wall " .. file .. " -o " .. bin .. " && " .. bin)
           or vim.bo.ft == "rust" and ("rustc " .. file .. " -o " .. bin .. " && " .. bin)
           or vim.bo.ft == "python" and ("python " .. file)

  if cmd then
    require("toggleterm").exec(cmd, 1, 15, nil, "float")
  end
end

-- =============================================
-- 21. Toggle between header/source (C/C++) instantly
-- =============================================
function _G.toggle_header_source()
  local ext = vim.fn.expand("%:e")
  local alternatives = {
    c = { "h", "hpp", "hh", "hxx" },
    cpp = { "h", "hpp", "hh", "hxx", "h++" },
    h = { "c", "cpp", "cc", "cxx" },
    hpp = { "cpp", "cc", "cxx" },
    hh = { "cc", "cpp" },
  }
  local base = vim.fn.expand("%:r")
  for _, e in ipairs(alternatives[ext] or {}) do
    local candidate = base .. "." .. e
    if vim.fn.filereadable(candidate) == 1 then
      vim.cmd("edit " .. candidate)
      return
    end
  end
  print("No alternate file found")
end

-- <leader>th or <leader>ts


-- =============================================
-- 22. Open alternate file (spec ↔ implementation, test ↔ src)
-- =============================================
function _G.open_alternate()
  local current = vim.fn.expand("%:.")  -- relative path
  local patterns = {
    {"^app/(.*)%.lua$", "tests/%1_spec.lua"},
    {"^tests/(.*)_spec%.lua$", "app/%1.lua"},
    {"^src/(.*)%.ts$", "src/%1.test.ts"},
    {"^src/(.*)%.test%.ts$", "src/%1.ts"},
  }
  for _, pat in ipairs(patterns) do
    local alt = current:gsub(pat[1], pat[2])
    if alt ~= current and vim.fn.filereadable(alt) == 1 then
      vim.cmd("edit " .. alt)
      return
    end
  end
  print("No alternate file")
end


-- =============================================
-- 23. cd to project root (git root or fallback)
-- =============================================
function _G.cd_project_root()
  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    root = vim.fn.getcwd()
  end
  vim.cmd("lcd " .. root)
  print("cd → " .. root)
end


-- =============================================
-- 24. Smart toggle terminal (one terminal to rule them all)
-- =============================================
function _G.smart_terminal()
  local term = vim.g.smart_term or nil
  if term and vim.api.nvim_buf_is_valid(term.buf) then
    if vim.api.nvim_get_current_buf() == term.buf then
      vim.cmd("hide")
    else
      vim.api.nvim_set_current_buf(term.buf)
    end
  else
    vim.cmd("botright 12split | terminal")
    term = { buf = vim.api.nvim_get_current_buf() }
    vim.g.smart_term = term
    vim.cmd("startinsert")
  end
end

-- <leader>t  (works even without toggleterm plugin)


-- =============================================
-- 25. Run last command again in terminal
-- =============================================
function _G.run_last_command()
  if vim.g.last_cmd then
    vim.cmd("terminal " .. vim.g.last_cmd)
    vim.cmd("startinsert")
  else
    print("No last command")
  end
end

-- Hook anywhere you run commands:
-- local function run_and_remember(cmd)
--   vim.g.last_cmd = cmd
--   vim.cmd("terminal " .. cmd)
-- end


-- =============================================
-- 26. Close all floating windows (instant zen)
-- =============================================
function _G.close_floats()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative and cfg.relative ~= "" then
      vim.api.nvim_win_close(win, false)
    end
  end
end

-- <Esc><Esc> in normal mode or <leader>cf


-- =============================================
-- 27. Toggle concealed text (great for markdown/json)
-- =============================================
function _G.toggle_conceal()
  vim.wo.conceallevel = vim.wo.conceallevel == 0 and 2 or 0
end


-- =============================================
-- 28. Insert UUID (v4)
-- =============================================
function _G.insert_uuid()
  local uuid = vim.fn.systemlist("uuidgen")[1]:gsub("-", ""):lower()
  vim.api.nvim_put({ uuid }, "c", true, true)
end

-- ciu → insert uuid


-- =============================================
-- 29. Toggle auto-comment on enter (for when you hate it)
-- =============================================
function _G.toggle_auto_comment()
  if vim.bo.formatoptions:match("o") then
    vim.bo.formatoptions = vim.bo.formatoptions:gsub("[cro]", "")
  else
    vim.bo.formatoptions = vim.bo.formatoptions .. "ro"
  end
end


-- =============================================
-- 30. Grep visual selection instantly
-- =============================================
function _G.grep_visual_selection()
  local a = vim.fn.getreg("a")
  vim.cmd('normal! "ay')
  local text = vim.fn.getreg("a")
  vim.fn.setreg("a", a)
  text = text:gsub("\n", " ")
  require("telescope.builtin").live_grep({ default_text = text })
end

-- In visual mode: <leader>/


-- =============================================
-- 31. Toggle background (light/dark) with theme sync
-- =============================================
function _G.toggle_background()
  if vim.o.background == "dark" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
end


-- =============================================
-- 32. Open changed files (git status) in quickfix
-- =============================================
function _G.open_git_changed()
  vim.cmd("silent! !git rev-parse --git-dir")  -- check if git repo
  if vim.v.shell_error ~= 0 then return end
  local files = vim.fn.systemlist("git status --porcelain | awk '{print $2}'")
  vim.fn.setqflist({}, "r")
  for _, f in ipairs(files) do
    if f ~= "" then vim.fn.setqflist({ { filename = f } }, "a") end
  end
  vim.cmd("copen")
end


-- =============================================
-- 33. Smart delete buffer without killing window layout
-- =============================================
function _G.delete_buffer_safe()
  local cur_buf = vim.api.nvim_get_current_buf()
  local buf_count = #vim.fn.getbufinfo({ buflisted = 1 })

  if buf_count == 1 then
    vim.cmd("bdelete")
    return
  end

  local alt_buf = vim.fn.bufnr("#")
  if alt_buf ~= -1 and vim.fn.getbufinfo(alt_buf)[1] then
    vim.cmd("buffer #")
  else
    vim.cmd("bnext")
  end
  vim.cmd("bdelete #")
end

-- <leader>bd


-- =============================================
-- 34. Toggle mouse (for copy-paste sessions)
-- =============================================
function _G.toggle_mouse()
  if vim.o.mouse == "a" then
    vim.o.mouse = ""
    print("Mouse OFF")
  else
    vim.o.mouse = "a"
    print("Mouse ON")
  end
end


-- =============================================
-- 35. Insert current filename / date / time templates
-- =============================================
function _G.insert_filename()
  vim.api.nvim_put({ vim.fn.expand("%:t") }, "c", true, true)
end

function _G.insert_date()
  vim.api.nvim_put({ os.date("%Y-%m-%d") }, "c", true, true)
end

function _G.insert_datetime()
  vim.api.nvim_put({ os.date("%Y-%m-%d %H:%M") }, "c", true, true)
end

-- Map to <leader>if, <leader>id, <leader>it
--

-- =============================================
-- 36. Surround emulation (vim-surround core features)
-- =============================================
function _G.surround_add(char)
  local line, col = vim.fn.line("."), vim.fn.col(".") - 1
  local left = char .. char
  if char == "(" then left = "( " right = " )"
  elseif char == "[" then left = "[ " right = " ]"
  elseif char == "{" then left = "{ " right = " }"
  elseif char == "<" then left = "<" right = ">"
  else right = char end
  vim.api.nvim_buf_set_text(0, line-1, col, line-1, col, {left, right})
  vim.fn.cursor(line, col + #left + 1)
end

-- Visual mode: cs"') etc → reimplement with <cmd>lua surround_change()<cr>
function _G.surround_change(old, new)
  vim.cmd(string.format('silent! %%s/%s\\(.*\\)%s/%s\\1%s/g', old, old, new, new))
end

-- ysiw" etc → map in operatorfunc
vim.keymap.set("n", "sa", function() vim.fn.inputsave() local c=vim.fn.input("Surround with: ") vim.fn.inputrestore() _G.surround_add(c) end)


-- =============================================
-- 37. Instant comment toggle (gcc, gc – like vim-commentary / comment.nvim)
-- =============================================
function _G.toggle_comment()
  local commentstring = vim.bo.commentstring:gsub("%%s", "(.*)")
  local line = vim.api.nvim_get_current_line()
  if line:match("^%s*" .. commentstring) then
    local uncomment = line:gsub("^(%s*)" .. commentstring .. "$", "%1%2")
    vim.api.nvim_set_current_line(uncomment)
  else
    local commented = vim.bo.commentstring:format(" " .. line:gsub("^%s*", ""))
    vim.api.nvim_set_current_line(commented)
  end
end

-- Visual mode version
function _G.toggle_comment_visual()
  vim.cmd('normal! gv')
  local esc = vim.api.nvim_replace_termcodes('<esc>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'nx', false)
  vim.cmd('silent! \'<,\'>lua _G.toggle_comment()')
  vim.cmd('normal! gv')
end

vim.keymap.set({"n", "v"}, "<leader>/", toggle_comment_visual)


-- =============================================
-- 38. Two-char sneak (like vim-sneak / lightspeed s-motion)
-- =============================================
function _G.sneak_two_char()
  local a = vim.fn.getchar()
  local b = vim.fn.getchar()
  local chars = vim.fn.nr2char(a) .. vim.fn.nr2char(b)
  vim.fn.search(chars, "W")
end

vim.keymap.set({"n", "x", "o"}, "s", sneak_two_char)


-- =============================================
-- 39. Abolish-style coercion (crs, crm, crc, cru)
-- =============================================
function _G.coerce_word(mode)
  local word = vim.fn.expand("<cword>")
  local mappings = {
    s = word:gsub("_(%w)", string.upper),                 -- snake_case
    m = word:gsub("(%a)(%u)", "%1_%2"):lower(),           -- MixedCase → snake_case
    c = word:gsub("^%l", string.upper):gsub("_(%l)", string.upper):gsub("_", ""), -- camelCase
    u = word:upper(),                                     -- UPPER
  }
  local new = mappings[mode] or word
  vim.api.nvim_command(string.format("%%substitute/\\<%s\\>/%s/g", word, new))
end

-- crs, crm, crc, cru
vim.keymap.set("n", "crs", function() _G.coerce_word("s") end)  -- to snake
vim.keymap.set("n", "crm", function() _G.coerce_word("m") end)  -- to mixed
vim.keymap.set("n", "crc", function() _G.coerce_word("c") end)  -- to camel
vim.keymap.set("n", "cru", function() _G.coerce_word("u") end)  -- to UPPER


-- =============================================
-- 40. EasyAlign style (ga motion – align on character)
-- =============================================
function _G.easy_align(char)
  char = char or vim.fn.input("Align on: ")
  vim.cmd(string.format("'<,'>s/^\\s*\\zs.*%s.*/\\0/g | '<,'>center", char))
end

vim.keymap.set("v", "ga", ":lua _G.easy_align()<cr>")


-- =============================================
-- 41. Hop / Flash style jump to word start (like flash.nvim jump)
-- =============================================
function _G.flash_jump()
  local word = vim.fn.input("Jump to word starting with: ")
  vim.fn.search("\\<" .. vim.fn.escape(word, "/\\") .. "\\w*")
end

vim.keymap.set("n", "<leader>j", flash_jump)


-- =============================================
-- 42. Replace word under cursor in entire buffer (like spectre but instant)
-- =============================================
function _G.replace_word_global()
  local old = vim.fn.expand("<cword>")
  vim.ui.input({ prompt = "Replace '"..old.."' with: " }, function(new)
    if new then vim.cmd(string.format("%%s/\\<%s\\>/%s/gc", old, new)) end
  end)
end

vim.keymap.set("n", "<leader>rw", replace_word_global)


-- =============================================
-- 43. Change inside/next surround (ci(, ci", etc. – better than built-in)
-- =============================================
vim.keymap.set("n", "ciw", "ciw")  -- already good, but enhance for pairs
function _G.change_inside(pair)
  vim.fn.searchpair(pair:sub(1,1), "", pair:sub(2,2), "W")
  vim.cmd("normal! vi" .. pair:sub(1,1))
end


-- =============================================
-- 44. Mini.indentscope-like visual indent guide toggle
-- =============================================
function _G.toggle_indent_guides()
  vim.wo.list = not vim.wo.list
  vim.wo.listchars = vim.wo.list and "lead:·,trail:·,tab:→ ,extends:>,precedes:<" or ""
end


-- =============================================
-- 45. ZenMode / Twilight style distraction-free toggle
-- =============================================
function _G.zen_mode()
  vim.g.zen_active = not vim.g.zen_active
  if vim.g.zen_active then
    vim.cmd("set laststatus=0 showtabline=0 ruler=false showcmd=false")
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = "no"
    vim.cmd("hi Normal ctermbg=none guibg=none")
  else
    vim.cmd("set laststatus=2 showtabline=2 ruler showcmd")
    vim.cmd("set number relativenumber signcolumn=yes")
    vim.cmd("hi Normal ctermbg=234 guibg=#1e1e1e")
  end
end


-- =============================================
-- 46. Auto-create parent dirs on save (like vim-eunuch :Mkdir)
-- =============================================
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    local dir = vim.fn.expand("<afile>:p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end
})


-- =============================================
-- 47. Better * / # search (search visual selection automatically)
-- =============================================
vim.keymap.set("v", "*", function()
  vim.cmd('normal! "sy')
  vim.fn.setreg("/", vim.fn.getreg("s"))
  vim.cmd("set hlsearch")
end)


-- =============================================
-- 48. Todo-comments style quick jump to TODO/FIXME
-- =============================================
function _G.jump_todo()
  require("telescope.builtin").live_grep({ default_text = "TODO|FIXME|HACK|NOTE" })
end

vim.keymap.set("n", "]t", jump_todo)


-- =============================================
-- 49. Harpoon-style mark & jump (4 slots)
-- =============================================
vim.g.harpoon_marks = vim.g.harpoon_marks or {}
function _G.harpoon_mark(slot)
  vim.g.harpoon_marks[slot or 1] = vim.fn.expand("%:p") .. ":" .. vim.fn.line(".")
end
function _G.harpoon_jump(slot)
  local mark = vim.g.harpoon_marks[slot]
  if mark then
    local file, line = mark:match("(.+):(%d+)")
    vim.cmd("edit " .. file)
    vim.fn.cursor(tonumber(line), 1)
  end
end

for i = 1,4 do
  vim.keymap.set("n", "<leader>h"..i, function() _G.harpoon_mark(i) end, {desc="Mark "..i})
  vim.keymap.set("n", "<leader>"..i, function() _G.harpoon_jump(i) end, {desc="Jump "..i})
end


-- =============================================
-- 50. Vim-maximizer style window zoom
-- =============================================
function _G.toggle_zoom()
  if vim.g.zoomed then
    vim.cmd(vim.g.zoomed_cmd)
    vim.g.zoomed = nil
  else
    vim.g.zoomed_cmd = vim.fn.winrestcmd()
    vim.cmd("resize | vertical resize")
    vim.g.zoomed = true
  end
end

vim.keymap.set("n", "<leader>z", toggle_zoom)


