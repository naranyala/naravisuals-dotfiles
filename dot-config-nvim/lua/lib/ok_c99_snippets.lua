-- ~/.config/nvim/lua/c99-snippets-picker.lua
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")

local function insert_c99_snippet()
  -- Change this to wherever you store your golden .c/.h snippets
  -- local snippets_dir = vim.fn.stdpath("config") .. "/snippets_c99"
  -- local snippets_dir = "/run/media/naranyala/Data/projects-remote/naravisuals-web/src/views/reusables"
  local snippets_dir = "/run/media/naranyala/Data/projects-remote/my-c-exploration/reusables"
  
  -- Collect both .c and .h files
  local c_files = vim.fn.glob(snippets_dir .. "/*.c", false, true)
  local h_files = vim.fn.glob(snippets_dir .. "/*.h", false, true)
  
  -- Combine both lists
  local files = {}
  for _, file in ipairs(c_files) do
    table.insert(files, file)
  end
  for _, file in ipairs(h_files) do
    table.insert(files, file)
  end
  
  if #files == 0 then
    print("No .c or .h snippets found in " .. snippets_dir)
    return
  end
  
  pickers
    .new({}, {
      prompt_title = "🚀 Insert C99 Snippet",
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
          for line in file:lines() do 
            table.insert(lines, line) 
          end
          file:close()
          
          local row, col = unpack(vim.api.nvim_win_get_cursor(0))
          vim.api.nvim_buf_set_lines(0, row, row, false, lines)
          
          -- Magic: proper re-indent using Neovim's built-in =
          vim.cmd(string.format("%d,%dnormal! ===", row + 1, row + #lines))
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
vim.keymap.set("n", "<leader>ic", insert_c99_snippet, { desc = "[I]nsert [C-programming] snippet → Telescope picker" })
