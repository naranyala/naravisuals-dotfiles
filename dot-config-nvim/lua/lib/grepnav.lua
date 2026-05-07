local M = {}

-- Default config
local config = {
  -- Engine priority: first available wins
  engine_priority = { "rg", "ag", "ack", "grep" },

  root_markers = {
    ".git", ".svn", ".hg", "Makefile", "package.json", "Cargo.toml",
    "go.mod", "pyproject.toml", "setup.py", "pom.xml", "build.gradle",
  },

  ignore = {
    ".git", "node_modules", ".cache", "build", "dist",
    ".venv", "__pycache__", ".next", ".nuxt", ".output",
  },

  window_height_ratio = 0.4,
  mappings = true,
}

local state = {}

function M.setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})

  vim.api.nvim_create_user_command("GrepNav", function(opts)
    M.grep(opts.args ~= "" and opts.args or nil)
  end, { nargs = "?", desc = "Ultimate project grep navigator" })

  if config.mappings ~= false then
    vim.keymap.set("n", "<leader>cg", function() 
      M.grep(vim.fn.expand("<cword>")) 
    end, { desc = "Grep word under cursor" })
    
    vim.keymap.set("n", "<leader>cG", function()
      vim.ui.input({ prompt = "Grep pattern: " }, function(input)
        if input and input ~= "" then M.grep(input) end
      end)
    end, { desc = "Grep with prompt" })
  end
end

local function find_root()
  local path = vim.fn.expand("%:p:h")
  if path == "" then path = vim.fn.getcwd() end

  while path and path ~= "/" and path ~= "" do
    for _, marker in ipairs(config.root_markers) do
      local full = path .. "/" .. marker
      if vim.loop.fs_stat(full) then
        return path
      end
    end
    local parent = vim.fn.fnamemodify(path, ":h")
    if parent == path then break end
    path = parent
  end
  return vim.fn.getcwd()
end

local function build_ignore_flags(tool)
  local flags = {}
  for _, dir in ipairs(config.ignore) do
    if tool == "rg" then
      table.insert(flags, "--glob")
      table.insert(flags, "!" .. dir .. "/")
    elseif tool == "ag" then
      table.insert(flags, "--ignore")
      table.insert(flags, dir)
    elseif tool == "ack" then
      table.insert(flags, "--ignore-directory=" .. dir)
    elseif tool == "grep" then
      table.insert(flags, "--exclude-dir=" .. dir)
    end
  end
  return flags
end

local function get_engine()
  for _, tool in ipairs(config.engine_priority) do
    if vim.fn.executable(tool) == 1 then
      return tool
    end
  end
  return nil
end

local function run_grep(pattern, root)
  local tool = get_engine()
  if not tool then
    vim.notify("No grep tool found (rg/ag/ack/grep)", vim.log.levels.ERROR)
    return nil
  end

  local old_cwd = vim.fn.getcwd()
  vim.cmd("silent! lcd " .. vim.fn.fnameescape(root))

  local ignore_flags = build_ignore_flags(tool)
  local cmd = {}

  if tool == "rg" then
    vim.list_extend(cmd, {
      "rg", "--vimgrep", "--no-heading", "--smart-case",
      "--follow", "--hidden", "--color=never"
    })
    vim.list_extend(cmd, ignore_flags)
    table.insert(cmd, "--")
    table.insert(cmd, pattern)
    table.insert(cmd, ".")

  elseif tool == "ag" then
    vim.list_extend(cmd, {
      "ag", "--vimgrep", "--smart-case", "--follow", "--hidden", "--depth", "50"
    })
    vim.list_extend(cmd, ignore_flags)
    table.insert(cmd, pattern)
    table.insert(cmd, ".")

  elseif tool == "ack" then
    vim.list_extend(cmd, {
      "ack", "--nocolor", "--nogroup", "--column", "--smart-case"
    })
    vim.list_extend(cmd, ignore_flags)
    table.insert(cmd, pattern)

  elseif tool == "grep" then
    vim.list_extend(cmd, {
      "grep", "-rInH", "--color=never"
    })
    vim.list_extend(cmd, ignore_flags)
    table.insert(cmd, pattern)
    table.insert(cmd, ".")
  end

  local output = vim.fn.systemlist(cmd)
  vim.cmd("silent! lcd " .. vim.fn.fnameescape(old_cwd))

  if vim.v.shell_error ~= 0 or not output or #output == 0 then
    return nil, tool
  end

  -- Filter out error messages
  local filtered = {}
  for _, line in ipairs(output) do
    if not line:match("^Binary file") and not line:match("error:") and line ~= "" then
      table.insert(filtered, line)
    end
  end

  if #filtered == 0 then
    return nil, tool
  end

  return filtered, tool
end

local function parse_line(line, root)
  -- Try file:line:col:text format first (rg, ag, ack)
  local file, lnum, col, text = line:match("^(.+):(%d+):(%d+):(.*)$")
  
  if file then
    if not vim.startswith(file, "/") then
      file = root .. "/" .. file:gsub("^%./", "")
    end
    return {
      filename = file,
      lnum = tonumber(lnum),
      col = tonumber(col),
      text = vim.trim(text),
      display = line
    }
  end
  
  -- Try file:line:text format (grep fallback)
  file, lnum, text = line:match("^(.+):(%d+):(.*)$")
  
  if file then
    if not vim.startswith(file, "/") then
      file = root .. "/" .. file:gsub("^%./", "")
    end
    return {
      filename = file,
      lnum = tonumber(lnum),
      col = 1,
      text = vim.trim(text),
      display = line
    }
  end
  
  return nil
end

local function open_window(results, root, pattern, tool)
  vim.cmd("botright split")
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, buf)

  local height = math.max(10, math.floor(vim.o.lines * config.window_height_ratio))
  vim.api.nvim_win_set_height(win, height)

  -- Build display with header
  local header = string.format("Pattern: %s | Root: %s | Tool: %s | Results: %d", 
    pattern, root, tool, #results)
  local separator = string.rep("─", vim.api.nvim_win_get_width(win))
  
  local lines = { header, separator }
  for _, r in ipairs(results) do
    table.insert(lines, r.display)
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "grepnav"

  return buf, win
end

local function setup_keymaps(buf, win, results)
  local opts = { buffer = buf, silent = true, nowait = true }
  
  local header_offset = 2  -- Skip header lines

  vim.keymap.set("n", "<CR>", function()
    local line_nr = vim.api.nvim_win_get_cursor(win)[1]
    local idx = line_nr - header_offset
    
    if idx < 1 or idx > #results then return end
    
    local res = results[idx]
    if not res then return end
    
    vim.cmd("wincmd p")
    vim.cmd("edit " .. vim.fn.fnameescape(res.filename))
    vim.api.nvim_win_set_cursor(0, { res.lnum, res.col - 1 })
    vim.cmd("normal! zz")
    vim.cmd("wincmd p")
  end, opts)

  vim.keymap.set("n", "o", function()
    local line_nr = vim.api.nvim_win_get_cursor(win)[1]
    local idx = line_nr - header_offset
    
    if idx < 1 or idx > #results then return end
    
    local res = results[idx]
    if not res then return end
    
    vim.cmd("wincmd p")
    vim.cmd("edit " .. vim.fn.fnameescape(res.filename))
    vim.api.nvim_win_set_cursor(0, { res.lnum, res.col - 1 })
    vim.cmd("normal! zz")
  end, opts)

  vim.keymap.set("n", "q", function()
    pcall(vim.api.nvim_win_close, win, true)
  end, opts)
  
  vim.keymap.set("n", "<Esc>", function()
    pcall(vim.api.nvim_win_close, win, true)
  end, opts)
  
  -- Navigation that skips header
  vim.keymap.set("n", "j", function()
    local cursor = vim.api.nvim_win_get_cursor(win)
    local total = vim.api.nvim_buf_line_count(buf)
    if cursor[1] < total then
      vim.api.nvim_win_set_cursor(win, { cursor[1] + 1, 0 })
    end
  end, opts)
  
  vim.keymap.set("n", "k", function()
    local cursor = vim.api.nvim_win_get_cursor(win)
    if cursor[1] > header_offset + 1 then
      vim.api.nvim_win_set_cursor(win, { cursor[1] - 1, 0 })
    end
  end, opts)
end

function M.grep(pattern)
  if not pattern or pattern == "" then
    pattern = vim.fn.input("Grep: ", vim.fn.expand("<cword>"))
    if not pattern or pattern == "" then return end
  end

  local root = find_root()
  local output, tool = run_grep(pattern, root)

  if not output then
    vim.notify(string.format('No matches for "%s" (tool: %s)', pattern, tool or "unknown"), 
      vim.log.levels.INFO)
    return
  end

  local results = {}
  for _, line in ipairs(output) do
    local parsed = parse_line(line, root)
    if parsed then
      table.insert(results, parsed)
    end
  end

  if #results == 0 then
    vim.notify("No valid results found", vim.log.levels.WARN)
    return
  end

  local buf, win = open_window(results, root, pattern, tool)
  setup_keymaps(buf, win, results)

  state.buf, state.win, state.results = buf, win, results
  
  -- Position cursor on first result (skip header)
  vim.api.nvim_win_set_cursor(win, { 3, 0 })
end

return M
