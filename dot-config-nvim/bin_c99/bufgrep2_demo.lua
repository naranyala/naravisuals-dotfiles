local files = {}
for _, b in ipairs(vim.api.nvim_list_bufs()) do
  local n = vim.api.nvim_buf_get_name(b)
  if vim.fn.filereadable(n) == 1 then files[#files+1] = n end
end
if #files == 0 then return end
local pat = vim.fn.input('Buffer grep: ')
vim.fn.setqflist({}, 'r')
vim.fn.jobstart({'bufgrep', pat, unpack(files)}, {
  stdout_buffered = true,
  on_stdout = function(_, data)
    local qf = {}
    for _, l in ipairs(data or {}) do
      local f, line, col, txt = l:match('^([^:]+):(%d+):(%d+):(.*)')
      if f then
        qf[#qf+1] = {filename=f, lnum=tonumber(line), col=tonumber(col), text=txt}
      end
    end
    vim.fn.setqflist(qf, 'a')
  end,
  on_exit = function() vim.cmd('copen') end
})
