local function list_symbols()
  local output = vim.fn.system({"c_symbols", "."})
  if vim.v.shell_error ~= 0 then
    print("Symbol scan failed")
    return
  end

  local lines = vim.split(output, "\n", { trimempty = true })
  local entries = {}
  for _, line in ipairs(lines) do
    local ok, obj = pcall(vim.fn.json_decode, line)
    if ok and obj then
      table.insert(entries, {
        filename = obj.file,
        lnum = obj.line,
        text = obj.name
      })
    end
  end

  -- Load into quickfix
  vim.fn.setqflist(entries, "r")
  vim.cmd("copen")
end

vim.keymap.set('n', '<leader>cs', list_symbols, { desc = "List C Symbols" })
