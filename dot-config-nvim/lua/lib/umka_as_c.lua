-- init.lua
local group = vim.api.nvim_create_augroup("UmkaAsC", { clear = true })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = group,
  pattern = { "*.um", "*.umka" },
  command = "setfiletype c",
})
