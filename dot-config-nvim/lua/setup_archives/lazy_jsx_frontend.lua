local M = {}

--------------------------------------------------------------
-- State
--------------------------------------------------------------
local state = {
  results = {},
  buf = nil,
  win = nil,
}

--------------------------------------------------------------
-- Find project root directory
--------------------------------------------------------------
local function find_root()
  -- Root markers to look for
  local markers = {
    ".git",
    ".svn",
    ".hg",
    "Makefile",
    "package.json",
    "Cargo.toml",
    "go.mod",
    "setup.py",
    "pom.xml",
    "build.gradle",
  }

  local current_file = vim.fn.expand("%:p")
  local current_dir = vim.fn.fnamemodify(current_file, ":h")
  
  -- If no file open, use current working directory
  if current_file == "" or current_dir == "" then
    current_dir = vim.fn.getcwd()
  end

  -- Walk up the directory tree
  local path = current_dir
  while path and path ~= "/" do
    for _, marker in ipairs(markers) do
      local marker_path = path .. "/" .. marker
      if vim.fn.isdirectory(marker_path) == 1 or vim.fn.filereadable(marker_path) == 1 then
        return path
      end
    end
    
    -- Go up one level
    local parent = vim.fn.fnamemodify(path, ":h")
    if parent == path then
      break
    end
    path = parent
  end

  -- Fallback to current working directory
  return vim.fn.getcwd()
end

--------------------------------------------------------------
-- Tool detection
--------------------------------------------------------------
local function get_grep_tool()
  if vim.fn.executable("rg") == 1 then
    return "rg"
  elseif vim.fn.executable("ag") == 1 then
    return "ag"
  elseif vim.fn.executable("grep") == 1 then
    return "grep"
  end
  return nil
end

--------------------------------------------------------------
-- Run grep command with deep search from root
--------------------------------------------------------------
local function run_grep(pattern, root_dir)
  local tool = get_grep_tool()
  if not tool then
    vim.notify("No grep tool found (rg, ag, or grep)", vim.log.levels.ERROR)
    return nil
  end

  -- Change to root directory for search
  local original_dir = vim.fn.getcwd()
  vim.cmd("cd " .. vim.fn.fnameescape(root_dir))

  local cmd
  if tool == "rg" then
    -- rg with full recursion, follow symlinks, search hidden files
    cmd = string.format(
      "rg --vimgrep --no-heading --follow --hidden --max-depth 50 " ..
      "--glob '!.git/' --glob '!node_modules/' --glob '!.cache/' " ..
      "'%s' . 2>/dev/null",
      pattern:gsub("'", "'\\''")
    )
  elseif tool == "ag" then
    -- ag with deep search
    cmd = string.format(
      "ag --vimgrep --follow --hidden --depth 50 " ..
      "--ignore .git --ignore node_modules --ignore .cache " ..
      "'%s' . 2>/dev/null",
      pattern:gsub("'", "'\\''")
    )
  else
    -- grep with recursive search
    cmd = string.format(
      "grep -rIn --exclude-dir=.git --exclude-dir=node_modules " ..
      "--exclude-dir=.cache '%s' . 2>/dev/null",
      pattern:gsub("'", "'\\''")
    )
  end

  local handle = io.popen(cmd)
  if not handle then
    vim.cmd("cd " .. vim.fn.fnameescape(original_dir))
    return nil
  end
  
  local output = handle:read("*a")
  handle:close()
  
  -- Restore original directory
  vim.cmd("cd " .. vim.fn.fnameescape(original_dir))
  
  if not output or output == "" then
    return nil
  end

  return vim.split(output, "\n", { trimempty = true })
end

--------------------------------------------------------------
-- Parse result line
--------------------------------------------------------------
local function parse_result(line, root_dir)
  -- Format: file:line:col:text or file:line:text
  local file, lnum, col, text = line:match("^(.+):(%d+):(%d+):(.*)$")
  if file then
    -- Make path absolute if relative
    if not vim.startswith(file, "/") then
      file = root_dir .. "/" .. file
    end
    return {
      file = file,
      lnum = tonumber(lnum),
      col = tonumber(col),
      text = vim.trim(text),
      display = line
    }
  end
  
  file, lnum, text = line:match("^(.+):(%d+):(.*)$")
  if file then
    if not vim.startswith(file, "/") then
      file = root_dir .. "/" .. file
    end
    return {
      file = file,
      lnum = tonumber(lnum),
      col = 1,
      text = vim.trim(text),
      display = line
    }
  end
  
  return nil
end

--------------------------------------------------------------
-- Create horizontal split window
--------------------------------------------------------------
local function create_window(lines, root_dir)
  -- Create new horizontal split at bottom
  vim.cmd("botright split")
  
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_get_current_win()
  
  vim.api.nvim_win_set_buf(win, buf)
  
  -- Set window height (about 40% of screen)
  local height = math.floor(vim.o.lines * 0.4)
  vim.api.nvim_win_set_height(win, height)
  
  -- Add header with root directory
  local header = string.format("Search root: %s | Results: %d", root_dir, #lines)
  local separator = string.rep("─", vim.api.nvim_win_get_width(win))
  local display_lines = { header, separator }
  vim.list_extend(display_lines, lines)
  
  return buf, win, 2  -- offset for header lines
end

--------------------------------------------------------------
-- Setup keymaps
--------------------------------------------------------------
local function setup_keymaps(buf, win, offset)
  local opts = { noremap = true, silent = true, buffer = buf }
  
  -- Enter: jump to file in window above
  vim.keymap.set("n", "<CR>", function()
    local cursor_line = vim.api.nvim_win_get_cursor(win)[1]
    local idx = cursor_line - offset
    
    if idx < 1 or idx > #state.results then
      return
    end
    
    local result = state.results[idx]
    
    if result and vim.fn.filereadable(result.file) == 1 then
      -- Go to previous window (the main editor window)
      vim.cmd("wincmd p")
      
      -- Open file
      vim.cmd("edit " .. vim.fn.fnameescape(result.file))
      vim.api.nvim_win_set_cursor(0, { result.lnum, result.col - 1 })
      vim.cmd("normal! zz")
      
      -- Return focus to grep window
      vim.cmd("wincmd p")
    else
      vim.notify("File not found: " .. (result.file or "unknown"), vim.log.levels.ERROR)
    end
  end, opts)
  
  -- o: open and stay in file
  vim.keymap.set("n", "o", function()
    local cursor_line = vim.api.nvim_win_get_cursor(win)[1]
    local idx = cursor_line - offset
    
    if idx < 1 or idx > #state.results then
      return
    end
    
    local result = state.results[idx]
    
    if result and vim.fn.filereadable(result.file) == 1 then
      -- Go to previous window
      vim.cmd("wincmd p")
      
      -- Open file
      vim.cmd("edit " .. vim.fn.fnameescape(result.file))
      vim.api.nvim_win_set_cursor(0, { result.lnum, result.col - 1 })
      vim.cmd("normal! zz")
    end
  end, opts)
  
  -- q or ESC: close window
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, opts)
  
  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, opts)
  
  -- j/k navigation skips header
  vim.keymap.set("n", "j", function()
    local cursor = vim.api.nvim_win_get_cursor(win)
    local total = vim.api.nvim_buf_line_count(buf)
    if cursor[1] < total then
      vim.api.nvim_win_set_cursor(win, { cursor[1] + 1, 0 })
    end
  end, opts)
  
  vim.keymap.set("n", "k", function()
    local cursor = vim.api.nvim_win_get_cursor(win)
    if cursor[1] > offset + 1 then
      vim.api.nvim_win_set_cursor(win, { cursor[1] - 1, 0 })
    end
  end, opts)
end

--------------------------------------------------------------
-- Main grep function
--------------------------------------------------------------
function M.grep(pattern)
  if not pattern or pattern == "" then
    vim.notify("Pattern required", vim.log.levels.WARN)
    return
  end

  local root_dir = find_root()

  local lines = run_grep(pattern, root_dir)
  
  if not lines or #lines == 0 then
    vim.notify("No results found for: " .. pattern, vim.log.levels.INFO)
    return
  end

  -- Parse results
  state.results = {}
  local display_lines = {}
  
  for _, line in ipairs(lines) do
    local result = parse_result(line, root_dir)
    if result then
      table.insert(state.results, result)
      table.insert(display_lines, result.display)
    end
  end

  if #state.results == 0 then
    vim.notify("No valid results", vim.log.levels.WARN)
    return
  end

  -- Create window with header
  local buf, win, offset = create_window(display_lines, root_dir)
  state.buf = buf
  state.win = win

  -- Build complete buffer content with header
  local header = string.format("Search root: %s | Results: %d", root_dir, #state.results)
  local separator = string.rep("─", vim.api.nvim_win_get_width(win))
  local all_lines = { header, separator }
  vim.list_extend(all_lines, display_lines)

  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, all_lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "grepnav"

  -- Setup keymaps
  setup_keymaps(buf, win, offset)
  
  -- Position cursor on first result (skip header)
  vim.api.nvim_win_set_cursor(win, { offset + 1, 0 })
end

--------------------------------------------------------------
-- Setup command
--------------------------------------------------------------
function M.setup(opts)
  opts = opts or {}
  
  vim.api.nvim_create_user_command("GrepNav", function(cmd_opts)
    M.grep(cmd_opts.args)
  end, {
    nargs = 1,
    desc = "Grep with navigation from project root",
  })
  
  -- Optional: Add keybinds
  if opts.mappings ~= false then
    vim.keymap.set("n", "<leader>g", function()
      local word = vim.fn.expand("<cword>")
      M.grep(word)
    end, { desc = "Grep word under cursor" })
    
    vim.keymap.set("n", "<leader>G", function()
      vim.ui.input({ prompt = "Grep pattern: " }, function(input)
        if input then
          M.grep(input)
        end
      end)
    end, { desc = "Grep with input" })
  end
end

return M
