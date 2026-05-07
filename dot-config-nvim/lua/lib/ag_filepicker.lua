
-- ag_filepicker.lua
-- Minimal single-file Neovim plugin using `ag`.
-- Selecting a search result replaces the entire original buffer's contents
-- with the selected file's contents.

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
  for _, buf in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_valid(buf) and api.nvim_buf_get_name(buf) == "__ag_results__" then
      for _, win in ipairs(api.nvim_list_wins()) do
        if api.nvim_win_get_buf(win) == buf then
          return { buf = buf, win = win }
        end
      end
      api.nvim_command("botright " .. tostring(height) .. "split")
      local win = api.nvim_get_current_win()
      api.nvim_win_set_buf(win, buf)
      return { buf = buf, win = win }
    end
  end

  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_name(buf, "__ag_results__")
  api.nvim_buf_set_option(buf, "buftype", "nofile")
  api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  api.nvim_buf_set_option(buf, "swapfile", false)
  api.nvim_buf_set_option(buf, "filetype", "ag_results")
  api.nvim_command("botright " .. tostring(height) .. "split")
  local win = api.nvim_get_current_win()
  api.nvim_win_set_buf(win, buf)
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

-- read file safely, return nil on error
local function read_file_lines(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then return nil, "failed to read: " .. tostring(path) end
  return lines
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
  end)
end

-- State: items + buffers
local state = {
  results_buf = nil,
  results_win = nil,
  items = {},
  cwd = nil,
  original_buf = nil, -- buffer that was active when search started
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

  -- Bridge callback via global helper
  _G._ag_replace_bridge = _G._ag_replace_bridge or {}
  _G._ag_replace_bridge.open_and_replace = function(row)
    local idx = tonumber(row)
    local item = state.items[idx]
    if not item then return end

    -- Read replacement file
    local lines, err = read_file_lines(item.file)
    if not lines then
      api.nvim_err_writeln(err)
      return
    end

    -- Close results window first to return focus to original buffer/window
    -- but keep original_buf reference (the buffer we will replace)
    pcall(api.nvim_buf_delete, state.results_buf, { force = true })
    state.results_buf = nil
    state.results_win = nil

    -- Ensure original buffer still exists
    if not (state.original_buf and api.nvim_buf_is_valid(state.original_buf)) then
      -- If original buffer isn't valid, open a new unnamed buffer
      api.nvim_command("enew")
      state.original_buf = api.nvim_get_current_buf()
    end

    -- Replace entire contents of the original buffer
    local ok, _ = pcall(function()
      -- make the buffer modifiable, replace lines, then restore 'modifiable' accordingly
      api.nvim_buf_set_option(state.original_buf, "modifiable", true)
      api.nvim_buf_set_lines(state.original_buf, 0, -1, false, lines)
      api.nvim_buf_set_option(state.original_buf, "modifiable", true)
      -- set the buffer name to the file path (optional behavior)
      api.nvim_buf_set_name(state.original_buf, item.file)
      -- jump cursor to the matched line inside the original window
      -- find window showing the original buffer; prefer the window that was active at start
      local target_win = nil
      for _, w in ipairs(api.nvim_list_wins()) do
        if api.nvim_win_get_buf(w) == state.original_buf then
          target_win = w
          break
        end
      end
      if target_win then
        api.nvim_set_current_win(target_win)
        api.nvim_win_set_cursor(target_win, { math.max(1, item.line), math.max(0, item.col - 1) })
      else
        -- if no window shows it, open it in current window
        api.nvim_set_current_buf(state.original_buf)
        api.nvim_win_set_cursor(0, { math.max(1, item.line), math.max(0, item.col - 1) })
      end
    end)
    if not ok then
      api.nvim_err_writeln("Failed to replace buffer contents")
    end
  end

  -- <CR> triggers open_and_replace on the cursor row
  api.nvim_buf_set_keymap(buf, "n", "<CR>",
    "<cmd>lua _G._ag_replace_bridge.open_and_replace(vim.api.nvim_win_get_cursor(0)[1])<CR>", opts)
  -- s / v behave the same (they will replace original buffer and keep current layout)
  api.nvim_buf_set_keymap(buf, "n", "s",
    "<cmd>lua _G._ag_replace_bridge.open_and_replace(vim.api.nvim_win_get_cursor(0)[1])<CR>", opts)
  api.nvim_buf_set_keymap(buf, "n", "v",
    "<cmd>lua _G._ag_replace_bridge.open_and_replace(vim.api.nvim_win_get_cursor(0)[1])<CR>", opts)

  bmap("G", "G")
  bmap("gg", "gg")
end

-- public search: open results split, run ag, append incremental results
function M.search(query, opts)
  if not query or query == "" then
    api.nvim_echo({ { "Usage: :Ag <query>", "WarningMsg" } }, false, {})
    return
  end
  opts = opts or {}
  local cwd = opts.cwd or vim.fn.getcwd()
  state.cwd = cwd
  state.items = {}
  -- record original buffer (the one active when starting search)
  state.original_buf = api.nvim_get_current_buf()

  local res = open_results_split(opts.height or 12)
  state.results_buf = res.buf
  state.results_win = res.win

  api.nvim_buf_set_option(state.results_buf, "modifiable", true)
  api.nvim_buf_set_lines(state.results_buf, 0, -1, false, {
    "ag results for: " .. query,
    "----------------------------------------",
  })
  api.nvim_buf_set_option(state.results_buf, "modifiable", false)

  setup_mappings(state.results_buf)

  local function on_chunk(parsed)
    table.insert(state.items, parsed)
    if api.nvim_buf_is_valid(state.results_buf) then
      local line = string.format("%s:%d:%d: %s", parsed.file, parsed.line, parsed.col, parsed.text)
      api.nvim_buf_set_option(state.results_buf, "modifiable", true)
      api.nvim_buf_set_lines(state.results_buf, -1, -1, false, { line })
      api.nvim_buf_set_option(state.results_buf, "modifiable", false)
    end
  end

  local function on_done(results)
    state.items = results
    if api.nvim_buf_is_valid(state.results_buf) then
      render_items(state.results_buf, results)
      if #results > 0 and api.nvim_win_is_valid(state.results_win) then
        api.nvim_win_set_cursor(state.results_win, { 1, 0 })
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
