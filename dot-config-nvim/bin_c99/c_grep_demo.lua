local function semantic_grep(pattern)
  if not pattern or pattern == "" then return end
  local files = vim.fn.globpath(vim.fn.getcwd(), "**/*.{c,h,cpp,hpp}", 1, 1)
  if #files == 0 then return end

  local cmd = {"c_grep", pattern}
  for _, f in ipairs(files) do table.insert(cmd, f) end

  local output = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then return end

  local qf = {}
  for line in output:gmatch("[^\r\n]+") do
    local ok, item = pcall(vim.fn.json_decode, line)
    if ok and item then
      table.insert(qf, {
        filename = item.file,
        lnum = item.line,
        text = vim.trim(item.snippet:gsub("\n", " "))
      })
    end
  end

  vim.fn.setqflist(qf, "r")
  vim.cmd("copen")
end

vim.keymap.set('n', '<leader>sg', function()
  vim.ui.input({ prompt = "Semantic Grep: " }, semantic_grep)
end, { desc = "Semantic Grep" })
