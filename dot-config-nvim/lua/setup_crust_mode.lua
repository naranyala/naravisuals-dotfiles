--=============================================================================
-- Neovim Configuration for C/Rust Development
--=============================================================================
-- This is a single-file configuration for Neovim 0.9+ optimized for C and Rust development
-- Place this file at: ~/.config/nvim/init.lua

--=============================================================================
-- Basic Settings
--=============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.scrolloff = 8
vim.opt.completeopt = "menuone,noselect"

--=============================================================================
-- Plugin Management with lazy.nvim
--=============================================================================
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

--=============================================================================
-- Plugin Specifications
--=============================================================================
require("lazy").setup({

	require("./_shared_other_modules"),
	require("./_shared_mason_lsp_treesitter"),

	-- COLORSCHEME (pick one)
	{
		"rebelot/kanagawa.nvim",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("kanagawa")
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			require("treesitter-context").setup({
				enable = true,
				max_lines = 3,
			})
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("tokyonight")
		end,
	},

	--=============================================================================
	-- File Explorer
	--=============================================================================

	-- Oil.nvim (alternative to neo-tree/nvim-tree)
	{
		"stevearc/oil.nvim",
		dependencies = {
			-- "nvim-tree/nvim-web-devicons"
		},
		keys = {
			-- { "<leader><leader>", "<cmd>Oil<cr>", desc = "Open file explorer" },
			{ "<leader>e", "<cmd>Oil<cr>", desc = "Open file explorer" },
			{ "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
		},
		config = function()
			require("oil").setup({
				columns = { "icon" },
				view_options = { show_hidden = true },
				float = { padding = 10 },
				keymaps = {
					["<C-h>"] = false,
					["<C-l>"] = false,
					["<C-s>"] = "actions.select_split",
					["<C-v>"] = "actions.select_vsplit",
				},
			})
		end,
	},

	-- {
	--     'nvim-tree/nvim-tree.lua',
	--     dependencies = {
	--         -- 'nvim-tree/nvim-web-devicons'
	--     },
	--     keys = {
	--         { '<leader>e', ':NvimTreeToggle<CR>', desc = 'Toggle file explorer' },
	--     },
	--     config = function()
	--         require("nvim-tree").setup({
	--             view = {
	--                 width = 40, -- Adjusts the height of the horizontal split
	--             },
	--             renderer = {
	--                 icons = {
	--                     show = {
	--                         git = false,          -- Disables git signs
	--                         folder = false,       -- Disables folder icons
	--                         file = false,         -- Disables file icons
	--                         folder_arrow = false, -- Disables arrow icons
	--                     }
	--                 }
	--             },
	--             diagnostics = {
	--                 enable = false, -- Disables all diagnostic signs (including git)
	--             },
	--         })
	--     end,
	-- },
	--

	-- Rust specific enhancements
	{
		"mrcjkb/rustaceanvim",
		version = "^6",
		ft = { "rust" },
		config = function()
			vim.g.rustaceanvim = {
				server = {
					on_attach = function(_, bufnr)
						vim.keymap.set("n", "<leader>ca", function()
							vim.cmd.RustLsp("codeAction")
						end, { buffer = bufnr, desc = "Code Action" })
						vim.keymap.set("n", "K", function()
							vim.cmd.RustLsp({ "hover", "actions" })
						end, { buffer = bufnr, desc = "Hover Actions" })
					end,
				},
			}
		end,
	},

	-- C/C++ specific enhancements
	{
		"p00f/clangd_extensions.nvim",
		ft = { "c", "cpp" },
		config = function()
			require("clangd_extensions").setup({
				server = {
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--header-insertion=iwyu",
						"--completion-style=detailed",
						"--function-arg-placeholders",
						"--fallback-style=llvm",
					},
					init_options = {
						usePlaceholders = true,
						completeUnimported = true,
						clangdFileStatus = true,
					},
				},
			})
		end,
	},

	--=============================================================================
	-- Autocompletion
	--=============================================================================
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
				}, {
					{ name = "buffer" },
					{ name = "path" },
				}),
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			require("treesitter-context").setup({
				enable = true,
				max_lines = 3,
			})
		end,
	},

	--=============================================================================
	-- File Finding and Navigation
	--=============================================================================
	{
		"nvim-telescope/telescope.nvim",
		tag = "v0.1.9",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
		},
		config = function()
			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<C-u>"] = false,
							["<C-d>"] = false,
						},
					},
				},
			})
		end,
	},

	--=============================================================================
	-- Formatting
	--=============================================================================
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					c = { "clang-format" },
					cpp = { "clang-format" },
					rust = { "rustfmt" },
					lua = { "stylua" },
					python = { "black" },
					javascript = { "prettier" },
					typescript = { "prettier" },
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_format = "fallback",
				},
			})
		end,
	},

	--=============================================================================
	-- Debugging
	--=============================================================================

	--=============================================================================
	-- Git Integration
	--=============================================================================
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},

	{
		"naranyala/pluginsize.nvim",
		enabled = true,
	},

	--=============================================================================
	-- Comments
	--=============================================================================

	--=============================================================================
	-- Auto Pairs
	--=============================================================================
	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup()
		end,
	},
})

--=============================================================================
-- Key Mappings
--=============================================================================

-- General keymaps
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear search highlights" })
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>Q", ":q!<CR>", { desc = "Force quit" })
vim.keymap.set("n", "<leader>n", ":enew<CR>", { desc = "New file" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize windows
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize +2<CR>", { desc = "Increase window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize -2<CR>", { desc = "Decrease window width" })

-- Buffers
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

vim.keymap.set("n", "<Esc>", "<cmd>noh<CR>")
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")

-- LSP keymaps (will be set when LSP attaches)
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "<leader>f", function()
			vim.lsp.buf.format({ async = true })
		end, opts)
	end,
})

-- Rust-specific keymaps (in Rust files)
vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	callback = function()
		vim.keymap.set("n", "<leader>cr", ":RustLsp run<CR>", { buffer = true, desc = "Run Rust" })
		vim.keymap.set("n", "<leader>ct", ":RustLsp test<CR>", { buffer = true, desc = "Test Rust" })
		vim.keymap.set("n", "<leader>cc", ":RustLsp check<CR>", { buffer = true, desc = "Check Rust" })
	end,
})

-- C/C++ specific keymaps
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp" },
	callback = function()
		vim.keymap.set(
			"n",
			"<leader>ch",
			":ClangdSwitchSourceHeader<CR>",
			{ buffer = true, desc = "Switch header/source" }
		)
	end,
})

--=============================================================================
-- Auto Commands
--=============================================================================

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	pattern = { "*" },
	callback = function()
		local save_cursor = vim.fn.getpos(".")
		vim.cmd([[%s/\s\+$//e]])
		vim.fn.setpos(".", save_cursor)
	end,
})

--=============================================================================
-- Status Line Customization
--=============================================================================

-- Show LSP status in statusline
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client then
			vim.opt.statusline:append("%#LspStatus#" .. " " .. client.name .. " %#Normal#")
		end
	end,
})

-- Put this in your init.lua or single-file config
vim.g.rustaceanvim = {
	server = {
		root_dir = function(fname)
			-- climb up until we find Cargo.toml or .git
			local dir = vim.fn.fnamemodify(fname, ":p:h")
			while dir ~= "" do
				if vim.fn.filereadable(dir .. "/Cargo.toml") == 1 or vim.fn.isdirectory(dir .. "/.git") == 1 then
					return dir
				end
				local parent = vim.fn.fnamemodify(dir, ":h")
				if parent == dir then
					break
				end
				dir = parent
			end
			-- fallback: just use the file’s directory
			return vim.fn.fnamemodify(fname, ":p:h")
		end,
	},
}

vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	callback = function()
		if vim.fn.findfile("Cargo.toml", ".;") == "" then
			vim.b.rustaceanvim_enabled = false
		end
	end,
})

-- vim.cmd.colorscheme("kanagawa")
-- vim.cmd.colorscheme("onedark")
