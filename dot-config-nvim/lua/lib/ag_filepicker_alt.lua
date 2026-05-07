-- ag_picker_split.lua
-- Minimal single-file Neovim plugin using `ag` that shows results in an Emacs-like horizontal split.

local M = {}
local api = vim.api
local uv = vim.loop

-- parse ag --vimgrep output: file:line:col:match
local function parse_ag_line(line)
  local file, l, c, text = line:match("([^:]+):(%d+):(%d+):%s?(.*)")
  if not file then return nil end
  return { file = file, line = tonumber(l), col = tonumber(c), text = text }
end

-- open or reuse bottom split results buffer; returns {buf, win}
local function open_results_split(height)
  height = height or 12
  -- Try to reuse existing buffer named "__ag_results__"
  for _, buf in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_valid(buf) and api.nvim_buf_get_name(buf) == "__ag_results__" then
      -- ensure it's shown in a window; if not, open at bottom
      for _, win in ipairs(api.nvim_list_wins()) do
        local b = api.nvim_win_get_buf(win)
        if b == buf then
          return { buf = buf, win = win }
        end
      end
      -- buffer exists but not visible: open a horizontal split at bottom and show it
      api.nvim_command("botright " .. tostring(height) .. "split")
      local win = api.nvim_get_current_win()
      api.nvim_win_set_buf(win, buf)
      return { buf = buf, win = win }
    end
  end

  -- create new scratch buffer
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_name(buf, "__ag_results__")
  api.nvim_buf_set_option(buf, "buftype", "nofile")
  api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  api.nvim_buf_set_option(buf, "swapfile", false)
  api.nvim_buf_set_option(buf, "filetype", "ag_results")
  -- open at bottom with fixed height
  api.nvim_command("botright " .. tostring(height) .. "split")
  local win = api.nvim_get_current_win()
  api.nvim_win_set_buf(win, buf)
  -- set some local window options for readability
  api.nvim_win_set_option(win, "wrap", false)
  api.nvim_buf_set_option(buf, "modifiable", false)
  return { buf = buf, win = win }
end

-- render full items buffer (overwrite)
local function render_items(buf, items)
  local lines = {}
  for i, it in ipairs(items) do
    lines[i] = string.format("%s:%d:%d: %s", it.file, it.line, it.col, it.text)
  end
  api.nvim_buf_set_option(buf, "modifiable", true)
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  api.nvim_buf_set_option(buf, "modifiable", false)
end

-- open selected item; mode can be nil, "split", or "vsplit"
local function open_item_and_jump(item, mode)
  if not item then return end
  local cmd
  if mode == "split" then
    cmd = "split " .. vim.fn.fnameescape(item.file)
  elseif mode == "vsplit" then
    cmd = "vsplit " .. vim.fn.fnameescape(item.file)
  else
    cmd = "edit " .. vim.fn.fnameescape(item.file)
  end
  api.nvim_command(cmd)
  api.nvim_win_set_cursor(0, { item.line, math.max(0, item.col - 1) })
end

-- run ag asynchronously; on_chunk(parsed) per result, on_done(results)
local function run_ag(query, cwd, on_chunk, on_done, opts)
  opts = opts or {}
  local args = { "--vimgrep", "--nocolor", "--nogroup" }
  if opts.ignore_case then table.insert(args, "--ignore-case") end
  table.insert(args, query)

  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)
  local handle
  local buf = ""
  local results = {}

  handle = uv.spawn("ag", {
    args = args,
    stdio = { nil, stdout, stderr },
    cwd = cwd,
  }, function(code, _signal)
    stdout:close()
    stderr:close()
    handle:close()
    -- parse remainder
    for line in (buf .. ""):gmatch("([^\n]*)\n?") do
      if line ~= "" then
        local p = parse_ag_line(line)
        if p then table.insert(results, p) end
      end
    end
    vim.schedule_wrap(function() on_done(results, code) end)()
  end)

  stdout:read_start(function(err, data)
    assert(not err, err)
    if data then
      buf = buf .. data
      local last_newline = buf:match(".*()\n")
      if last_newline then
        local complete = buf:sub(1, last_newline)
        buf = buf:sub(last_newline + 1)
        for line in complete:gmatch("([^\n]*)\n") do
          local p = parse_ag_line(line)
          if p then
            table.insert(results, p)
            if on_chunk then
              vim.schedule_wrap(function() on_chunk(p) end)()
            end
          end
        end
      end
    end
  end)

  stderr:read_start(function(err, data)
    assert(not err, err)
    -- ignore stderr in minimal example
  end)
end

-- state
local state = {
  buf = nil,
  win = nil,
  items = {},
  cwd = nil,
}

-- set up buffer-local mappings for the results buffer
local function setup_mappings(buf)
  local opts = { noremap = true, silent = true }
  local function bmap(lhs, rhs)
    api.nvim_buf_set_keymap(buf, "n", lhs, rhs, opts)
  end

  bmap("q", "<cmd>bwipeout! __ag_results__<CR>")
  bmap("j", "j")
  bmap("k", "k")

  -- Bridge callbacks through a global helper to avoid upvalue capture across user command boundaries
  _G._ag_picker_bridge = _G._ag_picker_bridge or {}
  _G._ag_picker_bridge.open_at = function(row, mode)
    local idx = tonumber(row)
    local item = state.items[idx]
    if not item then return end
    -- close the results window if you prefer; here we keep it open (like Emacs)
    open_item_and_jump(item, mode)
  end

  -- <CR>
  api.nvim_buf_set_keymap(buf, "n", "<CR>",
    "<cmd>lua _G._ag_picker_bridge.open_at(vim.api.nvim_win_get_cursor(0)[1])<CR>", opts)
  api.nvim_buf_set_keymap(buf, "n", "s",
    "<cmd>lua _G._ag_picker_bridge.open_at(vim.api.nvim_win_get_cursor(0)[1], 'split')<CR>", opts)
  api.nvim_buf_set_keymap(buf, "n", "v",
    "<cmd>lua _G._ag_picker_bridge.open_at(vim.api.nvim_win_get_cursor(0)[1], 'vsplit')<CR>", opts)
  -- jump to bottom / top
  bmap("G", "G")
  bmap("gg", "gg")
end

-- public search function
function M.search(query, opts)
  if not query or query == "" then
    api.nvim_echo({ { "Usage: :Ag <query>", "WarningMsg" } }, false, {})
    return
  end
  opts = opts or {}
  local cwd = opts.cwd or vim.fn.getcwd()
  state.cwd = cwd
  state.items = {}

  local res = open_results_split(opts.height or 12)
  state.buf = res.buf
  state.win = res.win

  -- show header lines then keep appending
  api.nvim_buf_set_option(state.buf, "modifiable", true)
  api.nvim_buf_set_lines(state.buf, 0, -1, false, {
    "ag results for: " .. query,
    "----------------------------------------",
  })
  api.nvim_buf_set_option(state.buf, "modifiable", false)

  setup_mappings(state.buf)

  local function on_chunk(parsed)
    table.insert(state.items, parsed)
    if api.nvim_buf_is_valid(state.buf) then
      local line = string.format("%s:%d:%d: %s", parsed.file, parsed.line, parsed.col, parsed.text)
      api.nvim_buf_set_option(state.buf, "modifiable", true)
      api.nvim_buf_set_lines(state.buf, -1, -1, false, { line })
      api.nvim_buf_set_option(state.buf, "modifiable", false)
    end
  end

  local function on_done(results)
    state.items = results
    if api.nvim_buf_is_valid(state.buf) then
      -- re-render full list to keep indexing consistent (optional)
      render_items(state.buf, results)
      -- place cursor on first result if exists
      if #results > 0 then
        local win = state.win
        if api.nvim_win_is_valid(win) then
          api.nvim_win_set_cursor(win, { 1, 0 })
        end
      end
    end
  end

  run_ag(query, cwd, on_chunk, on_done, opts)
end

-- command :Ag
function M.setup()
  api.nvim_create_user_command("Ag", function(opts)
    local q = opts.args
    if q == "" then
      api.nvim_echo({ { "Usage: :Ag <query>", "WarningMsg" } }, false, {})
      return
    end
    M.search(q, {})
  end, { nargs = "*", complete = "file" })
end

-- auto-setup when loaded as plugin file
pcall(function() if vim.fn.exists(":Ag") == 0 then M.setup() end end)

return M
