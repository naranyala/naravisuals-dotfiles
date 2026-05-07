
local M = {}

function M.toggle_header_source()
  vim.cmd([[
    let l:file = expand("%:t")
    let l:root = expand("%:r")
    let l:ext = expand("%:e")

    if l:ext =~# '^\(c\|cpp\|cc\|cxx\)$'
      let l:targets = ['h', 'hpp', 'hh']
    else
      let l:targets = ['c', 'cpp', 'cc', 'cxx']
    endif

    for ext in l:targets
      let l:try = l:root . '.' . ext
      if filereadable(l:try)
        execute "edit " . l:try
        break
      endif
    endfor
  ]])
end


vim.keymap.set("n", "<leader>hs", M.toggle_header_source)


function M.clean_blank_lines()
  vim.cmd([[
    silent! g/^\s*$/d
  ]])
end


vim.keymap.set("n", "<leader>ce", M.clean_blank_lines)


function M.peek_buffer(dir)
  vim.cmd([[
    let l:cur = bufnr('%')
    let l:bufs = filter(range(1, bufnr('$')), 'buflisted(v:val)')
    let l:i = index(l:bufs, l:cur)
  ]])

  if dir == "next" then
    vim.cmd("let l:target = l:bufs[(l:i + 1) % len(l:bufs)]")
  else
    vim.cmd("let l:target = l:bufs[(l:i - 1 + len(l:bufs)) % len(l:bufs)]")
  end

  vim.cmd([[
    execute "pedit +" l:target
    wincmd P
  ]])
end


vim.keymap.set("n", "<leader>pn", function() M.peek_buffer("next") end)
vim.keymap.set("n", "<leader>pp", function() M.peek_buffer("prev") end)


function M.rename_word()
  vim.cmd([[
    let l:old = expand('<cword>')
    let l:new = input("Rename " . l:old . " → ")

    if l:new != ""
      execute "%s/\\V" . escape(l:old, '/\') . "/" . l:new . "/g"
    endif
  ]])
end


vim.keymap.set("n", "<leader>rn", M.rename_word)


function M.wrap_paren()
  vim.cmd([[ execute "normal! I(" | execute "normal! A)" ]])
end


function M.wrap_brace()
  vim.cmd([[ execute "normal! I{" | execute "normal! A}" ]])
end


vim.keymap.set("n", "<leader>wp", M.wrap_paren)
vim.keymap.set("n", "<leader>{", M.wrap_brace)


function M.jump_error()
  vim.cmd([[
    if getqflist() == []
      echo "No errors"
    else
      cwindow
      cfirst
    endif
  ]])
end


vim.keymap.set("n", "<leader>je", M.jump_error)


function M.outline_split()
  vim.cmd([[
    vnew
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal noswapfile
    execute "!ctags -x --sort=no " . expand('%:p')
    0r!ctags -x --sort=no " . expand('%:p')
  ]])
end


vim.keymap.set("n", "<leader>os", M.outline_split)


function M.toggle_softwrap()
  vim.cmd([[
    if &wrap
      set nowrap
      set nolist
    else
      set wrap
      set linebreak
      set list
    endif
  ]])
end


vim.keymap.set("n", "<leader>sw", M.toggle_softwrap)


function M.jump_next_change()
  vim.cmd([[
    silent! normal! ]c
    zz
  ]])
end

function M.jump_prev_change()
  vim.cmd([[
    silent! normal! [c
    zz
  ]])
end


vim.keymap.set("n", "]c", M.jump_next_change)
vim.keymap.set("n", "[c", M.jump_prev_change)


function M.flash_line()
  vim.cmd([[
    highlight FlashLine guibg=#444444
    execute "match FlashLine /\%" . line('.') . "l/"
    redraw
    sleep 150m
    match none
  ]])
end


vim.keymap.set("n", "gl", M.flash_line)


function M.diff_disk()
  vim.cmd([[
    diffthis
    vnew | read #
    normal! ggdd
    diffthis
  ]])
end


vim.keymap.set("n", "<leader>df", M.diff_disk)


function M.tabs_to_spaces()
  vim.cmd([[ %s/\t/  /g ]])
end

function M.spaces_to_tabs()
  vim.cmd([[ %s/  /\t/g ]])
end


vim.keymap.set("n", "<leader>ts", M.tabs_to_spaces)
vim.keymap.set("n", "<leader>st", M.spaces_to_tabs)


function M.sort_imports()
  vim.cmd([[
    g/^#\s*include/ sort
    g/^import / sort
    g/^using / sort
  ]])
end


vim.keymap.set("n", "<leader>si", M.sort_imports)

function M.insert_header_guard()
  vim.cmd([[
    let l:name = toupper(substitute(expand('%:t:r'), '\W', '_', 'g'))
    let l:guard = l:name . "_H"

    call append(0, "#ifndef " . l:guard)
    call append(1, "#define " . l:guard)
    call append(line('$'), "#endif /* " . l:guard . " */")
  ]])
end


vim.keymap.set("n", "<leader>hg", M.insert_header_guard)




function M.extract_selection()
  vim.cmd([[
    normal! gv"xy
    new
    call setline(1, split(@x, "\n"))
  ]])
end


vim.keymap.set("v", "<leader>x", M.extract_selection)


function M.clean_workspace()
  vim.cmd([[
    wall
    for b in range(1, bufnr('$'))
      if buflisted(b) && !getbufvar(b, '&modified')
        execute "bdelete " . b
      endif
    endfor
  ]])
end


vim.keymap.set("n", "<leader>cw", M.clean_workspace)


function M.focus_function()
  vim.cmd([[
    normal! zM
    normal! zv
    normal! zO
  ]])
end


vim.keymap.set("n", "<leader>ff", M.focus_function)


function M.surround_html(tag)
  vim.cmd(string.format([[
    let l:word = expand("<cword>")
    execute "normal! ciw<%s>" . l:word . "</%s>"
  ]], tag, tag))
end


vim.keymap.set("n", "<leader>sh1", function() M.surround_html("h1") end)
vim.keymap.set("n", "<leader>sp",  function() M.surround_html("p") end)


function M.align(char)
  vim.cmd(string.format([[
    execute ':%s/\v\s*%s/\=repeat(" ", 20 - virtcol(".")) . "%s"/g'
  ]], char, char))
end


vim.keymap.set("n", "<leader>a=", function() M.align("=") end)


function M.toggle_qf()
  vim.cmd([[
    if empty(filter(getwininfo(), 'v:val.quickfix'))
      copen
    else
      cclose
    endif
  ]])
end


vim.keymap.set("n", "<leader>qf", M.toggle_qf)


function M.scratch()
  vim.cmd([[
    enew
    setlocal buftype=nofile bufhidden=hide noswapfile
  ]])
end


vim.keymap.set("n", "<leader>ns", M.scratch)


function M.copy_path()
  vim.cmd([[ let @+ = expand("%:p") ]])
end

function M.copy_dir()
  vim.cmd([[ let @+ = expand("%:p:h") ]])
end


vim.keymap.set("n", "<leader>cp", M.copy_path)
vim.keymap.set("n", "<leader>cd", M.copy_dir)


