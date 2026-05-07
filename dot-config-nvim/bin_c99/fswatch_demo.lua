
local M = {}
function M.start(path, on_event)
  local cmd = {"fswatch-c", path}
  local jid = vim.fn.jobstart(cmd, {
    stdout_buffered = false,
    on_stdout = function(_, data, _)
      if not data then return end
      for _,line in ipairs(data) do
        if line ~= "" then
          local ev, name = line:match("([^\t]+)\t(.+)")
          on_event(ev, name)
        end
      end
    end
  })
  return jid -- store to stop later with vim.fn.jobstop
end
return M
