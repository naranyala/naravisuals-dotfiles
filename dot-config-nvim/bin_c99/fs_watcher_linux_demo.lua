-- Lua side: fs_watcher_plugin.lua

local M = {}
local watcher_job = nil
local project_root = vim.loop.cwd() -- Start watching current directory

-- Callback to process the events sent from the C utility's stdout
local function on_event_received(err, data, event)
  if err then
    vim.notify("FS Watcher Error: " .. err, vim.log.levels.ERROR)
    return
  end

  if data then
    -- 'data' is a table of lines (strings). Process each event.
    for _, line in ipairs(data) do
      if line and line ~= "" then
        -- Example line: "MODIFY|/path/to/project/file.lua"
        local type_str, file_path = line:match("([^|]+)|(.*)")

        if type_str and file_path then
          -- Process the event:
          vim.notify("File changed: " .. type_str .. " " .. file_path, vim.log.levels.INFO, { title = "FS Watcher" })

          if file_path:match("init.lua$") then
            -- A core config file changed: prompt for reload
            vim.cmd("redraw")
            print("init.lua changed. Run :source % to reload config.")
          end
          -- Add logic here to signal LSP or refresh diagnostics
        end
      end
    end
  end
end

function M.start_watcher()
  if watcher_job then M.stop_watcher() end

  -- Use jobstart to run the C utility persistently
  watcher_job = vim.fn.jobstart({
    "path/to/fs_watcher", project_root
  }, {
    on_stdout = vim.schedule_wrap(on_event_received), -- Asynchronously process events
    on_exit = function(_, code, __)
      vim.notify("FS Watcher stopped with code: " .. code, vim.log.levels.WARN)
      watcher_job = nil
    end,
    -- Redirect stderr to pipe for debugging, stdin to null
    stdio = { "null", "pipe", "pipe" }
  })

  if watcher_job > 0 then
    vim.notify("FS Watcher started successfully in " .. project_root, vim.log.levels.INFO)
  else
    vim.notify("Failed to start FS Watcher.", vim.log.levels.ERROR)
  end
end

function M.stop_watcher()
  if watcher_job then
    vim.fn.jobstop(watcher_job)
    watcher_job = nil
    vim.notify("FS Watcher shut down.", vim.log.levels.INFO)
  end
end

return M
