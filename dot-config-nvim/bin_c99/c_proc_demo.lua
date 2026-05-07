local function show_processes(name)
  name = name or "nvim"
  local output = vim.fn.system({"c_proc", name})
  if vim.v.shell_error ~= 0 then return end

  local entries = {}
  for line in output:gmatch("[^\r\n]+") do
    local ok, p = pcall(vim.fn.json_decode, line)
    if ok and p then
      table.insert(entries, {
        value = string.format("[%d] %.1f%% CPU, %d MB — %s",
          p.pid, p.cpu, p.mem_kb / 1024, p.cmd),
        pid = p.pid
      })
    end
  end

  require('telescope.pickers').new({}, {
    prompt_title = "Processes: " .. name,
    finder = require('telescope.finders').new_table { results = entries },
    sorter = require('telescope.sorters').generic_sorter(),
    attach_mappings = function(_, map)
      map('i', '<C-k>', function(prompt_bufnr)
        local action_state = require 'telescope.actions.state'
        local selection = action_state.get_selected_entry()
        if selection then
          os.execute("kill " .. selection.pid)
          print("Killed PID " .. selection.pid)
          -- Refresh?
        end
      end)
      return true
    end
  }):find()
end

vim.keymap.set('n', '<leader>pp', function()
  vim.ui.input({ prompt = "Process name: " }, show_processes)
end, { desc = "Show Processes" })
