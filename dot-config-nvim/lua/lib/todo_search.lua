-- todo_search.lua
-- TODO scanner displaying results in horizontal split buffer

local M = {}

---------------------------------------------------------------------
-- Detect project root
---------------------------------------------------------------------
local function get_root()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  return (git_root and git_root ~= "") and git_root or vim.loop.cwd()
end

---------------------------------------------------------------------
-- Open result panel buffer (horizontal split)
---------------------------------------------------------------------
local function open_results_buffer(lines, locations)
  -- Create split
  vim.cmd("botright split")
  vim.cmd("resize 12")

  local buf = vim.api.nvim_create_buf(false, true) -- scratch buffer
  vim.api.nvim_win_set_buf(0, buf)

  -- Fill content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Mark as readonly
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  -------------------------------------------------------------------
  -- Jump to file when pressing ENTER
  -------------------------------------------------------------------
 vim.keymap.set("n", "<CR>", function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local loc = locations[row]
    if loc then
      -- Open file
      vim.cmd("e " .. loc.file)
      vim.api.nvim_win_set_cursor(0, { loc.lnum, loc.col })

      -- Make this window take the full screen
      vim.cmd("only")
    end
  end, { buffer = buf, silent = true })
  -------------------------------------------------------------------
  -- Press 'q' to close the panel
  -------------------------------------------------------------------
  vim.keymap.set("n", "q", function()
    vim.cmd("close")
  end, { buffer = buf, silent = true })
end

---------------------------------------------------------------------
-- Ripgrep search
---------------------------------------------------------------------
local function run_rg_search(root, patterns)
  local args = {
    "rg",
    "--vimgrep",
    "--no-heading",
    "--hidden",
    "--glob", "!.git",
    patterns,
    root,
  }

  local collected = {}

  vim.fn.jobstart(args, {
    stdout_buffered = true,

    on_stdout = function(_, data)
      if not data then return end
      for _, line in ipairs(data) do
        if line ~= "" then table.insert(collected, line) end
      end
    end,

    on_exit = function(_, _)
      if #collected == 0 then
        vim.notify("No TODO items found.", vim.log.levels.INFO)
        return
      end

      local display = {}
      local locations = {}

      for _, line in ipairs(collected) do
        local file, lnum, col, text = line:match("^(.-):(%d+):(%d+):(.*)$")
        if file then
          table.insert(display, string.format("%s:%s:%s  %s", file, lnum, col, text))
          table.insert(locations, {
            file = file,
            lnum = tonumber(lnum),
            col  = tonumber(col),
          })
        end
      end

      if #display == 0 then
        vim.notify("Failed to parse ripgrep output.", vim.log.levels.ERROR)
        return
      end

      open_results_buffer(display, locations)
    end,
  })
end

---------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------
function M.search()
  local root = get_root()
  local patterns = [[TODO|FIXME|BUG|HACK|NOTE]]
  run_rg_search(root, patterns)
end

---------------------------------------------------------------------
-- Optional setup
---------------------------------------------------------------------
function M.setup(opts)
  opts = opts or {}
  local key = opts.key or "<leader>td"

  vim.keymap.set("n", key, function()
    M.search()
  end, {
    desc = opts.desc or "Search TODO comments",
    silent = true,
  })
end

return M

