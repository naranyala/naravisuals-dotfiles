local qf = vim.fn.getqflist({items=0}).items
local tmp = vim.fn.tempname()..'.json'
local fd = io.open(tmp,'w')
fd:write(vim.json.encode(qf)) fd:close()
local bufname = vim.api.nvim_buf_get_name(0)
vim.system({'quickfix-filter'}, {
  env = { SEVERITY='E', BUFFER=bufname },
  stdout = function(_, data)
    if data then vim.fn.setqflist(vim.json.decode(data)) end
  end,
  stdin = io.open(tmp,'r')
})
