
local M = {}

function M.index(paths, cb)
  -- paths: array of file paths or nil to read from find
  local cmd = {"ctags-lite"}
  if paths then
    vim.fn.jobstart(cmd, {
      stdin = "pipe",
      stdout_buffered = true,
      on_stdout = function(_, data)
        if data then cb(data) end
      end,
    })
    -- send file list
    local jid = vim.fn.jobstart(cmd, {stdin="pipe", stdout_buffered=true, on_stdout=function() end})
    for _,p in ipairs(paths) do vim.fn.chansend(jid, p.."\n") end
    vim.fn.chanclose(jid, "stdin")
  else
    local finder = io.popen("find . -type f \\( -name '*.c' -o -name '*.h' -o -name '*.lua' \\)")
    local out = finder:read("*a"); finder:close()
    local lines = {}
    for l in out:gmatch("[^\r\n]+") do table.insert(lines,l) end
    return M.index(lines, cb)
  end
end

return M
