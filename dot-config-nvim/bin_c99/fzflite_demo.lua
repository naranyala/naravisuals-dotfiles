
local M = {}

function M.fzf(query, lines, cb)
  local job = vim.fn.jobstart({"fzf-lite", query}, {
    stdin = "pipe",
    on_stdout = function(_, data)
      if data then cb(data) end
    end,
  })

  for _, l in ipairs(lines) do
    vim.fn.chansend(job, l .. "\n")
  end

  vim.fn.chanclose(job, "stdin")
end

return M
