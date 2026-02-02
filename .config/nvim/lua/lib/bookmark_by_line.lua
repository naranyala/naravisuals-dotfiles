-- ~/.config/nvim/lua/mark-project-local.lua
local M = {}

-- Structure: project_root → array of {path, line, text?}
M.bookmarks = {}

local function get_project_key()
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
	if git_root and vim.fn.isdirectory(git_root) == 1 then
		return vim.fn.fnamemodify(git_root, ":p")
	end
	return vim.fn.getcwd() .. "/"
end

local function get_bookmarks_file()
	local key = get_project_key()
	local hash = vim.fn.sha256(key)
	return vim.fn.stdpath("data") .. "/bookmarks_" .. hash:sub(1, 12) .. ".json"
end

local function load_bookmarks()
	local file = get_bookmarks_file()
	local f = io.open(file, "r")
	if not f then
		M.bookmarks = {}
		return
	end
	local content = f:read("*a")
	f:close()
	if content and content ~= "" then
		local ok, decoded = pcall(vim.json.decode, content)
		if ok and type(decoded) == "table" then
			M.bookmarks = decoded
		else
			M.bookmarks = {}
		end
	end
end

local function save_bookmarks()
	local file = get_bookmarks_file()
	local f = io.open(file, "w")
	if f then
		f:write(vim.json.encode(M.bookmarks))
		f:close()
	end
end

-- Auto load/save
vim.api.nvim_create_autocmd({ "DirChanged", "VimEnter" }, { callback = load_bookmarks })
vim.api.nvim_create_autocmd("VimLeavePre", { callback = save_bookmarks })
load_bookmarks() -- initial load

-- Helper: get line text safely
local function get_line_text(path, lnum)
	local lines = vim.fn.readfile(path, "", lnum + 10) -- read a few lines
	if lines and lines[lnum] then
		local text = lines[lnum]:gsub("^%s+", ""):gsub("\t", "  ")
		return text ~= "" and text or "(empty line)"
	end
	return "(line unavailable)"
end

local function refresh_bookmarks()
	local items = {}
	local cur_file = vim.fn.expand("%:p")
	local cur_line = vim.fn.line(".") - 1 -- 0-indexed for comparison

	for i, bm in ipairs(M.bookmarks) do
		local rel = vim.fn.fnamemodify(bm.path, ":~:.")
		local line_text = bm.text or get_line_text(bm.path, bm.line)
		local display = string.format("%s:%d │ %s", rel, bm.line + 1, line_text)

		local is_current = (bm.path == cur_file and bm.line == cur_line)
		if is_current then
			display = "● " .. display
		end

		table.insert(items, {
			value = bm,
			display = display,
			ordinal = rel .. " " .. (bm.line + 1) .. " " .. line_text,
			path = bm.path,
			line = bm.line + 1,
			index = i,
			filename = rel,
			lnum = bm.line + 1,
			col = 1,
			text = line_text,
		})
	end
	return items
end

-- Add current line as bookmark
local function add_current_line()
	local path = vim.fn.expand("%:p")
	if path == "" or path:find("^term://") then
		print("Can't bookmark this buffer")
		return
	end

	local line = vim.fn.line(".") - 1 -- 0-indexed
	local text = vim.fn.getline("."):gsub("^%s+", ""):gsub("\t", "  ")
	if text == "" then
		text = "(empty)"
	end

	-- Avoid exact duplicates
	for _, bm in ipairs(M.bookmarks) do
		if bm.path == path and bm.line == line then
			print("This line is already bookmarked")
			return
		end
	end

	table.insert(M.bookmarks, { path = path, line = line, text = text })
	save_bookmarks()
	print(string.format("Bookmarked → %s:%d (%d total)", vim.fn.fnamemodify(path, ":t"), line + 1, #M.bookmarks))
end

-- Telescope: Jump to bookmark
local function open_telescope_jump()
	if #M.bookmarks == 0 then
		print("No line bookmarks in this project")
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	pickers
		.new({}, {
			prompt_title = "Project Line Bookmarks ─ " .. vim.fn.fnamemodify(get_project_key(), ":t"),
			finder = finders.new_table({
				results = refresh_bookmarks(),
				entry_maker = function(entry)
					return entry
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local sel = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					vim.cmd.edit(vim.fn.fnameescape(sel.path))
					vim.api.nvim_win_set_cursor(0, { sel.line, 0 })
					vim.cmd("normal! zz")
				end)

				-- Delete with <C-d> or d
				map({ "i", "n" }, "<C-d>", function()
					local sel = action_state.get_selected_entry()
					if sel then
						table.remove(M.bookmarks, sel.index)
						save_bookmarks()
						action_state.get_current_picker(prompt_bufnr):refresh(
							finders.new_table({
								results = refresh_bookmarks(),
								entry_maker = function(e)
									return e
								end,
							}),
							{ reset_prompt = false }
						)
					end
				end)

				return true
			end,
		})
		:find()
end

-- Optional: dedicated remove picker
local function open_telescope_remove()
	if #M.bookmarks == 0 then
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	pickers
		.new({}, {
			prompt_title = "Remove Bookmark ─ " .. vim.fn.fnamemodify(get_project_key(), ":t"),
			finder = finders.new_table({
				results = refresh_bookmarks(),
				entry_maker = function(e)
					return e
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, _)
				local function delete()
					local sel = action_state.get_selected_entry()
					if sel then
						table.remove(M.bookmarks, sel.index)
						save_bookmarks()
						action_state.get_current_picker(prompt_bufnr):refresh(
							finders.new_table({
								results = refresh_bookmarks(),
								entry_maker = function(e)
									return e
								end,
							}),
							{ reset_prompt = true }
						)
					end
				end

				actions.select_default:replace(delete)
				actions.select_horizontal:replace(delete)
				actions.select_vertical:replace(delete)

				return true
			end,
		})
		:find()
end

-- Setup function
function M.setup()
	vim.api.nvim_create_user_command("BookmarkAdd", add_current_line, {})
	vim.api.nvim_create_user_command("BookmarkClear", function()
		M.bookmarks = {}
		save_bookmarks()
		print("All project bookmarks cleared")
	end, {})

	-- Keymaps
	vim.keymap.set("n", "<leader><leader>", open_telescope_jump, { desc = "Bookmarks: Jump to line" })
	vim.keymap.set("n", "<leader>ba", add_current_line, { desc = "Bookmarks: Add current line" })
	vim.keymap.set("n", "<leader>br", open_telescope_remove, { desc = "Bookmarks: Remove picker" })

	-- Quick jump to first 9 bookmarks
	for i = 1, 9 do
		vim.keymap.set("n", "<leader>m" .. i, function()
			if M.bookmarks[i] then
				local bm = M.bookmarks[i]
				vim.cmd.edit(vim.fn.fnameescape(bm.path))
				vim.api.nvim_win_set_cursor(0, { bm.line + 1, 0 })
				vim.cmd("normal! zz")
			else
				print("No bookmark #" .. i)
			end
		end, { desc = "Jump to bookmark " .. i })
	end
end

return M
