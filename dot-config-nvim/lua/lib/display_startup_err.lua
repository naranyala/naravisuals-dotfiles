local M = {}

-- Function to display messages in a buffer
function M.display_messages()
  -- Get the messages from Neovim's message history
  local messages = vim.api.nvim_exec2("messages", { output = true }).output
  
  -- Split into lines
  local lines = vim.split(messages, "\n", { plain = true })
  
  -- Remove empty lines at the end
  while #lines > 0 and lines[#lines] == "" do
    table.remove(lines)
  end
  
  -- Check if there are any messages
  if #lines == 0 then
    vim.notify("No messages found.", vim.log.levels.INFO)
    return
  end
  
  -- Create a new scratch buffer
  local buf = vim.api.nvim_create_buf(false, true)
  
  -- Set buffer lines
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Set buffer options
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  vim.api.nvim_set_option_value("filetype", "messages", { buf = buf })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
  
  -- Set buffer name
  vim.api.nvim_buf_set_name(buf, "Messages")
  
  -- Open the buffer in a split
  vim.cmd("split")
  vim.api.nvim_set_current_buf(buf)
  
  -- Set window options
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.wrap = false
  
  -- Add keymaps for convenience
  local opts = { buffer = buf, noremap = true, silent = true }
  vim.keymap.set("n", "q", "<cmd>close<cr>", opts)
  vim.keymap.set("n", "r", function()
    M.refresh_messages(buf)
  end, opts)
end

-- Function to refresh messages in existing buffer
function M.refresh_messages(buf)
  -- Get updated messages
  local messages = vim.api.nvim_exec2("messages", { output = true }).output
  local lines = vim.split(messages, "\n", { plain = true })
  
  -- Remove empty lines at the end
  while #lines > 0 and lines[#lines] == "" do
    table.remove(lines)
  end
  
  -- Make buffer modifiable temporarily
  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
  
  -- Update buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Make buffer read-only again
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  
  vim.notify("Messages refreshed", vim.log.levels.INFO)
end

-- Create user command
vim.api.nvim_create_user_command("Messages", function()
  M.display_messages()
end, { desc = "Display Neovim messages in a buffer" })

-- Optional: Create command to clear messages
vim.api.nvim_create_user_command("MessagesClear", function()
  vim.cmd("messages clear")
  vim.notify("Messages cleared", vim.log.levels.INFO)
end, { desc = "Clear Neovim messages" })

return M
