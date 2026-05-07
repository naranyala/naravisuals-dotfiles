
-- mini_explorer.lua
-- Minimal, robust file explorer for Neovim (single-file plugin)
-- Toggle with :MiniExplorer or <leader>e

local M = {}

-- Default configuration
M.config = {
  height = 12,
  mappings = {
    toggle        = "q",
    close         = "<Esc>",
    open          = "<CR>",
    parent        = { "-", "<BS>" },
    toggle_hidden = "a",
  },
  show_hidden = false,
  sort = "dirs-first", -- "dirs-first" | "name"
}

-- Internal state (kept private)
local state = {
  buf = nil,
  win = nil,
  cwd = vim.fn.getcwd(),
  stack = {},
  cursor = 1,
}

local uv = vim.loop

-- Utilities --------------------------------------------------------------

local function normalize(path)
  if not path or path == "" then return "/" end
  local resolved = vim.fn.resolve(path)
  return vim.fn.simplify(resolved)
end

local function is_root(path)
  return path == "/" or path == "" or path == nil
end

local function stat_path(path)
  if not path then return nil end
  local ok, stat = pcall(uv.fs_stat, path)
  if not ok then return nil end
  return stat
end

local function join_path(dir, name)
  if dir == "/" then
    return "/" .. name
  else
    return dir .. "/" .. name
  end
end

local function get_full_path(entry)
  if entry == "../" then
    return vim.fn.fnamemodify(state.cwd, ":h")
  end
  local clean = entry:gsub("/$", "")
  return join_path(state.cwd, clean)
end

-- Directory listing ------------------------------------------------------

local function list_dir(dir)
  local entries = {}
  local fd, err = uv.fs_scandir(dir)
  if not fd then
    return entries
  end

  while true do
    local name, ftype = uv.fs_scandir_next(fd)
    if not name then break end

    if not M.config.show_hidden then
      if name:sub(1,1) == "." and name ~= "." and name ~= ".." then
        goto continue
      end
    end

    local suffix = (ftype == "directory") and "/" or ""
    table.insert(entries, name .. suffix)

    ::continue::
  end

  -- Optional: add parent entry if not root
  if not is_root(dir) then
    table.insert(entries, 1, "../")
  end

  -- Sorting
  if M.config.sort == "dirs-first" then
    table.sort(entries, function(a,b)
      local a_dir = a:sub(-1) == "/"
      local b_dir = b:sub(-1) == "/"
      if a_dir ~= b_dir then
        return a_dir -- directories first
      end
      return a:lower() < b:lower()
    end)
  else
    table.sort(entries, function(a,b)
      return a:lower() < b:lower()
    end)
  end

  return entries
end

-- Refresh UI -------------------------------------------------------------

local function safe_set_win_title(win, title)
  -- nvim_win_set_config exists in newer Neovim; wrap in pcall to be safe
  if not vim.api.nvim_win_is_valid(win) then return end
  if vim.api.nvim_win_set_config then
    pcall(vim.api.nvim_win_set_config, win, { title = title })
  end
end

local function refresh()
  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then return end
  if not (state.win and vim.api.nvim_win_is_valid(state.win)) then return end

  local items = list_dir(state.cwd)

  -- Replace buffer contents safely
  vim.api.nvim_buf_set_option(state.buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, items)
  vim.api.nvim_buf_set_option(state.buf, "modifiable", false)

  -- Set a window title if available
  local short = (state.cwd == vim.fn.getenv("HOME") and "~") or state.cwd
  safe_set_win_title(state.win, " MiniExplorer :: " .. short .. " ")

  -- Restore cursor within valid range
  local max_line = #items
  if max_line == 0 then
    state.cursor = 1
  else
    state.cursor = math.max(1, math.min(state.cursor, max_line))
  end

  -- Move cursor
  pcall(vim.api.nvim_win_set_cursor, state.win, { state.cursor, 0 })
end

-- Navigation / actions ---------------------------------------------------

local function cd(new_dir)
  new_dir = normalize(new_dir)

  local stat = stat_path(new_dir)
  if not stat or stat.type ~= "directory" then
    vim.notify("Not a directory: " .. tostring(new_dir), vim.log.levels.ERROR)
    return false
  end

  local ok = pcall(vim.cmd.cd, new_dir)
  if not ok then
    vim.notify("Cannot cd into: " .. new_dir, vim.log.levels.ERROR)
    return false
  end

  table.insert(state.stack, state.cwd)
  state.cwd = new_dir
  state.cursor = 1
  refresh()
  return true
end

local function open_current()
  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then return end
  local lnum = vim.api.nvim_win_get_cursor(state.win)[1]
  local entry = vim.api.nvim_buf_get_lines(state.buf, lnum-1, lnum, false)[1]
  if not entry then return end

  if entry == "../" then
    local parent = vim.fn.fnamemodify(state.cwd, ":h")
    if parent ~= state.cwd then cd(parent) end
    return
  end

  if entry:sub(-1) == "/" then
    cd(get_full_path(entry))
    return
  end

  local full = get_full_path(entry)
  local stat = stat_path(full)
  if not stat then
    vim.notify("File vanished: " .. full, vim.log.levels.WARN)
    refresh()
    return
  end

  if stat.type == "directory" then
    cd(full)
    return
  end

  -- It's a file: open it
  M.close()
  vim.cmd("edit " .. vim.fn.fnameescape(full))
end

-- Window open/close ------------------------------------------------------

function M.close()
  -- Remove autocmds attached to buffer (if buffer exists)
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    pcall(vim.api.nvim_buf_clear_namespace, state.buf, -1, 0, -1)
    pcall(vim.api.nvim_buf_set_var, state.buf, "mini_explorer_active", nil)
    -- remove autocmds in case they exist (buffer-local group)
    pcall(vim.api.nvim_buf_del_keymap, state.buf, "n", "j")
  end

  if state.win and vim.api.nvim_win_is_valid(state.win) then
    pcall(vim.api.nvim_win_close, state.win, true)
  end

  state.win = nil
  state.buf = nil
  state.stack = {}
  state.cwd = vim.fn.getcwd()
  state.cursor = 1
end

function M.toggle()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    M.close()
    return
  end

  -- Create buffer
  state.buf = vim.api.nvim_create_buf(false, true) -- listed=false, scratch
  vim.api.nvim_buf_set_name(state.buf, "MiniExplorer")
  vim.api.nvim_buf_set_option(state.buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(state.buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(state.buf, "swapfile", false)
  vim.api.nvim_buf_set_option(state.buf, "modifiable", false)
  -- store marker
  pcall(vim.api.nvim_buf_set_var, state.buf, "mini_explorer_active", true)

  -- Open a bottom split
  vim.cmd("botright " .. tostring(M.config.height) .. "split")
  state.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.win, state.buf)

  -- Window-local options (set safely)
  pcall(vim.api.nvim_win_set_option, state.win, "number", false)
  pcall(vim.api.nvim_win_set_option, state.win, "cursorline", true)
  pcall(vim.api.nvim_win_set_option, state.win, "relativenumber", false)

  -- Buffer-local mappings & autocmds
  local buf_opts = { buffer = state.buf, silent = true, nowait = true }

  -- Toggle/close
  vim.keymap.set("n", M.config.mappings.toggle, M.toggle, buf_opts)
  vim.keymap.set("n", M.config.mappings.close, M.toggle, buf_opts)

  -- Open
  vim.keymap.set("n", M.config.mappings.open, open_current, buf_opts)

  -- Parent (multiple keys)
  local parents = type(M.config.mappings.parent) == "table" and M.config.mappings.parent or { M.config.mappings.parent }
  for _, k in ipairs(parents) do
    vim.keymap.set("n", k, function()
      -- emulate opening the first line when it's "../"
      local lnum = vim.api.nvim_win_get_cursor(state.win)[1]
      local entry = vim.api.nvim_buf_get_lines(state.buf, lnum-1, lnum, false)[1]
      if entry == "../" then
        local parent = vim.fn.fnamemodify(state.cwd, ":h")
        if parent ~= state.cwd then cd(parent) end
      else
        open_current()
      end
    end, buf_opts)
  end

  -- Toggle hidden
  vim.keymap.set("n", M.config.mappings.toggle_hidden, function()
    M.config.show_hidden = not M.config.show_hidden
    state.cursor = 1
    refresh()
    vim.notify("Hidden files: " .. (M.config.show_hidden and "shown" or "hidden"))
  end, buf_opts)

  -- Move keys with cursor tracking (buffer-local, update state.cursor via autocmd instead of embedding state into string)
  vim.keymap.set("n", "j", "j", buf_opts)
  vim.keymap.set("n", "k", "k", buf_opts)
  vim.keymap.set("n", "G", "G", buf_opts)
  vim.keymap.set("n", "gg", "gg", buf_opts)

  -- Keep state.cursor in sync by using buffer-local autocmds
  local group = vim.api.nvim_create_augroup("MiniExplorer_" .. tostring(state.buf), { clear = true })
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = group,
    buffer = state.buf,
    callback = function()
      -- protect from invalid win/buf
      if not (state.win and vim.api.nvim_win_is_valid(state.win)) then return end
      if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then return end
      local l = vim.api.nvim_win_get_cursor(state.win)[1]
      state.cursor = l
    end,
  })

  -- Initial cwd and refresh
  state.cwd = vim.fn.getcwd()
  state.cursor = 1
  state.stack = {}

  refresh()
end

-- Setup function ---------------------------------------------------------

function M.setup(user_cfg)
  M.config = vim.tbl_deep_extend("force", M.config, user_cfg or {})
  -- Create user command & mapping (global)
  pcall(vim.api.nvim_create_user_command, "MiniExplorer", function() M.toggle() end, { desc = "Toggle MiniExplorer" })
  pcall(vim.keymap.set, "n", "<leader>e", function() M.toggle() end, { desc = "MiniExplorer" })
end

-- Fallback: if user doesn't call setup explicitly, still provide defaults
M.setup()

return M
