-- ~/.config/nvim/lua/mark-project-local.lua
local M = {}

M.marks = {} -- now per-project: project_root → {marks table}

local function get_project_key()
  -- Method 1: Git root (best for real projects)
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
  if git_root and vim.fn.isdirectory(git_root) == 1 then
    return vim.fn.fnamemodify(git_root, ":p")
  end

  -- Method 2: fallback to current working directory
  return vim.fn.getcwd() .. "/"
end

local function get_marks_file()
  local key = get_project_key()
  local hash = vim.fn.sha256(key) -- short unique hash per project
  return vim.fn.stdpath("data") .. "/marks_" .. hash:sub(1, 12) .. ".json"
end

-- Load marks for current project
local function load_marks()
  local file = get_marks_file()
  local f = io.open(file, "r")
  if not f then
    M.marks = {}
    return
  end
  local content = f:read("*a")
  f:close()
  if content and content ~= "" then
    local ok, decoded = pcall(vim.json.decode, content)
    if ok and type(decoded) == "table" then
      M.marks = decoded
    else
      M.marks = {}
    end
  end
end

-- Save marks for current project
local function save_marks()
  local file = get_marks_file()
  local f = io.open(file, "w")
  if f then
    f:write(vim.json.encode(M.marks))
    f:close()
  end
end

-- Auto-load when entering a project, auto-save on leave
vim.api.nvim_create_autocmd({ "DirChanged", "VimEnter" }, {
  callback = function()
    load_marks()
  end,
})

vim.api.nvim_create_autocmd("VimLeavePre", { callback = save_marks })

-- Initial load
load_marks()

-- Rest of the logic (same as before, just uses M.marks directly)
local function refresh_marks()
  local items = {}
  local current_path = vim.fn.expand("%:p")

  for i, mark in ipairs(M.marks) do
    local display = string.format("%d  %s", i, vim.fn.fnamemodify(mark.path, ":~:."))
    if mark.path == current_path then
      display = "● " .. display
    end
    table.insert(items, {
      value   = mark.path,
      display = display,
      ordinal = display,
      path    = mark.path,
      index   = i,
    })
  end
  return items
end

local function add_current()
  local path = vim.fn.expand("%:p")
  if path == "" or path:find("^term://") then
    print("Can't mark this buffer")
    return
  end
  for _, m in ipairs(M.marks) do
    if m.path == path then
      print("Already marked")
      return
    end
  end
  table.insert(M.marks, { path = path })
  save_marks()
  print("Marked " .. #M.marks .. " in " .. vim.fn.fnamemodify(get_project_key(), ":t"))
end

-- Jump picker
local function open_telescope_jump()
  if #M.marks == 0 then
    print("No marked files in this project")
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = "Marked Files ─ " .. vim.fn.fnamemodify(get_project_key(), ":t"),
    finder = finders.new_table({
      results = refresh_marks(),
      entry_maker = function(e) return e end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local sel = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.cmd.edit(vim.fn.fnameescape(sel.path))
      end)

      map({ "i", "n" }, "d", function()
        local sel = action_state.get_selected_entry()
        if sel then
          table.remove(M.marks, sel.index)
          save_marks()
          action_state.get_current_picker(prompt_bufnr):refresh(
            finders.new_table({ results = refresh_marks(), entry_maker = function(e) return e end })
          )
        end
      end)

      return true
    end,
  }):find()
end

-- Remove picker
local function open_telescope_remove()
  if #M.marks == 0 then
    print("No marks to remove in this project")
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = "Remove Mark ─ " .. vim.fn.fnamemodify(get_project_key(), ":t"),
    finder = finders.new_table({
      results = refresh_marks(),
      entry_maker = function(e) return e end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      local function delete_and_refresh()
        local sel = action_state.get_selected_entry()
        if sel then
          table.remove(M.marks, sel.index)
          save_marks()
          local picker = action_state.get_current_picker(prompt_bufnr)
          picker:refresh(finders.new_table({ results = refresh_marks(), entry_maker = function(e) return e end }),
            { reset_prompt = true })
        end
      end

      actions.select_default:replace(delete_and_refresh)
      map({ "i", "n" }, "d", delete_and_refresh)

      return true
    end,
  }):find()
end

function M.setup()
  vim.api.nvim_create_user_command("MarkAdd", add_current, {})
  vim.api.nvim_create_user_command("MarkClear", function()
    M.marks = {}
    save_marks()
    print("Project marks cleared")
  end, {})

  vim.keymap.set("n", "<leader><leader>", open_telescope_jump, { desc = "Marks: Project jump" })
  vim.keymap.set("n", "<leader>ma", add_current, { desc = "Marks: Add current" })
  vim.keymap.set("n", "<leader>mr", open_telescope_remove, { desc = "Marks: Remove picker" })

  for i = 1, 9 do
    vim.keymap.set("n", "<leader>m" .. i, function()
      if M.marks[i] then
        vim.cmd.edit(vim.fn.fnameescape(M.marks[i].path))
      end
    end, { desc = "Project Mark: " .. i })
  end
end

return M
