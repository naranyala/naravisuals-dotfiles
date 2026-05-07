vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function(args)
    vim.system({'indent-ranger', args.file}, {}, function(obj)
      local style, width = obj.stdout:match('(%w+)%s+(%d+)')
      if style == 'space' then
        vim.bo[args.buf].expandtab = true
        vim.bo[args.buf].shiftwidth = tonumber(width)
        vim.bo[args.buf].tabstop = tonumber(width)
      else
        vim.bo[args.buf].expandtab = false
        vim.bo[args.buf].tabstop = 8
      end
    end)
  end
})
