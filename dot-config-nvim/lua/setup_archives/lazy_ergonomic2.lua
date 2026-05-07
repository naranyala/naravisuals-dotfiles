-- Bootstrap lazy.nvim
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

-- ==========================
-- Default Neovim Tweaks
-- ==========================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 300
vim.opt.scrolloff = 8
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Ergonomic additions
vim.opt.undofile = true -- Persistent undo
vim.opt.swapfile = false -- Disable swap files (use git/autosave instead)
vim.opt.backup = false -- Disable backup files
vim.opt.cursorline = true -- Highlight current line
vim.opt.showmode = false -- Don't show mode (lualine shows it)
vim.opt.pumheight = 10 -- Limit completion menu height
vim.opt.completeopt = "menu,menuone,noselect" -- Better completion experience

-- vim.env.JAVA_OPTS = "-Xmx8g"

-- ==========================
-- Plugins via lazy.nvim
-- ==========================
require("lazy").setup({

	-- Enhanced LSP UI
	{ "glepnir/lspsaga.nvim", branch = "main" },

	-- Syntax & Language
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	{ "nvim-treesitter/nvim-treesitter-textobjects" }, -- Better text objects

	-- Fuzzy Finding
	{ "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" }, -- Faster fuzzy finding

	-- Git
	{ "lewis6991/gitsigns.nvim" },
	{ "tpope/vim-fugitive" }, -- Git commands

	-- File Management
	-- { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },

	-- UI & UX
	{ "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
	{ "numToStr/Comment.nvim", config = true },
	{ "folke/which-key.nvim", config = true },
	{ "catppuccin/nvim", name = "catppuccin" },

	-- Ergonomic Enhancements
	{ "windwp/nvim-autopairs" }, -- Auto-close brackets
	{ "kylechui/nvim-surround", version = "*", config = true }, -- Surround operations
	{ "folke/flash.nvim" }, -- Better navigation
	{ "stevearc/conform.nvim" }, -- Formatting

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

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local lspconfig = require("lspconfig")
			local cmp_lsp = require("cmp_nvim_lsp")

			-- Enhanced capabilities for autocompletion
			local capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				cmp_lsp.default_capabilities()
			)

			-- Common LSP keymaps
			local function setup_keymaps(bufnr)
				local opts = { buffer = bufnr, silent = true }

				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "<leader>f", function()
					vim.lsp.buf.format({ async = true })
				end, opts)
				vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
				vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
				vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
				vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
			end

			-- Common on_attach function
			local function on_attach(client, bufnr)
				setup_keymaps(bufnr)

				-- Enable inlay hints if available
				if client.server_capabilities.inlayHintProvider then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end

				-- Format on save
				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({ bufnr = bufnr })
						end,
					})
				end
			end

			-- Diagnostic configuration
			vim.diagnostic.config({
				virtual_text = {
					prefix = "●",
					source = "if_many",
				},
				float = {
					source = "always",
					border = "rounded",
				},
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			})

			-- Diagnostic signs
			local signs = {
				{ name = "DiagnosticSignError", text = "" },
				{ name = "DiagnosticSignWarn", text = "" },
				{ name = "DiagnosticSignHint", text = "" },
				{ name = "DiagnosticSignInfo", text = "" },
			}

			for _, sign in ipairs(signs) do
				vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
			end
		end,
	},

	-- Mason for LSP server management
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				ui = {
					border = "rounded",
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},

	-- Mason LSP config bridge
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				-- ensure_installed = {
				-- 	"jdtls",
				-- 	"kotlin_language_server",
				-- },
				automatic_installation = true,
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
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			-- Load snippets
			require("luasnip.loaders.from_vscode").lazy_load()

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
				formatting = {
					format = function(entry, vim_item)
						-- Kind icons
						local kind_icons = {
							Text = "",
							Method = "m",
							Function = "",
							Constructor = "",
							Field = "",
							Variable = "",
							Class = "",
							Interface = "",
							Module = "",
							Property = "",
							Unit = "",
							Value = "",
							Enum = "",
							Keyword = "",
							Snippet = "",
							Color = "",
							File = "",
							Reference = "",
							Folder = "",
							EnumMember = "",
							Constant = "",
							Struct = "",
							Event = "",
							Operator = "",
							TypeParameter = "",
						}

						vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							luasnip = "[Snippet]",
							buffer = "[Buffer]",
							path = "[Path]",
						})[entry.source.name]

						return vim_item
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
			})

			-- Command line completion
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})

			-- Search completion
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})
		end,
	},


  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    version = '*', -- Use latest stable version
    opts = {},
  },
  {
    'HiPhish/rainbow-delimiters.nvim',
    version = '*',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },

})

vim.cmd.colorscheme("catppuccin")

-- ==========================
-- Plugin Configurations
-- ==========================

-- indent-blankline.nvim: persistent indent guides with explicit configuration
require('ibl').setup({
  indent = {
    char = '┃', -- Distinct vertical bar for clarity
    tab_char = '┃',
    smart_indent_cap = true, -- Prevent over-indentation
  },
  scope = {
    enabled = true,
    show_start = false, -- Avoid cluttering buffer
    show_end = false,
    highlight = { 'Label' }, -- Use distinct highlight group
    priority = 500, -- Ensure scope highlight precedence
  },
  exclude = {
    filetypes = {
      'help',
      'dashboard',
      'NvimTree',
      'terminal',
      'alpha',
    },
    buftypes = {
      'terminal',
      'nofile',
      'quickfix',
    },
  },
})

-- rainbow-delimiters.nvim: colorful bracket highlighting
require('rainbow-delimiters.setup').setup({
  strategy = {
    [''] = require('rainbow-delimiters').strategy['global'], -- Default global strategy
    nim = require('rainbow-delimiters').strategy['local'], -- Local for Nim (smaller files)
    rust = require('rainbow-delimiters').strategy['global'], -- Global for Rust (complex scoping)
  },
  query = {
    [''] = 'rainbow-delimiters',
    nim = 'rainbow-delimiters',
    rust = 'rainbow-delimiters',
  },
  highlight = {
    'RainbowDelimiterRed',
    'RainbowDelimiterYellow',
    'RainbowDelimiterGreen',
    'RainbowDelimiterCyan',
    'RainbowDelimiterBlue',
    'RainbowDelimiterViolet',
  },
  blacklist = { 'markdown', 'json', 'txt' }, -- Explicitly exclude non-code filetypes
})

-- Treesitter-based scope detection for enhanced context
local function enable_scope_highlighting()
  vim.api.nvim_set_hl(0, 'TreesitterContext', {
    link = 'Visual', -- Link to Visual for clear scope boundary
    force = true,
  })
  require('nvim-treesitter.configs').setup({
    context_commentstring = {
      enable = true,
      enable_autocmd = false, -- Manual control for performance
    },
  })
end

-- Filetype-specific enabling for Nim and Rust
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Enable indentation and highlighting for Nim and Rust',
  pattern = { 'nim', 'rust' },
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    vim.validate({ filetype = { ft, 'string' } }) -- Defensive: ensure filetype is string
    vim.cmd('IBLEnable') -- Enable indent-blankline
    enable_scope_highlighting() -- Enable treesitter-based scope
    -- rainbow-delimiters is enabled by default via plugin setup
  end,
})

-- Filetype-specific disabling for non-Nim/Rust files
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Disable indentation and highlighting for non-Nim/Rust filetypes',
  pattern = { '*' },
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    vim.validate({ filetype = { ft, 'string' } }) -- Defensive: ensure filetype is string
    if ft ~= 'nim' and ft ~= 'rust' then
      vim.cmd('IBLDisable') -- Disable indent-blankline
      -- Treesitter context is not disabled to avoid breaking other plugins
      -- rainbow-delimiters is automatically disabled via blacklist
    end
  end,
})

-- Define explicit highlight groups for rainbow-delimiters
local function define_highlight_groups()
  local highlights = {
    RainbowDelimiterRed = { fg = '#E06C75' },
    RainbowDelimiterYellow = { fg = '#E5C07B' },
    RainbowDelimiterGreen = { fg = '#98C379' },
    RainbowDelimiterCyan = { fg = '#56B6C2' },
    RainbowDelimiterBlue = { fg = '#61AFEF' },
    RainbowDelimiterViolet = { fg = '#C678DD' },
  }
  for group, style in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, style)
  end
end

-- Initialize highlight groups on startup
vim.api.nvim_create_autocmd('VimEnter', {
  desc = 'Define rainbow delimiter highlight groups',
  callback = define_highlight_groups,
})

-- Ensure predictable buffer-local settings
vim.api.nvim_create_autocmd('BufEnter', {
  desc = 'Set consistent buffer options for Nim and Rust',
  pattern = { '*.nim', '*.rs' },
  callback = function()
    vim.bo.expandtab = true -- Use spaces for indentation
    vim.bo.tabstop = 2 -- 2 spaces for Nim and Rust
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
  end,
})

-- Treesitter
require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"kotlin",
		"java",
		"lua",
		"vim",
		"python",
		"bash",
		"markdown",
		"json",
		"yaml",
	},
	highlight = { enable = true },
	indent = { enable = true },
	textobjects = {
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			},
		},
	},
})

-- Telescope with FZF
require("telescope").setup({
	extensions = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
		},
	},
})
require("telescope").load_extension("fzf")

-- Git signs
require("gitsigns").setup()

-- File tree
-- require("nvim-tree").setup({
-- 	view = { adaptive_size = true },
-- 	filters = { dotfiles = false },
-- })

-- Status line
require("lualine").setup({
	options = { theme = "catppuccin" },
	sections = {
		lualine_c = {
			{ "filename", path = 1 }, -- Show relative path
		},
	},
})

-- Auto-pairs
require("nvim-autopairs").setup({
	check_ts = true, -- Use treesitter
})

-- Flash (better navigation)
require("flash").setup({
	modes = {
		search = { enabled = false }, -- Don't interfere with normal search
	},
})

-- Formatting
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "black" },
		-- kotlin = { "ktlint" },
		-- java = { "google-java-format" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
})

require("lspsaga").setup({
	lightbulb = { enable = false },
	finder = { default = "tyd" }, -- Show types, definitions, references
})

-- ==========================
-- Ergonomic Keymaps
-- ==========================
vim.g.mapleader = " "
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<leader>e", "<cmd>Oil<cr>")

map("n", "<leader>m", '<cmd>lua require("harpoon.mark").add_file()<cr>', { desc = "Harpoon Mark" })
map("n", "<leader><leader>", '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>', { desc = "Show Harpoon" })
map("n", "1", '<cmd>lua require("harpoon.ui").nav_file(1)<cr>', { desc = "Move #1" })
map("n", "2", '<cmd>lua require("harpoon.ui").nav_file(2)<cr>', { desc = "Move #2" })
map("n", "3", '<cmd>lua require("harpoon.ui").nav_file(3)<cr>', { desc = "Move #3" })
map("n", "4", '<cmd>lua require("harpoon.ui").nav_file(4)<cr>', { desc = "Move #4" })

-- LSP (keeping existing, well-designed mappings)
map("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { desc = "Go to definition" })
map("n", "gD", "<cmd>Lspsaga peek_definition<CR>", { desc = "Peek definition" })
map("n", "gr", "<cmd>Lspsaga finder<CR>", { desc = "LSP references/implementations" })
map("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "Hover Documentation" })
map("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { desc = "Code Action" })
map("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { desc = "Prev Diagnostic" })
map("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", { desc = "Next Diagnostic" })
map("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", { desc = "Rename Symbol" })
map("n", "<leader>o", "<cmd>Lspsaga outline<CR>", { desc = "Symbol Outline" })

-- File operations (enhanced)
-- map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })
map("n", "<leader>e", "<cmd>Oil<CR>", { desc = "Toggle File Explorer" })
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find Files" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent Files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })
map("n", "<leader>fw", "<cmd>Telescope grep_string<CR>", { desc = "Current Word" })
map("n", "<leader>fc", "<cmd>Telescope commands<CR>", { desc = "Commands" })
map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Document Symbols" })

-- Enhanced navigation
map("n", "s", '<cmd>lua require("flash").jump()<CR>', { desc = "Flash Jump" })
map("n", "S", '<cmd>lua require("flash").treesitter()<CR>', { desc = "Flash Treesitter" })

-- Window management (simplified)
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)
map("n", "<leader>v", "<C-w>v", { desc = "Split Vertical" })
map("n", "<leader>s", "<C-w>s", { desc = "Split Horizontal" })
map("n", "<leader>x", "<cmd>close<CR>", { desc = "Close Split" })

-- Buffer navigation (keep existing)
map("n", "<Tab>", ":bnext<CR>", opts)
map("n", "<S-Tab>", ":bprev<CR>", opts)
map("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete Buffer" })

-- Quick actions
map("n", "<leader>w", ":w<CR>", { desc = "Save File" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<leader>Q", ":qa!<CR>", { desc = "Quit All (Force)" })

-- Formatting
map("n", "<leader>f", '<cmd>lua require("conform").format()<CR>', { desc = "Format Document" })

-- Git operations
map("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git Status" })
map("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git Commit" })
map("n", "<leader>gp", "<cmd>Git push<CR>", { desc = "Git Push" })
map("n", "<leader>gl", "<cmd>Git log<CR>", { desc = "Git Log" })

-- Comment (keep existing)
map("n", "<leader>c", '<cmd>lua require("Comment.api").toggle.linewise.current()<CR>', { desc = "Toggle Comment" })
map(
	"v",
	"<leader>c",
	'<esc><cmd>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>',
	{ desc = "Toggle Comment (Visual)" }
)

-- Enhanced text manipulation
map("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
map("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)
map("n", "<A-j>", ":m .+1<CR>==", opts) -- Move line down in normal mode
map("n", "<A-k>", ":m .-2<CR>==", opts) -- Move line up in normal mode

-- Better indenting
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Clear search highlight
map("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear Highlight" })

-- System clipboard (explicit, keep existing)
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })

-- WhichKey
map("n", "<leader>?", "<cmd>WhichKey<CR>", { desc = "Show All Keymaps" })

-- ==========================
-- Autocommands for workflow
-- ==========================
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	desc = "Remove trailing whitespace on save",
	callback = function()
		local save_cursor = vim.fn.getpos(".")
		vim.cmd([[%s/\s\+$//e]])
		vim.fn.setpos(".", save_cursor)
	end,
})

local function restart_lsp(name)
	for _, client in pairs(vim.lsp.get_clients()) do
		if client.name == name then
			client:stop()
		end
	end
end

