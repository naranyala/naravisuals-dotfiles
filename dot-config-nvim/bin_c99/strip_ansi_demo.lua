vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  callback = function()
    local qf = vim.fn.getqflist()
    for _, item in ipairs(qf) do
      if item.text then
        item.text = vim.fn.system('strip-ansi', item.text):gsub('\n','')
      end
    end
    vim.fn.setqflist(qf, 'r')
  end
})
