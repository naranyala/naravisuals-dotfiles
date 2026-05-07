-- Neovim configuration for Scala and JVM development with lazy.nvim
-- Save this file in ~/.config/nvim/init.lua

-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key before plugins
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Basic Neovim settings for a better development experience
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.tabstop = 2 -- 2 spaces for tabs
vim.opt.shiftwidth = 2 -- 2 spaces for indentation
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.smartindent = true -- Smart indentation
vim.opt.termguicolors = true -- Enable true colors
vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard
vim.opt.scrolloff = 8 -- Keep 8 lines above/below cursor for context
vim.opt.sidescrolloff = 8 -- Keep 8 columns left/right for context
vim.opt.cursorline = true -- Highlight the current line

-- Initialize lazy.nvim with plugins
require("lazy").setup({
	-- Scala and Metals LSP support
	{
		"scalameta/nvim-metals",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local metals_config = require("metals").bare_config()
			metals_config.settings = {
				showImplicitArguments = true,
				excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
			}
			metals_config.init_options.statusBarProvider = "show-message"
			metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Autocmd to initialize Metals for Scala files
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "scala", "sbt", "java" },
				callback = function()
					require("metals").initialize_or_attach(metals_config)
				end,
			})
		end,
	},

	-- General LSP support for other JVM languages (e.g., Java)
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			lspconfig.java_language_server.setup({
				cmd = { "java-language-server" }, -- Assumes java-language-server is installed
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})
		end,
	},

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local cmp = require("cmp")
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				},
			})
		end,
	},

	-- Autopairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup()
		end,
	},

	-- Syntax highlighting with Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "scala", "java", "lua", "vim", "vimdoc" },
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},

	-- Fuzzy finder
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup({
				defaults = {
					layout_config = { prompt_position = "top", preview_width = 0.6 },
					sorting_strategy = "ascending",
				},
			})
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files)
			vim.keymap.set("n", "<leader>fg", builtin.live_grep)
			vim.keymap.set("n", "<leader>fb", builtin.buffers)
			vim.keymap.set("n", "<leader>fh", builtin.help_tags)
		end,
	},

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local function file_stats()
				local buf = vim.api.nvim_get_current_buf()
				if vim.api.nvim_buf_get_option(buf, "buftype") ~= "" then
					return "" -- Skip for non-file buffers
				end

				-- Line count
				local lines = vim.api.nvim_buf_line_count(buf)

				-- Word count
				local words = 0
				local content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
				for _, line in ipairs(content) do
					for _ in line:gmatch("%S+") do
						words = words + 1
					end
				end

				-- Character count
				local chars = #table.concat(content, "")

				return string.format("lines %d | words %d | chars %d", lines, words, chars)
			end

			require("lualine").setup({
				options = {
					theme = "auto",
					component_separators = "",
					section_separators = "",
					disabled_filetypes = {},
					globalstatus = true,
				},
				sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = {
						{
							"filename",
							path = 2, -- 2 = absolute path
							symbols = {
								modified = "[+]",
								readonly = "[-]",
								unnamed = "[No Name]",
							},
						},
					},
					lualine_x = {},
					lualine_y = {},
					lualine_z = {
						{ file_stats },
					},
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = {
						{
							"filename",
							path = 2, -- Absolute path for inactive buffers too
						},
					},
					lualine_x = {},
					lualine_y = {},
					lualine_z = {},
				},
				extensions = {},
			})
		end,
	},

	-- File explorer with oil.nvim
	{
		"stevearc/oil.nvim",
		config = function()
			require("oil").setup({
				default_file_explorer = true,
				view_options = { show_hidden = true },
			})
			vim.keymap.set("n", "<leader>e", ":Oil<CR>", { desc = "Open Oil File Explorer" })
		end,
	},

	-- Quick file navigation with Harpoon
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup({})
			vim.keymap.set("n", "<leader>ha", function()
				harpoon:list():add()
			end, { desc = "Add File to Harpoon" })
			vim.keymap.set("n", "<leader>hm", function()
				harpoon.ui:toggle_quick_menu()
			end, { desc = "Harpoon Menu" })
			vim.keymap.set("n", "<leader>1", function()
				harpoon:list():select(1)
			end, { desc = "Harpoon File 1" })
			vim.keymap.set("n", "<leader>2", function()
				harpoon:list():select(2)
			end, { desc = "Harpoon File 2" })
			vim.keymap.set("n", "<leader>3", function()
				harpoon:list():select(3)
			end, { desc = "Harpoon File 3" })
			vim.keymap.set("n", "<leader>4", function()
				harpoon:list():select(4)
			end, { desc = "Harpoon File 4" })
		end,
	},

	-- Git integration with Fugitive
	{
		"tpope/vim-fugitive",
		config = function()
			vim.keymap.set("n", "<leader>gs", ":Git<CR>", { desc = "Git Status" })
			vim.keymap.set("n", "<leader>gc", ":Git commit<CR>", { desc = "Git Commit" })
			vim.keymap.set("n", "<leader>gp", ":Git push<CR>", { desc = "Git Push" })
		end,
	},

	-- Code commenting
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
			vim.keymap.set(
				"n",
				"<leader>/",
				"<cmd>lua require('Comment.api').toggle.linewise.current()<CR>",
				{ desc = "Toggle Comment" }
			)
			vim.keymap.set(
				"v",
				"<leader>/",
				"<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
				{ desc = "Toggle Comment (Visual)" }
			)
		end,
	},

	-- Diagnostics viewer with Trouble
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("trouble").setup({})
			vim.keymap.set("n", "<leader>xx", ":TroubleToggle<CR>", { desc = "Toggle Trouble" })
			vim.keymap.set("n", "<leader>xd", ":Trouble diagnostics<CR>", { desc = "Diagnostics" })
		end,
	},

	-- Colorscheme
	{
		"folke/tokyonight.nvim",
		config = function()
			vim.cmd([[colorscheme tokyonight]])
		end,
	},
}, {
	performance = {
		rtp = {
			disabled_plugins = { "netrwPlugin" }, -- Disable default file explorer
		},
	},
})

-- Keymaps for LSP and Metals
vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { desc = "Find References" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })

-- Diagnostics
vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	update_in_insert = false,
})

-- Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.scala", "*.java" },
	callback = function()
		vim.lsp.buf.format()
	end,
})

-- Ergonomic movement tweaks and keymaps
-- Better wrapped line navigation
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Center cursor on searches and jumps
vim.keymap.set("n", "n", "nzzzv", { desc = "Next Search Result (Centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous Search Result (Centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down (Centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up (Centered)" })

-- Easier line beginning/end
vim.keymap.set({ "n", "v" }, "H", "^", { desc = "Go to Beginning of Line" })
vim.keymap.set({ "n", "v" }, "L", "$", { desc = "Go to End of Line" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to Left Window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to Bottom Window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to Top Window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to Right Window" })

-- Better escape in insert mode
vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape Insert Mode" })

-- Autocommands for ergonomics
-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Auto-resize windows on Vim resize
vim.api.nvim_create_autocmd("VimResized", {
	desc = "Resize windows equally on Vim resize",
	callback = function()
		vim.cmd("wincmd =")
	end,
})

-- Disable auto-comment on new line
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
})
