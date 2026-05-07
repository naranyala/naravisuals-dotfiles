
local M = {}
function M.root(cb)
  vim.fn.jobstart({"git-digest","root"}, { stdout_buffered=true, on_stdout=function(_,d) cb(d) end })
end
function M.branch(cb)
  vim.fn.jobstart({"git-digest","branch"}, { stdout_buffered=true, on_stdout=function(_,d) cb(d) end })
end
function M.changed(cb)
  vim.fn.jobstart({"git-digest","changed"}, { stdout_buffered=true, on_stdout=function(_,d) cb(d) end })
end
function M.blame(file, line, cb)
  vim.fn.jobstart({"git-digest","blame",file,line}, { stdout_buffered=true, on_stdout=function(_,d) cb(d) end })
end
return M
