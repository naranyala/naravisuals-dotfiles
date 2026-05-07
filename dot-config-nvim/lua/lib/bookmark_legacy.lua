-- ~/.config/nvim/lua/mark-persistent.lua
local M = {}

M.marks = {}
local marks_file = vim.fn.stdpath("data") .. "/marks.json"

-- Persistence ---------------------------------------------------------
local function load_marks()
  local f = io.open(marks_file, "r")
  if not f then return end
  local content = f:read("*a")
  f:close()
  if content and content ~= "" then
    local ok, decoded = pcall(vim.json.decode, content)
    if ok and type(decoded) == "table" then
      M.marks = decoded
    end
  end
end

local function save_marks()
  local f = io.open(marks_file, "w")
  if f then
    f:write(vim.json.encode(M.marks))
    f:close()
  end
end

vim.api.nvim_create_autocmd("VimLeavePre", { callback = save_marks })
load_marks()

-- Helpers -------------------------------------------------------------
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

-- Core actions --------------------------------------------------------
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
  print("Marked " .. #M.marks .. ": " .. vim.fn.fnamemodify(path, ":~:."))
end

-- Main picker (jump) --------------------------------------------------
local function open_telescope_jump()
  if #M.marks == 0 then
    print("No marked files")
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = "Marked Files",
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

      -- d = delete in the jump picker too (optional but handy)
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

-- Dedicated REMOVE picker ---------------------------------------------
local function open_telescope_remove()
  if #M.marks == 0 then
    print("No marks to remove")
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = "Remove Marked File",
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
          picker:refresh(finders.new_table({ results = refresh_marks(), entry_maker = function(e) return e end }), { reset_prompt = true })
        end
      end

      -- Enter or d deletes the mark
      actions.select_default:replace(delete_and_refresh)
      map({ "i", "n" }, "d", delete_and_refresh)

      -- q or Esc just closes without doing anything
      actions.close:enhance({ ["q"] = true, ["<Esc>"] = true })

      return true
    end,
  }):find()
end

-- Setup ---------------------------------------------------------------
function M.setup()
  vim.api.nvim_create_user_command("MarkAdd", add_current, {})
  vim.api.nvim_create_user_command("MarkClear", function() M.marks = {}; save_marks(); print("All marks cleared") end, {})

  -- Keymaps
  vim.keymap.set("n", "<leader><leader>", open_telescope_jump,     { desc = "Marks: Jump picker" })
  vim.keymap.set("n", "<leader>ma",       add_current,            { desc = "Marks: Add current" })
  vim.keymap.set("n", "<leader>mr",       open_telescope_remove,   { desc = "Marks: Remove picker" }) -- ← NEW

  -- Harpoon-style quick jumps
  for i = 1, 9 do
    vim.keymap.set("n", "<leader>m" .. i, function()
      if M.marks[i] then
        vim.cmd.edit(vim.fn.fnameescape(M.marks[i].path))
      end
    end, { desc = "Mark: Jump to " .. i })
  end
end

return M
