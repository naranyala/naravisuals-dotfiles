-- ~/.config/nvim/init.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
	-- Theme
	-- {
	--   "rose-pine/neovim",
	--   name = "rose-pine",
	--   priority = 1000,
	--   config = function()
	--     vim.cmd.colorscheme("rose-pine-moon")
	--   end
	-- },

	{
		"navarasu/onedark.nvim",
		priority = 1000, -- ensures it loads before other plugins
		lazy = false, -- load immediately
		config = function()
			require("onedark").setup({
				style = "darker", -- options: dark, darker, cool, deep, warm, warmer, light
			})
			require("onedark").load()
		end,
	},

	-- LSP Management
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls", -- Lua
					"clangd", -- C
					"bashls", -- Bash
					"kotlin_language_server", -- Kotlin
				},
			})
		end,
	},

	-- File explorer
	-- {
	--   "tamago324/lir.nvim",
	--   dependencies = { "nvim-tree/nvim-web-devicons" },
	--   config = function()
	--     require("lir").setup({
	--       show_hidden_files = true,
	--       devicons = { enable = true }
	--     })
	--   end
	-- },

	{
		"stevearc/oil.nvim",
		config = function()
			require("oil").setup({
				float = { padding = 4 },
				view_options = { show_hidden = true },
			})
		end,
	},

	{
		"ThePrimeagen/harpoon",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("harpoon").setup()
		end,
	},

	-- Fuzzy finder
	-- {
	--   "vijaymarupudi/nvim-fzf",
	--   dependencies = { "junegunn/fzf" },
	--   config = function()
	--     require("fzf").setup()
	--   end
	-- },

	-- Statusline
	{
		"beauwilliams/statusline.lua",
		config = function()
			require("statusline").setup({
				sections = {
					left = { "mode", "filename" },
					middle = { "lsp" },
					right = { "filetype", "line_col" },
				},
			})
		end,
	},

	-- LSP with different approach
	{
		"glepnir/lspsaga.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("lspsaga").setup({
				ui = { border = "rounded" },
				lightbulb = { enable = false },
			})

			local lspconfig = require("lspconfig")
			local servers = { "lua_ls", "pyright", "rust_analyzer", "clangd", "ts_ls" }
			-- local servers = { "pyright", "rust_analyzer", "clangd", "ts_ls" }

			for _, server in ipairs(servers) do
				lspconfig[server].setup({
					on_attach = function(client, bufnr)
						local opts = { buffer = bufnr }
						vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<cr>", opts)
						vim.keymap.set("n", "gr", "<cmd>Lspsaga finder<cr>", opts)
						vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<cr>", opts)
						vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<cr>", opts)
						vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<cr>", opts)
					end,
				})
			end
		end,
	},

	-- Completion
	-- {
	--   "ms-jpq/coq_nvim",
	--   branch = "coq",
	--   dependencies = {
	--     { "ms-jpq/coq.artifacts", branch = "artifacts" },
	--     { "ms-jpq/coq.thirdparty", branch = "3p" }
	--   },
	--   config = function()
	--     vim.g.coq_settings = {
	--       auto_start = "shut-up",
	--       keymap = { jump_to_mark = "<c-n>" }
	--     }
	--   end
	-- },

	-- Syntax highlighting
	-- {
	--   "sheerun/vim-polyglot",
	--   config = function()
	--     vim.g.polyglot_disabled = {}
	--   end
	-- },

	-- Project management
	{
		"ahmedkhalf/project.nvim",
		config = function()
			require("project_nvim").setup({
				detection_methods = { "lsp", "pattern" },
				patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
			})
		end,
	},

	-- Tabline
	-- {
	--   "romgrk/barbar.nvim",
	--   dependencies = { "nvim-tree/nvim-web-devicons" },
	--   config = function()
	--     require("barbar").setup({
	--       animation = false,
	--       auto_hide = false,
	--       tabpages = true
	--     })
	--   end
	-- },

	-- Terminal
	{
		"kassio/neoterm",
		config = function()
			vim.g.neoterm_default_mod = "belowright"
			vim.g.neoterm_size = 16
			vim.g.neoterm_autoscroll = 1
		end,
	},

	-- File manager
	-- {
	--   "ptzz/lf.nvim",
	--   dependencies = { "voldikss/vim-floaterm" },
	--   config = function()
	--     require("lf").setup({
	--       escape_quit = false,
	--       border = "rounded"
	--     })
	--   end
	-- },

	-- Commenting
	{
		"b3nj5m1n/kommentary",
		config = function()
			require("kommentary.config").configure_language("default", {
				prefer_single_line_comments = true,
			})
		end,
	},

	-- Surround
	{
		"machakann/vim-sandwich",
		config = function()
			vim.g.sandwich_no_default_key_mappings = 1
			vim.keymap.set("n", "sa", "<Plug>(sandwich-add)")
			vim.keymap.set("n", "sd", "<Plug>(sandwich-delete)")
			vim.keymap.set("n", "sr", "<Plug>(sandwich-replace)")
		end,
	},

	-- Git
	{
		"sindrets/diffview.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("diffview").setup({
				diff_binaries = false,
				enhanced_diff_hl = false,
			})
		end,
	},

	-- Registers
	{
		"tversteeg/registers.nvim",
		config = function()
			require("registers").setup()
		end,
	},

	-- Motion
	{
		"phaazon/hop.nvim",
		config = function()
			require("hop").setup()
		end,
	},

	-- Startscreen
	{
		"mhinz/vim-startify",
		config = function()
			vim.g.startify_lists = {
				{ type = "files", header = { "   Recent Files" } },
				{ type = "dir", header = { "   Current Directory" } },
				{ type = "sessions", header = { "   Sessions" } },
				{ type = "bookmarks", header = { "   Bookmarks" } },
			}
		end,
	},

	-- Colorscheme switcher
	{
		"zaldih/themery.nvim",
		config = function()
			require("themery").setup({
				themes = { "rose-pine", "rose-pine-moon", "rose-pine-dawn" },
			})
		end,
	},

	-- Snippets
	{
		"dcampos/nvim-snippy",
		config = function()
			require("snippy").setup({
				mappings = {
					is = {
						["<Tab>"] = "expand_or_advance",
						["<S-Tab>"] = "previous",
					},
				},
			})
		end,
	},

	-- Marks
	{
		"chentoast/marks.nvim",
		config = function()
			require("marks").setup({
				default_mappings = true,
				refresh_interval = 250,
			})
		end,
	},

	-- Windowing
	{
		"anuvyklack/windows.nvim",
		dependencies = { "anuvyklack/middleclass" },
		config = function()
			require("windows").setup({
				autowidth = { enable = true },
				ignore = { buftype = { "quickfix" } },
			})
		end,
	},

	-- Scrollbar
	{
		"petertriho/nvim-scrollbar",
		config = function()
			require("scrollbar").setup({
				show = true,
				handle = { color = "#928374" },
			})
		end,
	},

	-- Which-key: Show keybindings
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("which-key").setup({
				window = {
					border = "rounded",
					position = "bottom",
					margin = { 1, 0, 1, 0 },
					padding = { 2, 2, 2, 2 },
				},
				layout = {
					height = { min = 4, max = 25 },
					width = { min = 20, max = 50 },
					spacing = 3,
					align = "left",
				},
			})
		end,
	},
})

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250

-- Keybindings
vim.g.mapleader = " "
local map = vim.keymap.set

-- File operations
-- map('n', '<leader>e', '<cmd>edit .<cr>')
-- map('n', '<leader>lf', '<cmd>Lf<cr>')
map("n", "<leader>ff", '<cmd>lua require("fzf").files()<cr>')
map("n", "<leader>fg", '<cmd>lua require("fzf").live_grep()<cr>')
map("n", "<leader>fb", '<cmd>lua require("fzf").buffers()<cr>')

-- Project
map("n", "<leader>fp", '<cmd>lua require("fzf").projects()<cr>')

-- Motion
map("n", "<leader>j", "<cmd>HopChar1<cr>")
map("n", "<leader>k", "<cmd>HopChar2<cr>")
map("n", "<leader>l", "<cmd>HopLine<cr>")
map("n", "<leader>w", "<cmd>HopWord<cr>")

-- Git
map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>")
map("n", "<leader>gh", "<cmd>DiffviewFileHistory<cr>")
map("n", "<leader>gc", "<cmd>DiffviewClose<cr>")

-- Terminal
map("n", "<leader>tt", "<cmd>Tnew<cr>")
map("n", "<leader>tv", "<cmd>Topen<cr>")
map("n", "<leader>tc", "<cmd>Tclose<cr>")

-- Registers
map("n", '"', '<cmd>lua require("registers").show()<cr>')

-- Themes
map("n", "<leader>th", "<cmd>Themery<cr>")

-- Buffer navigation
map("n", "<S-l>", "<cmd>BufferNext<cr>")
map("n", "<S-h>", "<cmd>BufferPrevious<cr>")
map("n", "<leader>bd", "<cmd>BufferClose<cr>")

-- Windows
map("n", "<leader>ww", "<cmd>WindowsMaximize<cr>")
map("n", "<leader>w=", "<cmd>WindowsEqualize<cr>")

-- Navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Quick save and escape
map("n", "<C-s>", "<cmd>w<cr>")
map("i", "<C-s>", "<esc><cmd>w<cr>")
map("i", "jk", "<esc>")

-- Comments
map("n", "<leader>/", "<Plug>kommentary_line_default")
map("v", "<leader>/", "<Plug>kommentary_visual_default")

map("n", "<leader>e", "<cmd>Oil<cr>")

map("n", "<leader>m", '<cmd>lua require("harpoon.mark").add_file()<cr>')
map("n", "<leader><leader>", '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>')
map("n", "1", '<cmd>lua require("harpoon.ui").nav_file(1)<cr>')
map("n", "2", '<cmd>lua require("harpoon.ui").nav_file(2)<cr>')
map("n", "3", '<cmd>lua require("harpoon.ui").nav_file(3)<cr>')
map("n", "4", '<cmd>lua require("harpoon.ui").nav_file(4)<cr>')

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.spelllang = "en_us"
	end,
})
