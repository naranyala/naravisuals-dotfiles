local tag = vim.fn.expand('<cword>')
vim.system({'tag-jump', 'tags', tag}, {}, function(obj)
  local file, lnum = obj.stdout:match('([^\t]+)\t(%d+)')
  if file then
    vim.cmd.edit(file)
    vim.api.nvim_win_set_cursor(0, {tonumber(lnum), 0})
  else
    vim.notify('tag not found', vim.log.levels.WARN)
  end
end)
