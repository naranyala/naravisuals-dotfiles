-- lua/suckless_infobar.lua
-- Fixed version with bug corrections and improvements

local M = {}

local state = {
  win       = nil,
  buf       = nil,
  gen       = 0,
  fragments = { left = {}, center = {}, right = {} },
  processes = {},
  pipes     = {},  -- Track pipes separately for cleanup
  config    = nil,
  visible   = true,
  render_scheduled = false,
}

------------------------------------------------------------------------
-- helpers
------------------------------------------------------------------------
local function kill_all()
  -- Close all pipes first
  for _, pipe in pairs(state.pipes) do
    if pipe and not pipe:is_closing() then 
      pipe:close()
    end
  end
  state.pipes = {}
  
  -- Then kill processes
  for _, proc in pairs(state.processes) do
    if proc and not proc:is_closing() then 
      proc:kill("sigterm")
    end
  end
  state.processes = {}
end

local function close_win()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win, state.buf = nil, nil
end

local function join(section)
  local t = {}
  for _, src in ipairs(state.config.sources) do
    if src.section == section then
      local text = state.fragments[section][src.name] or ""
      if text ~= "" then t[#t + 1] = text end
    end
  end
  return table.concat(t, state.config.sep)
end

------------------------------------------------------------------------
-- render with debouncing
------------------------------------------------------------------------
local render_immediate  -- forward declaration

local function render()
  if not state.visible then return end
  if not state.config then return end
  
  -- Debounce rapid updates
  if state.render_scheduled then return end
  state.render_scheduled = true
  
  vim.schedule(function()
    state.render_scheduled = false
    render_immediate()
  end)
end

render_immediate = function()
  if not state.visible then return end
  if not state.config then return end

  local left   = join("left")
  local center = join("center")
  local right  = join("right")

  local pad = state.config.pad
  left   = string.rep(" ", pad.left)   .. left
  center = string.rep(" ", pad.center) .. center .. string.rep(" ", pad.center)
  right  = right .. string.rep(" ", pad.right)

  local cols = vim.o.columns
  if not cols or cols == 0 then
    -- Retry with exponential backoff
    local attempts = state.render_attempts or 0
    if attempts < 5 then
      state.render_attempts = attempts + 1
      vim.defer_fn(function()
        state.render_attempts = 0
        render_immediate()
      end, 50 * (2 ^ attempts))
    end
    return
  end
  state.render_attempts = 0

  -- FIXED: Actually use the center section!
  local line
  local total = #left + #center + #right
  
  if total >= cols then
    -- Truncate if too wide
    line = (left .. center .. right):sub(1, cols)
  else
    -- Distribute space: left [gap] center [gap] right
    local remaining = cols - total
    local left_gap = math.floor(remaining / 2)
    local right_gap = remaining - left_gap
    
    line = left .. string.rep(" ", left_gap) .. center .. string.rep(" ", right_gap) .. right
  end

  -- Create or reuse float
  if not state.win or not vim.api.nvim_win_is_valid(state.win) then
    state.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[state.buf].bufhidden = "wipe"

    -- FIXED: Better window offset approach
    state.win = vim.api.nvim_open_win(state.buf, false, {
      relative = 'editor',
      row = 0,
      col = 0,
      width = cols,
      height = 1,
      style = 'minimal',
      focusable = false,
      zindex = 50,
    })

    -- Use showtabline instead of global winbar hack
    if vim.o.showtabline ~= 2 then
      vim.o.showtabline = 2  -- Always show, creates offset naturally
    end

    vim.wo[state.win].winhighlight = "NormalFloat:SucklessInfobar,FloatBorder:SucklessInfobar"

    -- Mouse handler
    if state.config.click then
      vim.keymap.set("n", "<LeftRelease>", function() M.click() end,
                     { buffer = state.buf, nowait = true })
    end
  end

  vim.api.nvim_win_set_width(state.win, cols)
  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, { line })
  vim.bo[state.buf].modifiable = false
end

------------------------------------------------------------------------
-- spawn source with proper cleanup
------------------------------------------------------------------------
local function start_source(src)
  local uv     = vim.uv or vim.loop
  local stdout = uv.new_pipe()
  local my_gen = state.gen
  
  -- Mode: 'oneshot' (run once) vs 'stream' (continuous output)
  local mode = src.mode or "oneshot"
  
  -- Buffer for incomplete lines (streaming mode)
  local buffer = ""
  
  -- Timeout protection (only for oneshot mode)
  local timeout_timer = nil
  if mode == "oneshot" and src.timeout then
    timeout_timer = uv.new_timer()
    timeout_timer:start(src.timeout * 1000, 0, function()
      if state.processes[src.name] then
        state.processes[src.name]:kill("sigterm")
      end
      if state.pipes[src.name] then
        state.pipes[src.name]:close()
      end
    end)
  end

  -- Interval timer for periodic refresh (oneshot mode only)
  local interval_timer = nil
  if mode == "oneshot" and src.interval then
    interval_timer = uv.new_timer()
  end

  local function cleanup_timers()
    if timeout_timer and not timeout_timer:is_closing() then
      timeout_timer:close()
    end
    if interval_timer and not interval_timer:is_closing() then
      interval_timer:close()
    end
  end

  local handle, pid = uv.spawn(src.cli, {
    args = src.args or {},
    stdio = { nil, stdout, nil },
  }, function(code)
    -- FIXED: Always close pipe
    if stdout and not stdout:is_closing() then
      stdout:close()
    end
    
    cleanup_timers()
    
    if my_gen ~= state.gen then return end
    
    state.processes[src.name] = nil
    state.pipes[src.name] = nil
    
    -- Restart if it's a stream that exited unexpectedly
    if mode == "stream" and code ~= 0 and code ~= 15 then
      if state.config.debug then
        state.fragments[src.section][src.name] = "⟳ " .. src.name
        render()
      end
      -- Retry after delay
      vim.defer_fn(function()
        if my_gen == state.gen and state.config then
          start_source(src)
        end
      end, (src.retry_delay or 5) * 1000)
    elseif mode == "oneshot" and src.interval then
      -- Schedule next run for periodic oneshot commands
      if interval_timer then
        interval_timer:start(src.interval * 1000, 0, function()
          if my_gen == state.gen and state.config then
            start_source(src)
          end
        end)
      end
    elseif state.config.debug and code ~= 0 and code ~= 15 then
      state.fragments[src.section][src.name] = "✖ " .. src.name
      render()
    end
  end)

  -- FIXED: Handle spawn failure properly
  if not handle then
    if stdout and not stdout:is_closing() then
      stdout:close()
    end
    cleanup_timers()
    state.fragments[src.section][src.name] = "✖ " .. src.name
    render()
    return
  end

  state.processes[src.name] = handle
  state.pipes[src.name] = stdout

  stdout:read_start(function(err, data)
    if err or not data or my_gen ~= state.gen then return end
    
    if mode == "stream" then
      -- Streaming mode: process line-by-line as data arrives
      buffer = buffer .. data
      
      -- Process complete lines
      while true do
        local line_end = buffer:find("\n")
        if not line_end then break end
        
        local line = buffer:sub(1, line_end - 1)
        buffer = buffer:sub(line_end + 1)
        
        line = vim.trim(line)
        if line ~= "" then
          -- Apply transform function if provided
          if src.transform then
            line = src.transform(line)
          end
          
          state.fragments[src.section][src.name] = line
          render()
        end
      end
    else
      -- Oneshot mode: take last non-empty line
      local last = data:match("([^\r\n]+)%s*$")
      if last and last ~= "" then
        last = vim.trim(last)
        
        -- Apply transform function if provided
        if src.transform then
          last = src.transform(last)
        end
        
        state.fragments[src.section][src.name] = last
        render()
      end
    end
  end)
end

------------------------------------------------------------------------
-- public API
------------------------------------------------------------------------
function M.setup(cfg)
  if not cfg or not cfg.sources or #cfg.sources == 0 then
    error("[suckless_infobar] 'sources' table is required")
  end

  -- Bump generation to invalidate old callbacks
  state.gen = state.gen + 1
  local my_gen = state.gen

  kill_all()
  close_win()

  state.config = {
    sources   = cfg.sources,
    sep       = cfg.separator or " │ ",
    pad       = vim.tbl_extend("force", { left = 1, center = 2, right = 1 }, cfg.padding or {}),
    debug     = cfg.debug == true,
    click     = cfg.click == true,
  }

  -- Default highlight
  vim.api.nvim_set_hl(0, "SucklessInfobar", { fg = "#c0caf5", bg = "#1a1b26", bold = false })

  state.fragments = { left = {}, center = {}, right = {} }
  for _, src in ipairs(state.config.sources) do
    if my_gen ~= state.gen then return end
    state.fragments[src.section][src.name] = ""
    -- Add default timeout if not specified
    src.timeout = src.timeout or 30
    start_source(src)
  end

  -- Autocmds
  local group_resize = vim.api.nvim_create_augroup("SucklessInfobarResize", { clear = true })
  vim.api.nvim_create_autocmd({ "VimResized", "DirChanged", "BufEnter" }, {
    group = group_resize,
    callback = function() render() end,
  })

  local group_clean = vim.api.nvim_create_augroup("SucklessInfobarCleanup", { clear = true })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group_clean,
    callback = function()
      kill_all()
      close_win()
    end,
  })

  render()
end

function M.toggle()
  state.visible = not state.visible
  if state.visible then render() else close_win() end
end

function M.reload()
  if state.config then M.setup(state.config) end
end

function M.update(name, text)
  if not state.config then return end
  for _, src in ipairs(state.config.sources) do
    if src.name == name then
      state.fragments[src.section][name] = text or ""
      render()
      return
    end
  end
end

function M.click()
  if not state.config.click then return end
  local pos = vim.fn.getmousepos()
  -- Stub for custom click handling
  -- You can map column positions to sources here
end

return M

-- Example usage in init.lua:
--[[
require('suckless_infobar').setup({
  sources = {
    -- ONESHOT MODE: Run once, display result
    { 
      section = "left",
      name = "mode",
      cli = "echo",
      args = {"NORMAL"},
      mode = "oneshot"  -- default
    },
    
    -- PERIODIC ONESHOT: Run every N seconds
    { 
      section = "center",
      name = "clock",
      cli = "date",
      args = {"+%H:%M:%S"},
      mode = "oneshot",
      interval = 1,  -- refresh every 1 second
      timeout = 5
    },
    
    -- STREAM MODE: Long-running process, continuous updates
    {
      section = "right",
      name = "cpu",
      cli = "bash",
      args = {
        "-c",
        -- Streams CPU usage every second
        "while true; do top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1; sleep 1; done"
      },
      mode = "stream",
      retry_delay = 5,  -- retry after 5s if stream dies
      transform = function(line)
        return "CPU: " .. line .. "%"
      end
    },
    
    -- STREAM: Tail a log file
    {
      section = "right",
      name = "logs",
      cli = "tail",
      args = {"-f", "/var/log/app.log"},
      mode = "stream",
      transform = function(line)
        -- Only show last 50 chars
        return line:sub(-50)
      end
    },
    
    -- STREAM: Custom monitoring script
    {
      section = "left",
      name = "battery",
      cli = "bash",
      args = {"-c", "while true; do cat /sys/class/power_supply/BAT0/capacity; sleep 10; done"},
      mode = "stream",
      transform = function(line)
        local pct = tonumber(line)
        local icon = pct > 80 and "🔋" or pct > 20 and "🔌" or "⚠️ "
        return icon .. " " .. line .. "%"
      end
    },
  },
  separator = " │ ",
  padding   = { left = 1, center = 2, right = 1 },
  debug = false,
  click = false,
})

-- You can also update sources manually from Lua:
vim.keymap.set('n', '<leader>um', function()
  local mode = vim.fn.mode()
  require('suckless_infobar').update('mode', mode)
end)
--]]
