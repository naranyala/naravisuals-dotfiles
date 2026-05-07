local path = vim.api.nvim_buf_get_name(0)
vim.system({'indent-ranger', path}, {}, function(obj)
  local style, width = obj.stdout:match('(%w+)%s+(%d+)')
  if style == 'space' then
    vim.bo.expandtab = true
    vim.bo.shiftwidth = tonumber(width)
    vim.bo.tabstop = tonumber(width)
  else
    vim.bo.expandtab = false
    vim.bo.tabstop = 8
  end
  vim.notify('Detected indent: '..style..' '..width)
end)
