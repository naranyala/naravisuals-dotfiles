
local function socket_send(payload, cb)
  local sock = "/tmp/taskd-lite.sock"
  local handle = io.popen("printf %s | socat - UNIX-CONNECT:"..sock, "r")
  local out = handle:read("*a")
  handle:close()
  if cb then cb(out) end
end

-- add task
socket_send("ADD long_running_command && echo done\n", function(res) print(res) end)
-- status
socket_send("STATUS\n", print)
-- log
socket_send("LOG 1\n", print)
