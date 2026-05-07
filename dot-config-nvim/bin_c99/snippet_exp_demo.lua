vim.keymap.set('i', '<C-p>', function()
  local snip = vim.fn.expand('<cword>')
  local file = vim.fn.stdpath('config')..'/snippets/all.snippets'
  vim.system({'snippet-exp', file, snip}, {}, function(obj)
    vim.api.nvim_buf_set_lines(0, vim.fn.line('.'), vim.fn.line('.'), false,
                               vim.split(obj.stdout, '\n'))
  end)
end, {expr=true})
