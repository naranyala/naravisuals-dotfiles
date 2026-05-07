local function show_clipboard_history()
  local history_file = os.getenv("HOME") .. "/.cache/c_clipboard_history"
  local f = io.open(history_file, "r")
  if not f then return end
  local lines = {}
  for line in f:lines() do table.insert(lines, line) end
  f:close()

  require('telescope.pickers').new({}, {
    prompt_title = "Clipboard History",
    finder = require('telescope.finders').new_table { results = lines },
    sorter = require('telescope.sorters').generic_sorter(),
    attach_mappings = function(prompt_bufnr, map)
      local action_state = require 'telescope.actions.state'
      local actions = require 'telescope.actions'
      map('i', '<CR>', function()
        local selection = action_state.get_selected_entry()
        vim.fn.setreg('*', selection[1])
        vim.fn.setreg('+', selection[1])
        actions.close(prompt_bufnr)
      end)
      return true
    end
  }):find()
end

vim.keymap.set('n', '<leader>ch', show_clipboard_history, { desc = "Clipboard History" })
