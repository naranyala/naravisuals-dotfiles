local files = {}                       -- collect open buffer paths
for _, b in ipairs(vim.api.nvim_list_bufs()) do
  local n = vim.api.nvim_buf_get_name(b)
  if vim.fn.filereadable(n) == 1 then table.insert(files, n) end
end
local pat = vim.fn.input('Pattern: ')
vim.fn.setqflist({}, 'r')
vim.fn.jobstart({'bufgrep', pat, unpack(files)}, {
  stdout_buffered = true,
  on_stdout = function(_, data)
    if data then
      local qf = {}
      for _, l in ipairs(data) do
        local f, line, col, txt = l:match('^([^:]+):(%d+):(%d+):(.*)')
        if f then
          table.insert(qf, {filename=f, lnum=tonumber(line), col=tonumber(col), text=txt})
        end
      end
      vim.fn.setqflist(qf, 'a')
    end
  end,
  on_exit = function() vim.cmd('copen') end
})
