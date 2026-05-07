local function smart_reload()
  local buf = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(buf)
  if filepath == "" then return end

  local result = vim.fn.system({"c_digest", filepath})
  if vim.v.shell_error ~= 0 then return end

  local ok, data = pcall(vim.fn.json_decode, result)
  if ok and data and data.changed then
    vim.cmd("checktime") -- or e!
    print("Reloaded: " .. filepath)
  end
end

-- Call every 2 seconds
vim.defer_fn(function()
  smart_reload()
  vim.loop.timer_start(2000, 2000, vim.schedule_wrap(smart_reload))
end, 1000)
