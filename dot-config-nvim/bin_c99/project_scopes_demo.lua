local root, lang
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    vim.system({'project-scopes'}, {cwd=vim.fn.expand('%:p:h')}, function(obj)
      root, lang = obj.stdout:match('([^\t]+)\t([^\t]+)')
      vim.g.project_root = root
    end)
  end
})
