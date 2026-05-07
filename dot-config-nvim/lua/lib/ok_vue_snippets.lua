-- ~/.config/nvim/lua/vue-snippets-picker.lua  (or anywhere you like)

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")
local previewers = require("telescope.previewers")


local function insert_vue_snippet()
  -- Change this to wherever you store your golden .vue snippets
  -- local snippets_dir = vim.fn.stdpath("config") .. "/snippets_vue"
  -- local snippets_dir = "/run/media/naranyala/Data/projects-remote/naravisuals-web/src/views/reusables"
  local snippets_dir = "/run/media/naranyala/Data/projects-remote/naravisuals-web/src/views/snippets/"


  -- Alternative: project-local → vim.fn.getcwd() .. "/.snippets/vue"

  local files = vim.fn.glob(snippets_dir .. "/*.vue", false, true)
  if #files == 0 then
    print("No .vue snippets found in " .. snippets_dir)
    return
  end

  -- Extract just the filename without extension for clean display
  local displayer = entry_display.create({
    separator = " │ ",
    items = {
      { width = 40 },
      { remaining = true },
    },
  })

  local make_display = function(entry)
    return displayer({
      { entry.filename, "TelescopeResultsIdentifier" },
      entry.path:gsub(snippets_dir .. "/", ""):gsub("%.vue$", ""),
    })
  end

  pickers
    .new({}, {
      prompt_title = "🚀 Insert Vue Snippet",
      finder = finders.new_table({
        results = files,
        entry_maker = function(path)
          local filename = vim.fn.fnamemodify(path, ":t")  -- Just filename with extension
          return {
            value = path,
            display = filename,
            ordinal = filename,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),

    previewer = previewers.new_buffer_previewer({
        title = "Snippet Preview",
        define_preview = function(self, entry, status)
          -- Read and display the file content
          conf.buffer_previewer_maker(entry.path, self.state.bufnr, {
            bufname = self.state.bufname,
            winid = self.state.winid,
          })
        end,
      }),
      attach_mappings = function(prompt_bufnr, map)
local insert_selected = function()
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)

  local path = selection.value
  local file = io.open(path, "r")
  if not file then
    print("Failed to open: " .. path)
    return
  end

  local lines = {}
  for line in file:lines() do table.insert(lines, line) end
  file:close()

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_lines(0, row, row, false, lines)

  -- Magic: proper re-indent using Neovim's built-in =
  vim.cmd(string.format("%d,%dnormal! ===", row + 1, row + #lines))

  -- Optional: move cursor inside <template> or <script setup> automatically?
  -- vim.api.nvim_win_set_cursor(0, { row + 8, 0 })  -- example
end

        map("i", "<CR>", insert_selected)
        map("n", "<CR>", insert_selected)
        map("i", "<C-y>", insert_selected) -- bonus shortcut

        return true
      end,
    })
    :find()
end

-- Your nuclear hotkey
vim.keymap.set("n", "<leader>iv", insert_vue_snippet, { desc = "[I]nsert [V]ue snippet → Telescope picker" })
