-- ~/.config/nvim/lua/my-godtier-enhancements.lua
local M = {}
local G = {}

-- 25. Duplicate current line visually (like VSCode Ctrl+D but better)
function M.duplicate_line()
  vim.cmd('t.')
end

-- 26. Instant sort visual selection (alphabetical, numeric, length, etc.)
function M.sort_visual(mode)
  vim.cmd('normal! gv')
  local sort_cmd = "sort"
  if mode == "n" then sort_cmd = sort_cmd .. " n"
  elseif mode == "l" then sort_cmd = sort_cmd .. " /.\\{-}\\ze\\s/"  -- by length
  elseif mode == "u" then sort_cmd = sort_cmd .. " u"  -- unique
  elseif mode == "r" then sort_cmd = sort_cmd .. "!"  -- reverse
  end
  vim.cmd("'" .. sort_cmd)
end

-- 27. Toggle quickfix / loclist like a pro
vim.g.qf_open = false
function M.toggle_quickfix()
  if vim.g.qf_open then
    vim.cmd("cclose")
    vim.g.qf_open = false
  else
    vim.cmd("copen")
    vim.g.qf_open = true
  end
end

-- 28. Open alternate file (header ↔ source) instantly
function M.alternate_file()
  local ext = vim.fn.expand("%:e")
  local alts = {
    c = "h", h = "c",
    cpp = "hpp", hpp = "cpp",
    cc = "hh", hh = "cc",
    cxx = "hxx", hxx = "cxx",
    ts = "tsx", tsx = "ts",
  }
  local alt_ext = alts[ext] or ext
  local candidates = {
    vim.fn.expand("%:r") .. "." .. alt_ext,
    vim.fn.expand("%:p:h") .. "/include/" .. vim.fn.expand("%:t:r") .. "." .. alt_ext,
    vim.fn.expand("%:p:h") .. "/src/" .. vim.fn.expand("%:t:r") .. "." .. alt_ext,
  }
  for _, file in ipairs(candidates) do
    if vim.fn.filereadable(file) == 1 then
      vim.cmd("e " .. file)
      return
    end
  end
  print("No alternate found")
end

-- 29. One-key "open header under cursor" (C/C++ include)
function M.open_include_under_cursor()
  local line = vim.fn.getline(".")
  local include = line:match('#include [%<%"](.-)[%>"]')
  if include then
    vim.cmd("find " .. include)
  end
end

-- 30. Toggle foldcolumn + signs + numbers for ultra-clean screenshot mode
function M.toggle_presentation_mode()
  vim.cmd([[execute "set " .. (&foldcolumn == 0 ? "foldcolumn=4" : "foldcolumn=0")]])
  vim.cmd([[execute "set " .. (&signcolumn == "auto" ? "signcolumn=no" : "signcolumn=auto")]])
  vim.cmd([[execute "set " .. (&number ? "nonumber" : "number") .. " " .. (&relativenumber ? "norelativenumber" : "relativenumber")]])
end

-- 31. Insert current date/time in multiple formats
function M.insert_date(format)
  local formats = {
    iso = "%Y-%m-%d",
    time = "%H:%M",
    full = "%Y-%m-%d %H:%M",
    log = "%Y-%m-%d %H:%M:%S",
    rfc = "%a, %d %b %Y %H:%M:%S %z",
  }
  local f = formats[format] or formats.iso
  local date = os.date(f)
  vim.api.nvim_paste(date, true, -1)
end

-- 32. Toggle inlay hints (LSP) globally or per-buffer
function M.toggle_inlay_hints()
  if vim.lsp.inlay_hint then
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
  end
end

-- 33. Open scratch buffer (unnamed, no swap, buftype=nofile)
function M.scratch()
  vim.cmd("enew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.buflisted = false
  vim.bo.swapfile = false
  vim.cmd("file scratch")
end

-- 34. Run last terminal command again (like !! in bash)
vim.g.last_term_cmd = ""
vim.api.nvim_create_autocmd("TermClose", {
  callback = function(ev)
    if vim.v.event.status == 0 then
      local lines = vim.api.nvim_buf_get_lines(ev.buf, -3, -1, false)
      for _, l in ipairs(lines) do
        if l:match("^%+") then
          vim.g.last_term_cmd = l:sub(3)
          break
        end
      end
    end
  end
})
function M.rerun_last_term()
  if vim.g.last_term_cmd ~= "" then
    vim.cmd("split | terminal " .. vim.g.last_term_cmd)
  end
end

-- 35. Toggle hex mode (xxd) on current file
function M.toggle_hex()
  if vim.bo.binary then
    vim.cmd("%!xxd -r")
    vim.cmd("set nobinary")
  else
    vim.cmd("%!xxd")
    vim.cmd("set binary")
  end
end

-- 36. Strip trailing whitespace + convert tabs → spaces in one shot
function M.cleanup_buffer()
  vim.cmd([[keeppatterns %s/\s\+$//e]])
  vim.cmd([[keeppatterns %s/\t/  /g]])
  print("Buffer cleaned")
end

-- 37. Jump to definition in vertical split (never lose context)
function M.vsplit_definition()
  vim.cmd("vsplit")
  vim.lsp.buf.definition()
end

-- 38. Smart "cd to project root" (git root → lsp root → cwd)
function M.cd_project_root()
  local roots = {
    vim.fn.finddir(".git/..", vim.fn.expand("%:p:h") .. ";"),
    vim.lsp.buf.list_workspaces()[1],
    vim.fn.getcwd(),
  }
  for _, root in ipairs(roots) do
    if root and root ~= "" then
      vim.cmd("cd " .. root)
      print("cd → " .. root)
      return
    end
  end
end

-- 39. Toggle colorcolumn at current textwidth or 80/120
function M.toggle_colorcolumn()
  if vim.wo.colorcolumn == "" then
    local tw = vim.bo.textwidth > 0 and vim.bo.textwidth or 80
    vim.wo.colorcolumn = tostring(tw + 1)
  else
    vim.wo.colorcolumn = ""
  end
end

-- 40. Generate random password & insert it
function M.insert_password()
  local pw = vim.fn.systemlist("openssl rand -base64 32")[1]
  vim.api.nvim_paste(pw, true, -1)
end

-- 41. Open man page for word under cursor in split
function M.man_under_cursor()
  local word = vim.fn.expand("<cword>")
  vim.cmd("split | terminal man " .. word)
end

-- 42. Toggle virtual text diagnostics (hide errors when you want peace)
function M.toggle_virtual_text()
  local current = vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = not current })
end

-- 43. One-key "open in default app" (macOS open / Linux xdg-open)
function M.open_in_os()
  vim.cmd("silent !open " .. vim.fn.shellescape(vim.fn.expand("%:p")) .. " &")
end

-- 44. Toggle cursor line + column crosshair
function M.toggle_crosshair()
  vim.wo.cursorline = not vim.wo.cursorline
  vim.wo.cursorcolumn = not vim.wo.cursorcolumn
end

-- 45. Diff current buffer with saved version
function M.diff_saved()
  vim.cmd("w !diff % -")
end

-- 46. Toggle auto-save (saves every 500ms of inactivity)
vim.g.autosave = false
function M.toggle_autosave()
  if vim.g.autosave then
    vim.cmd("au! autosave_group")
    vim.g.autosave = false
  else
    vim.cmd([[augroup autosave_group
      autocmd CursorHoldI,CursorHold * silent! update
    augroup END]])
    vim.g.autosave = true
  end
end

-- 47. Insert lorem ipsum paragraph
function M.lorem()
  local lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
  vim.api.nvim_put(vim.split(lorem, " "), "l", true, true)
end

-- 48. One-key "open Neovim config" (jump straight to init.lua)
function M.open_config()
  vim.cmd("e $MYVIMRC")
end


-- 11. Toggle spell checking with smart language cycling (en → fr → de → off)
function M.toggle_spell_cycle()
  if vim.wo.spell then
    if vim.bo.spelllang == "en" then
      vim.cmd("set spelllang=fr spell")
    elseif vim.bo.spelllang == "fr" then
      vim.cmd("set spelllang=de spell")
    else
      vim.cmd("set nospell")
    end
  else
    vim.cmd("set spell spelllang=en")
  end
end

-- 12. Open a floating terminal that re-uses the same window (like tmux)
vim.g.floaterm_win = nil
function M.toggle_floating_terminal()
  if vim.g.floaterm_win and vim.api.nvim_win_is_valid(vim.g.floaterm_win) then
    vim.api.nvim_win_close(vim.g.floaterm_win, true)
    vim.g.floaterm_win = nil
  else
    vim.cmd([[let $LINES=stdscrheight()]])
    vim.cmd("60new | terminal")
    vim.cmd("startinsert")
    vim.g.floaterm_win = vim.api.nvim_get_current_win()
    vim.wo.winfixheight = true
    vim.wo.winfixwidth = true
  end
end

-- 13. Git: Quick commit whole file with message from first line as comment
function M.git_commit_quick()
  vim.cmd("w")
  local msg = vim.fn.getline(1):match("^%s*//%s*(.-)$") or vim.fn.input("Commit message: ")
  vim.cmd(string.format("!git add %s && git commit -m '%s'", vim.fn.expand("%"), msg))
end

-- 14. Paste image from clipboard directly into Markdown / Org (macOS + Linux)
function M.paste_image()
  local ext = vim.fn.has("mac") == 1 and "png" or "png"
  local img_path = vim.fn.expand("%:p:h") .. "/assets/" .. os.date("%Y%m%d_%H%M%S") .. "." .. ext
  vim.fn.system(vim.fn.has("mac") == 1 and
    "pngpaste " .. vim.fn.shellescape(img_path) or
    "xclip -selection clipboard -t image/png -o > " .. vim.fn.shellescape(img_path))
  if vim.v.shell_error == 0 then
    local rel = vim.fn.fnamemodify(img_path, ":.")
    vim.api.nvim_paste("![" .. rel .. "](" .. rel .. ")", true, -1)
  else
    print("No image in clipboard or failed to paste")
  end
end

-- 15. One-key profiler (start/stop Neovim startuptime profiling)
vim.g.profiling = false
function M.toggle_profiler()
  if vim.g.profiling then
    vim.cmd("profile stop")
    vim.cmd("tabnew | edit profile.log")
    vim.g.profiling = false
  else
    vim.cmd("profile start profile.log")
    vim.cmd("profile func *")
    vim.cmd("profile file *")
    vim.g.profiling = true
    print("Profiling ON → run stuff → press <leader>P again")
  end
end

-- 16. Jump to next/prev git conflict marker
function M.next_conflict() vim.cmd("call search('^\\(<\\|=\\|>\\)\\{7\\}\\($\\)', 'w')") end
function M.prev_conflict() vim.cmd("call search('^\\(<\\|=\\|>\\)\\{7\\}\\($\\)', 'bw')") end

-- 17. Open current line on GitHub/GitLab with exact line range (visual mode too)
function M.open_line_in_github()
  local remote = vim.fn.systemlist("git config --get remote.origin.url")[1]:gsub("%.git$", ""):gsub("git@github.com:", "https://github.com/")
  local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
  local file = vim.fn.expand("%:p"):gsub(vim.fn.getcwd() .. "/", "")
  local line = vim.api.nvim_win_get_cursor(0)[1]
  if vim.fn.mode():find("[vV]") then
    local start = vim.fn.line("v")
    line = start .. "-" .. line
  end
  local url = remote .. "/blob/" .. branch .. "/" .. file .. "#L" .. line
  vim.cmd("silent !open " .. vim.fn.shellescape(url))
end

-- 18. Toggle auto-change directory (project-local vs global)
vim.g.autochdir = false
function M.toggle_autochdir()
  if vim.g.autochdir then
    vim.cmd("set noautochdir")
    vim.g.autochdir = false
  else
    vim.cmd("set autochdir")
    vim.g.autochdir = true
  end
end

-- 19. Quick HTTP server in current directory (Python one-liner)
function M.serve_current_dir()
  local port = 8080
  vim.cmd(string.format("split | terminal python3 -m http.server %d", port))
  print("Serving on http://localhost:" .. port)
end

-- 20. Convert current buffer between tabs ↔ spaces instantly
function M.retab_smart()
  local spaces = vim.fn.input("Spaces per tab (or Enter for detect): ")
  if spaces == "" then
    spaces = vim.bo.shiftwidth
  else
    spaces = tonumber(spaces)
  end
  vim.bo.expandtab = not vim.bo.expandtab
  vim.cmd("retab " .. spaces)
  print(vim.bo.expandtab and "→ Spaces" or "→ Tabs")
end

-- 21. Run macro over visual selection (the holy grail)
function M.execute_macro_over_visual()
  vim.cmd('echo "@".getcharstr()." over visual"')
  vim.cmd('normal! gv@' .. vim.fn.nr2char(vim.fn.getchar()))
end

-- 22. Toggle mouse (for when you’re lazy or presenting)
function M.toggle_mouse()
  if vim.o.mouse == "a" then
    vim.cmd("set mouse=")
    print("Mouse OFF")
  else
    vim.cmd("set mouse=a")
    print("Mouse ON")
  end
end

-- 23. Generate ctags + cscope in one shot (old-school but unbeatable)
function M.generate_tags()
  vim.cmd("!ctags -R . && cscope -Rbq")
  vim.cmd("cs reset")
  print("Tags + cscope regenerated")
end

-- 24. Smart "copy full path" / "copy relative path" / "copy filename"
function M.copy_path_variant()
  local variants = {
    p = vim.fn.expand("%:p"),      -- full path
    h = vim.fn.expand("%:p:h"),    -- directory
    t = vim.fn.expand("%:t"),      -- filename
    r = vim.fn.expand("%:.")       -- relative to cwd
  }
  print("p=full, h=dir, t=file, r=rel → choose:")
  local choice = vim.fn.nr2char(vim.fn.getchar())
  if variants[choice] then
    vim.fn.setreg("+", variants[choice])
    print("Copied: " .. variants[choice])
  end
end


-- 1. Smart toggle relative/absolute line numbers (context-aware)
function M.toggle_smart_numbers()
  if vim.wo.number == false then
    vim.wo.number = true
    vim.wo.relativenumber = true
  elseif vim.wo.relativenumber then
    vim.wo.relativenumber = false
  else
    vim.wo.number = false
    vim.wo.relativenumber = false
  end
end

-- 2. Quick run current file (detects filetype automatically)
function M.run_current_file()
  vim.cmd("w") -- save first
  local ft = vim.bo.filetype
  local file = vim.fn.expand("%:p")

  if ft == "python" then
    vim.cmd(string.format("split | terminal python3 '%s'", file))
  elseif ft == "lua" then
    vim.cmd("luafile %")
  elseif ft == "javascript" or ft == "typescript" then
    vim.cmd(string.format("split | terminal node '%s'", file))
  elseif ft == "go" then
    vim.cmd("split | terminal go run .")
  elseif ft == "rust" then
    vim.cmd("split | terminal cargo run")
  elseif ft == "sh" or ft == "bash" or ft == "zsh" then
    vim.cmd(string.format("split | terminal bash '%s'", file))
  elseif ft == "c" or ft == "cpp" then
    local bin = "/tmp/nvim_quickrun_" .. vim.fn.fnamemodify(file, ":t:r")
    vim.cmd(string.format("!gcc '%s' -o %s -lm && %s", file, bin, bin))
  else
    print("No runner defined for filetype: " .. ft)
  end
end

-- 3. Toggle live grep under cursor or visual selection (Telescope + ripgrep)
function M.live_grep_word_or_selection()
  local visual_mode = vim.fn.mode():lower():find("v")
  if visual_mode then
    vim.cmd('normal! "vy')  -- yank visual selection into "v register
    local selected = vim.fn.getreg("v")
    require("telescope.builtin").live_grep({ default_text = selected })
  else
    require("telescope.builtin").live_grep({ default_text = vim.fn.expand("<cword>") })
  end
end

-- 4. Auto-format on save + fix LSP diagnostics (super clean code)
function M.auto_format_and_fix()
  -- Format with LSP or fallback to vim.lsp.buf.format
  if vim.lsp.buf.format then
    vim.lsp.buf.format({ async = false })
  end

  -- Auto-fix common issues (e.g., eslint, prettier, etc.)
  vim.cmd("silent! EslintFixAll")  -- if you use eslint lsp
  -- Or for null-ls / none-ls users:
  -- vim.cmd("lua require('conform').format()")
end

-- 5. Jump to last edit position when reopening a file (better than built-in)
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
      vim.cmd("normal! zz")  -- center screen
    end
  end,
})

-- 6. Quick compile & run for competitive programming (C++/Rust/Python)
function M.cp_run()
  vim.cmd("w")
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.expand("%:p:h")
  local name = vim.fn.expand("%:t:r")

  if vim.bo.filetype == "cpp" then
    vim.cmd(string.format("!g++ -std=c++20 -O2 -Wall '%s' -o '%s/%s' && time '%s/%s'", file, dir, name, dir, name))
  elseif vim.bo.filetype == "rust" then
    vim.cmd("!rustc " .. file .. " -O && time ./" .. name)
  elseif vim.bo.filetype == "python" then
    vim.cmd("!time python3 " .. file)
  end
end

-- 7. Toggle distraction-free zen mode (Goyo + Limelight + twilight)
function M.toggle_zen_mode()
  if vim.g.goyo_active then
    vim.cmd("Goyo")
    vim.cmd("Limelight!")
    vim.cmd("TwilightDisable")
    vim.g.goyo_active = false
  else
    vim.cmd("Goyo 120")
    vim.cmd("Limelight!! 0.8")
    vim.cmd("TwilightEnable")
    vim.g.goyo_active = true
  end
end

-- 8. Insert UUID v4 (great for IDs in JSON, tests, etc.)
function M.insert_uuid()
  local uuid = vim.fn.systemlist("uuidgen")[1]:gsub("%-",""):lower()
  vim.api.nvim_paste(uuid, true, -1)
end

-- 9. Open current file in GitHub/GitLab (browser)
function M.open_in_github()
  vim.cmd([[call system('open https://github.com/' . system('git config --get remote.origin.url | sed "s/^git@github.com://" | sed "s/\\.git$//"') . '/blob/main/' . expand('%:p:S'))]])
end

-- 10. Smart close buffer but keep split layout
function M.smart_close_buffer()
  local bufcount = #vim.fn.getbufinfo({ buflisted = 1 })
  if bufcount == 1 then
    vim.cmd("q")
  else
    vim.cmd("bprevious | bdelete #")
  end
end

function _G.advanced_window_management()
    local windows = {}
    
    function windows.balance_windows_smart()
        vim.cmd([[
            function! SmartWindowBalance() abort
                let l:total_windows = winnr('$')
                let l:current_layout = []
                
                " Analyze current window layout
                for l:win in range(1, l:total_windows)
                    call win_execute(l:win, 'let l:current_layout += [winwidth(0) . "x" . winheight(0)]')
                endfor
                
                " Simple heuristic: if windows are very uneven, balance them
                let l:min_width = min(map(copy(l:current_layout), {_, v -> split(v, "x")[0]}))
                let l:max_width = max(map(copy(l:current_layout), {_, v -> split(v, "x")[0]}))
                
                if l:max_width - l:min_width > 20
                    return 1 " Needs balancing
                else
                    return 0 " Already balanced
                endif
            endfunction
        ]])
        
        local needs_balancing = vim.fn.SmartWindowBalance()
        
        if needs_balancing == 1 then
            vim.cmd('wincmd =')
            print("Windows balanced")
        else
            print("Windows already well balanced")
        end
    end
    
    function windows.create_scratch_buffer()
        vim.cmd([[
            function! CreateScratchBuffer() abort
                let l:scratch_buf = bufadd('scratch://' . strftime('%H%M%S'))
                call bufload(l:scratch_buf)
                call setbufvar(l:scratch_buf, '&buftype', 'nofile')
                call setbufvar(l:scratch_buf, '&bufhidden', 'hide')
                call setbufvar(l:scratch_buf, '&swapfile', 0)
                return l:scratch_buf
            endfunction
        ]])
        
        local scratch_buf = vim.fn.CreateScratchBuffer()
        vim.cmd('sbuffer ' .. scratch_buf)
        
        -- Set some helpful text
        local header = {
            "SCRATCH BUFFER - " .. os.date("%Y-%m-%d %H:%M:%S"),
            "Use this for temporary notes, calculations, or experiments",
            "This buffer will not be saved automatically",
            "",
            "--------------------------------------------------",
            ""
        }
        
        vim.api.nvim_buf_set_lines(scratch_buf, 0, -1, false, header)
        vim.api.nvim_buf_set_option(scratch_buf, 'modifiable', true)
        
        print("Created scratch buffer")
    end
    
    function windows.rotate_windows()
        vim.cmd([[
            function! RotateWindowLayout() abort
                let l:current_win = winnr()
                let l:total_windows = winnr('$')
                
                if l:total_windows < 2
                    echo "Need at least 2 windows to rotate"
                    return
                endif
                
                " Get all window IDs
                let l:win_ids = []
                for l:i in range(1, l:total_windows)
                    call add(l:win_ids, win_getid(l:i))
                endfor
                
                " Rotate the list
                call add(l:win_ids, remove(l:win_ids, 0))
                
                " Rearrange windows
                for l:i in range(l:total_windows)
                    call win_gotoid(l:win_ids[l:i])
                    execute (l:i + 1) . 'wincmd w'
                endfor
                
                " Return to original window
                call win_gotoid(win_getid(l:current_win))
            endfunction
        ]])
        
        vim.fn.RotateWindowLayout()
        print("Rotated window layout")
    end
    
    return windows
end

function _G.session_management()
    local session = {}
    
    function session.save_named_session()
        vim.cmd([[
            function! GetSessionName() abort
                let l:default_name = fnamemodify(getcwd(), ':t')
                let l:name = input('Session name: ', l:default_name)
                if l:name == ''
                    return ''
                endif
                return '~/.local/share/nvim/sessions/' . l:name . '.vim'
            endfunction
        ]])
        
        local session_file = vim.fn.GetSessionName()
        if session_file ~= "" then
            vim.cmd('mksession! ' .. session_file)
            print("Session saved: " .. session_file)
        end
    end
    
    function session.load_session()
        vim.cmd([[
            function! ListSessions() abort
                let l:session_dir = '~/.local/share/nvim/sessions'
                let l:session_files = split(glob(l:session_dir . '/*.vim'), "\n")
                let l:sessions = []
                for l:file in l:session_files
                    call add(l:sessions, fnamemodify(l:file, ':t:r'))
                endfor
                return l:sessions
            endfunction
        ]])
        
        local sessions = vim.fn.ListSessions()
        
        if #sessions == 0 then
            print("No saved sessions found")
            return
        end
        
        print("Available sessions:")
        for i, name in ipairs(sessions) do
            print(i .. ". " .. name)
        end
        
        local choice = vim.fn.input("Choose session (number): ")
        local session_num = tonumber(choice)
        
        if session_num and session_num > 0 and session_num <= #sessions then
            local session_file = '~/.local/share/nvim/sessions/' .. sessions[session_num] .. '.vim'
            vim.cmd('source ' .. session_file)
            print("Loaded session: " .. sessions[session_num])
        else
            print("Invalid choice")
        end
    end
    
    return session
end

function _G.git_helpers()
    local helpers = {}
    
    function helpers.smart_git_blame()
        vim.cmd([[
            function! GetGitBlameInfo() abort
                if !executable('git')
                    return ['', 'Git not available']
                endif
                
                let l:file = expand('%:p')
                let l:line = line('.')
                let l:cmd = 'git blame -L ' . l:line . ',' . l:line . ' -- ' . shellescape(l:file)
                let l:blame_output = systemlist(l:cmd)
                
                if v:shell_error != 0 || empty(l:blame_output)
                    return ['', 'Not in git repository or file not tracked']
                endif
                
                let l:blame_line = l:blame_output[0]
                let l:hash = matchstr(l:blame_line, '^\^\?\zs\x\+')
                let l:author = matchstr(l:blame_line, ')\s*\zs[^(]\+')
                let l:date = matchstr(l:blame_line, '\d\{4\}-\d\{2\}-\d\{2}')
                
                return [l:hash, trim(l:author) . ' (' . l:date . ')']
            endfunction
        ]])
        
        local hash, info = unpack(vim.fn.GetGitBlameInfo())
        
        if hash ~= "" then
            -- Create a floating window to show git info
            local buf = vim.api.nvim_create_buf(false, true)
            local width = 50
            local height = 3
            local row = 1
            local col = vim.o.columns - width - 1
            
            local opts = {
                style = "minimal",
                relative = "editor",
                width = width,
                height = height,
                row = row,
                col = col,
                border = "rounded"
            }
            
            local win = vim.api.nvim_open_win(buf, true, opts)
            
            local lines = {
                "Git Blame Info:",
                "Commit: " .. hash:sub(1, 8),
                "Author: " .. info
            }
            
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
            vim.api.nvim_buf_set_option(buf, 'filetype', 'gitblame')
            vim.api.nvim_buf_set_option(buf, 'modifiable', false)
            
            -- Auto-close after 3 seconds
            vim.defer_fn(function()
                if vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_win_close(win, true)
                end
            end, 3000)
        else
            print(info)
        end
    end
    
    function helpers.git_diff_current_line()
        vim.cmd([[
            function! GetGitDiffForLine() abort
                if !executable('git')
                    return ''
                endif
                
                let l:file = expand('%:p')
                let l:line = line('.')
                let l:cmd = 'git diff -U0 -- ' . shellescape(l:file) . ' | grep -A3 -B3 "^@@.*+' . l:line . '"'
                let l:diff_output = system(l:cmd)
                
                return split(l:diff_output, "\n")
            endfunction
        ]])
        
        local diff_lines = vim.fn.GetGitDiffForLine()
        
        if #diff_lines > 0 then
            -- Create scratch buffer with diff
            vim.cmd('botright 10new')
            local buf = vim.api.nvim_get_current_buf()
            vim.api.nvim_buf_set_name(buf, 'git_diff_line')
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, diff_lines)
            vim.api.nvim_buf_set_option(buf, 'modifiable', false)
            vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
            vim.api.nvim_buf_set_option(buf, 'filetype', 'diff')
            
            vim.cmd('setlocal wrap')
            print("Showing git diff for current line")
        else
            print("No changes for current line")
        end
    end
    
    return helpers
end

function _G.quickfix_helpers()
    local helpers = {}
    
    function helpers.filter_quickfix(pattern, invert)
        vim.cmd([[
            function! FilterQuickfix(pattern, invert) abort
                let l:new_list = []
                for l:item in getqflist()
                    let l:matches = l:item.text =~ a:pattern
                    if (a:invert && !l:matches) || (!a:invert && l:matches)
                        call add(l:new_list, l:item)
                    endif
                endfor
                call setqflist(l:new_list)
                echo "Filtered quickfix list"
            endfunction
        ]])
        
        vim.fn.FilterQuickfix(pattern, invert and 1 or 0)
    end
    
    function helpers.export_quickfix()
        vim.cmd([[
            function! ExportQuickfix() abort
                let l:filename = input('Export to file: ', 'quickfix_export.txt')
                if l:filename == ''
                    return
                endif
                execute 'redir > ' . l:filename
                silent execute 'copen'
                silent execute '%print'
                redir END
                echo 'Quickfix list exported to ' . l:filename
            endfunction
        ]])
        
        vim.fn.ExportQuickfix()
    end
    
    return helpers
end

function _G.fix_indentation()
    vim.cmd([[
        function! PreserveCursorPosition(command) abort
            let l:save = winsaveview()
            execute a:command
            call winrestview(l:save)
        endfunction
    ]])
    
    -- Save cursor position and execute commands
    vim.fn.PreserveCursorPosition("normal! mz")
    vim.fn.PreserveCursorPosition("execute 'normal! gg=G'")
    vim.fn.PreserveCursorPosition("normal! `z")
    
    print("Fixed indentation")
end

function _G.auto_format_code()
    local filetype = vim.bo.filetype
    
    vim.cmd([[
        function! HasFormatter() abort
            if &filetype == 'lua'
                return executable('stylua')
            elseif &filetype == 'python'
                return executable('black') || executable('autopep8')
            elseif &filetype == 'javascript' || &filetype == 'typescript'
                return executable('prettier')
            elseif &filetype == 'go'
                return 1 " gofmt is built-in
            else
                return 0
            endif
        endfunction
    ]])
    
    local has_formatter = vim.fn.HasFormatter()
    
    if has_formatter == 1 then
        -- Try LSP formatting first
        local success, _ = pcall(vim.lsp.buf.format)
        if not success then
            -- Fallback to filetype-specific formatting
            if filetype == "lua" then
                vim.cmd("!stylua %")
            elseif filetype == "python" then
                vim.cmd("!black %")
            elseif filetype == "javascript" or filetype == "typescript" then
                vim.cmd("!prettier --write %")
            elseif filetype == "go" then
                vim.cmd("!gofmt -w %")
            end
            vim.cmd("edit!") -- Reload the file
        end
        print("Formatted " .. filetype .. " code")
    else
        -- Use built-in formatting as last resort
        vim.cmd("normal! gg=G")
        print("Used basic formatting")
    end
end

function _G.visual_search_replace()
    local mode = vim.fn.mode()
    
    if mode ~= "v" and mode ~= "V" then
        print("Not in visual mode!")
        return
    end
    
    vim.cmd([[
        function! GetVisualSelection() abort
            let [line_start, column_start] = getpos("'<")[1:2]
            let [line_end, column_end] = getpos("'>")[1:2]
            let lines = getline(line_start, line_end)
            if len(lines) == 0
                return ''
            endif
            let lines[-1] = lines[-1][: column_end - 2]
            let lines[0] = lines[0][column_start - 1:]
            return join(lines, "\n")
        endfunction
    ]])
    
    local visual_selection = vim.fn.GetVisualSelection()
    
    if visual_selection == "" then
        print("No text selected!")
        return
    end
    
    -- Escape for Lua pattern and Vim regex
    local escaped_search = vim.fn.escape(visual_selection, '\\/.*$^~[]')
    local lua_escaped = visual_selection:gsub('([%(%)%.%%%+%-%*%?%[%^%$%]])', '%%%1')
    
    -- Get replacement text
    local replace_with = vim.fn.input("Replace with: ")
    
    if replace_with ~= "" then
        -- Use Vimscript for the actual substitution (more reliable with complex patterns)
        vim.cmd(':%s/' .. escaped_search .. '/' .. vim.fn.escape(replace_with, '\\/') .. '/g')
        print("Replaced all occurrences")
    end
end

function _G.smart_buffer_switch(direction)
    direction = direction or "next"
    
    vim.cmd([[
        function! HasModifiableBuffer() abort
            let l:bufs = filter(range(1, bufnr('$')), 'buflisted(v:val) && getbufvar(v:val, "&modifiable")')
            return len(l:bufs) > 1
        endfunction
    ]])
    
    local has_modifiable = vim.fn.HasModifiableBuffer()
    
    if has_modifiable == 1 then
        if direction == "next" then
            vim.cmd("bnext")
        else
            vim.cmd("bprevious")
        end
    else
        print("No other modifiable buffers available")
    end
end

-- Close buffer without closing window
function _G.smart_buffer_close()
    vim.cmd([[
        function! CloseBufferKeepWindow() abort
            if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) > 1
                bdelete
            else
                echo "Last buffer - cannot close"
            endif
        endfunction
    ]])
    
    vim.fn.CloseBufferKeepWindow()
end

-- Toggle comments intelligently based on file type
function _G.smart_comment_toggle()
    local filetype = vim.bo.filetype
    local comment_string = vim.api.nvim_buf_get_option(0, 'commentstring')
    
    -- Use Vimscript to get comment format
    vim.cmd([[
        function! GetCommentFormat() abort
            let l:comment_format = &commentstring
            if l:comment_format == '' || l:comment_format == '%s'
                " Fallback comment formats by filetype
                if &filetype == 'lua'
                    return '-- %s'
                elseif &filetype == 'python' || &filetype == 'sh' || &filetype == 'ruby'
                    return '# %s'
                elseif &filetype == 'vim'
                    return '" %s'
                else
                    return '/* %s */'
                endif
            endif
            return l:comment_format
        endfunction
    ]])
    
    local comment_format = vim.fn.GetCommentFormat()
    
    -- Extract left and right parts of comment
    local left, right = comment_format:match('^(.*)%%s(.*)$')
    left = left or ''
    right = right or ''
    
    -- Get current line
    local line = vim.fn.getline('.')
    
    -- Check if line is already commented
    local is_commented = false
    if left ~= '' then
        is_commented = line:match('^%s*' .. vim.pesc(left:gsub('%%s', '')))
    end
    
    if is_commented then
        -- Uncomment the line
        local uncommented_line = line:gsub('^%s*' .. vim.pesc(left:gsub('%%s', '')), '')
        uncommented_line = uncommented_line:gsub(vim.pesc(right:gsub('%%s', '')) .. '$', '')
        vim.fn.setline('.', uncommented_line)
    else
        -- Comment the line
        local indent = line:match('^(%s*)')
        local commented_line = indent .. left:gsub('%%s', '') .. line:gsub('^%s*', '') .. right:gsub('%%s', '')
        vim.fn.setline('.', commented_line)
    end
end



-- Remove trailing whitespace while remembering cursor position
function M.trim_trailing_whitespace()
  vim.cmd([[
    let l:pos = getpos(".")
    %s/\s\+$//e
    call setpos(".", l:pos)
  ]])
end


vim.keymap.set("n", "<leader>tw", M.trim_trailing_whitespace)


function M.toggle_bool()
  vim.cmd([[
    let l:word = expand("<cword>")
    if l:word ==# "true"
      execute "normal! ciwfalse"
    elseif l:word ==# "false"
      execute "normal! ciwtrue"
    endif
  ]])
end


vim.keymap.set("n", "<leader>tb", M.toggle_bool)


function M.highlight_todos()
  vim.cmd([[
    highlight TodoWord cterm=bold gui=bold guifg=#ffaf00
    match TodoWord /\v<(TODO|FIXME|BUG):?/
  ]])
end


vim.api.nvim_create_autocmd("BufEnter", {
  callback = M.highlight_todos
})


function M.restore_cursor()
  vim.cmd([[
    if line("'\"") >= 1 && line("'\"") <= line("$")
      exe "normal! g`\""
    endif
  ]])
end

vim.api.nvim_create_autocmd("BufReadPost", { callback = M.restore_cursor })


function M.smart_join()
  vim.cmd([[
    let l:save = @"
    normal! mzJ
    silent! %s/^\s\+/ /e
    normal! `z
    let @" = l:save
  ]])
end


vim.keymap.set("n", "J", M.smart_join)


function M.surround_open_close(open, close)
  vim.cmd(string.format([[
    let l:op = '%s'
    let l:cp = '%s'
    normal! vi%c
    execute "normal! c" . l:op . "\<C-r>\"" . l:cp
  ]], open, close, '"'))
end

-- Convenience
function M.surround_quotes() M.surround_open_close('"', '"') end
function M.surround_brackets() M.surround_open_close('[', ']') end


vim.keymap.set("v", "<leader>sq", M.surround_quotes)
vim.keymap.set("v", "<leader>sb", M.surround_brackets)


function M.smart_run()
  vim.cmd([[
    let l:file = expand("%:p")
    let l:base = expand("%:t:r")
    let l:ext = expand("%:e")

    if l:ext ==# 'c'
      exec "!gcc -O2 " . l:file . " -o " . l:base
      exec "!./" . l:base
    elseif l:ext ==# 'cpp'
      exec "!g++ -std=c++20 -O2 " . l:file . " -o " . l:base
      exec "!./" . l:base
    elseif l:ext ==# 'py'
      exec "!python3 " . l:file
    else
      echo "Unsupported file type"
    endif
  ]])
end


vim.keymap.set("n", "<leader>r", M.smart_run)


function M.duplicate_line()
  vim.cmd([[
    let l:pos = getpos(".")
    execute "normal! yyp"
    call setpos(".", l:pos)
  ]])
end


vim.keymap.set("n", "<leader>d", M.duplicate_line)


function M.focus_mode()
  vim.cmd([[
    if &relativenumber
      set norelativenumber
      set nocursorline
      set signcolumn=no
    else
      set relativenumber
      set cursorline
      set signcolumn=yes
    endif
  ]])
end


vim.keymap.set("n", "<leader>fm", M.focus_mode)


function M.search_in_split()
  vim.cmd([[
    let l:word = expand("<cword>")
    split
    execute "grep " . shellescape(l:word)
    copen
  ]])
end


vim.keymap.set("n", "<leader>gs", M.search_in_split)


function M.jump_prev_symbol()
  vim.cmd([[
    let l:pattern = '\v^(class|struct|fn|function|def|impl|enum|module|interface)\>'
    silent! execute "normal! ?".l:pattern."\<CR>zz"
  ]])
end


vim.keymap.set("n", "[f", M.jump_prev_symbol)


function M.jump_next_symbol()
  vim.cmd([[
    let l:pattern = '\v^(class|struct|fn|function|def|impl|enum|module|interface)\>'
    silent! execute "normal! /".l:pattern."\<CR>zz"
  ]])
end


vim.keymap.set("n", "]f", M.jump_next_symbol)


function M.toggle_comment()
  vim.cmd([[
    let l:line = getline('.')
    if l:line =~ '^\s*//'
      execute "s#^\s*//##"
    else
      execute "s#^#// #"
    endif
  ]])
end


vim.keymap.set("n", "<leader>cc", M.toggle_comment)


function M.duplicate_block()
  vim.cmd([[
    normal! gv"xy
    normal! `>p
  ]])
end


vim.keymap.set("v", "<leader>db", M.duplicate_block)


