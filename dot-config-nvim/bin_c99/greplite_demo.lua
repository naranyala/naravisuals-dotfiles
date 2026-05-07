
local function grep(pattern, file, cb)
  vim.fn.jobstart({"grep-lite", pattern, file}, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      cb(data)
    end,
  })
end
