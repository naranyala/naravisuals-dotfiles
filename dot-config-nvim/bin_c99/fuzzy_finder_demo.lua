-- Lua side: fuzzy_plugin.lua

local M = {}

-- Function to run the C utility
function M.start_fuzzy_search(query, list_of_items)
  local list_str = table.concat(list_of_items, '\n') .. '\n'

  -- Use vim.loop.spawn for asynchronous I/O with the C binary
  local job = vim.loop.spawn(
    "path/to/fuzzy_finder", -- Path to your compiled C binary
    {
      args = { query },
      stdio = {
        { fd = 0, type = 'pipe' }, -- stdin pipe (for list_str)
        { fd = 1, type = 'pipe' }, -- stdout pipe (for results)
        { fd = 2, type = 'pipe' }, -- stderr pipe (for errors)
      },
    },
    vim.schedule_wrap(function(status)
      if status ~= 0 then
        -- Handle C utility error
        print("Fuzzy finder failed with status: " .. status)
        return
      end
    end)
  )

  local results_data = {}

  -- Write the list of items to the utility's stdin
  job:write(list_str)
  job:close_stdin()

  -- Read the ranked results from the utility's stdout
  job:read_start(vim.schedule_wrap(function(err, chunk)
    if err then
      print("Error reading from fuzzy finder:", err)
      return
    end

    if chunk then
      -- Append the chunk of results
      table.insert(results_data, chunk)
    else
      -- chunk is nil: The job finished reading
      local final_results = table.concat(results_data):split('\n')
      -- Now use final_results to populate a Neovim UI (e.g., a float window)
      print("Fuzzy results received:", #final_results)
      -- M.update_ui(final_results)
    end
  end))
end

-- Example usage:
-- M.start_fuzzy_search("main", { "main.c", "util.c", "documentation.md", "README.md" })
