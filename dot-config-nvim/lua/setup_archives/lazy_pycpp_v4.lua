--[[
  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
  
  BEHOLD! The most unhinged Neovim config this side of the Mississippi.
  You wanted chaos? You got it. But like, productive chaos.
--]]

-- First, let's summon lazy.nvim from the void
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- because unstable is for losers who like segfaults
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Configure the demon core (a.k.a. Neovim options)
vim.g.mapleader = " " -- The space bar is now your god
vim.g.maplocalleader = "\\" -- The rebellious younger sibling

-- Options that make Vim purists cry themselves to sleep
vim.opt.number = true -- Numbers are cool
vim.opt.relativenumber = true -- Numbers that move are cooler
vim.opt.mouse = "a" -- Mouse support for weaklings
vim.opt.ignorecase = true -- Case insensitive search because we're not cavemen
vim.opt.smartcase = true -- But sometimes we want to be cavemen
vim.opt.hlsearch = false -- Highlight search? More like highlight trash
vim.opt.wrap = false -- Wrapping is for presents, not code
vim.opt.breakindent = true -- Indent even when breaking lines because we're fancy
vim.opt.tabstop = 4 -- Tabs are 4 spaces because Python said so
vim.opt.shiftwidth = 4 -- Shifting is also 4 spaces
vim.opt.expandtab = true -- Spaces are better than tabs (fight me)
vim.opt.signcolumn = "yes" -- Always show sign column to avoid layout shift
vim.opt.termguicolors = true -- Colors that make your eyes bleed (in a good way)
vim.opt.scrolloff = 8 -- Keep 8 lines above/below cursor because we're clingy
vim.opt.updatetime = 50 -- Faster updates for snappier experience
vim.opt.clipboard = "unnamedplus" -- System clipboard integration for normies
vim.opt.splitright = true -- New splits go to the right like a sane person
vim.opt.splitbelow = true -- New splits go below like a slightly less sane person
vim.opt.inccommand = "split" -- Show substitution effects in real-time like magic
vim.opt.cursorline = true -- Highlight current line because we're self-centered
vim.opt.colorcolumn = "80,120" -- Vertical lines to remind you of your failures

-- Keymaps that would make Vim purists faint
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Movement that doesn't make you want to die
keymap("n", "<C-d>", "<C-d>zz", opts) -- Center after half-page jump
keymap("n", "<C-u>", "<C-u>zz", opts) -- Center after half-page jump up
keymap("n", "n", "nzzzv", opts) -- Center search results
keymap("n", "N", "Nzzzv", opts) -- Center search results (reverse)

-- Quality of life improvements for the weak-willed
keymap("n", "<leader>y", '"+y', opts) -- Yank to system clipboard
keymap("v", "<leader>y", '"+y', opts) -- Yank to system clipboard (visual)
keymap("n", "<leader>Y", '"+Y', opts) -- Yank line to system clipboard
keymap("n", "<leader>d", '"_d', opts) -- Delete without yanking
keymap("v", "<leader>d", '"_d', opts) -- Delete without yanking (visual)
keymap("n", "Q", "<nop>", opts) -- Disable Ex mode because nobody uses that
keymap("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", opts) -- Magic tmux integration

-- Window management for the spatially challenged
keymap("n", "<leader>sv", "<C-w>v", opts) -- Split vertically
keymap("n", "<leader>sh", "<C-w>s", opts) -- Split horizontally
keymap("n", "<leader>se", "<C-w>=", opts) -- Make splits equal size
keymap("n", "<leader>sx", ":close<CR>", opts) -- Close current split

-- Tab management for tab hoarders
keymap("n", "<leader>to", ":tabnew<CR>", opts) -- Open new tab
keymap("n", "<leader>tx", ":tabclose<CR>", opts) -- Close current tab
keymap("n", "<leader>tn", ":tabn<CR>", opts) -- Next tab
keymap("n", "<leader>tp", ":tabp<CR>", opts) -- Previous tab

-- Plugin management with lazy.nvim (the sane part of this config)
require("lazy").setup({
  -- Colorscheme that hurts your eyes less
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha") -- Because we're edgy
    end,
  },

  -- File tree for people who can't remember where they put their stuff
  -- {
  --   "nvim-tree/nvim-tree.lua",
  --   dependencies = { "nvim-tree/nvim-web-devicons" },
  --   config = function()
  --     require("nvim-tree").setup({
  --       view = {
  --         width = 35, -- Because we're not animals
  --       },
  --       renderer = {
  --         group_empty = true, -- Group empty folders because we're organized
  --       },
  --       filters = {
  --         dotfiles = true, -- Hide dotfiles like a coward
  --       },
  --     })
  --     keymap("n", "<leader>e", ":NvimTreeToggle<CR>", opts) -- Toggle file tree
  --   end,
  -- },

  -- Statusline that shows too much information
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin", -- Match our colorscheme because we're not monsters
          component_separators = { left = "", right = "" }, -- Fancy separators
          section_separators = { left = "", right = "" }, -- Even fancier separators
        },
      })
    end,
  },

  -- Fuzzy finder for when you can't remember what you named your files
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<C-u>"] = false, -- Disable clear prompt because who uses that?
              ["<C-d>"] = require("telescope.actions").delete_buffer, -- Delete buffer from results
            },
          },
        },
      })
      telescope.load_extension("fzf")

      -- Telescope keymaps for maximum file-finding power
      keymap("n", "<leader>ff", ":Telescope find_files<CR>", opts)
      keymap("n", "<leader>fg", ":Telescope live_grep<CR>", opts)
      keymap("n", "<leader>fb", ":Telescope buffers<CR>", opts)
      keymap("n", "<leader>fh", ":Telescope help_tags<CR>", opts)
    end,
  },

  -- Treesitter: because parsing text is hard
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "cpp", "python", "lua", "vim", "vimdoc", "query", "bash", "markdown", "json" },
        highlight = { enable = true }, -- Syntax highlighting that doesn't suck
        indent = { enable = true }, -- Indentation that (mostly) works
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<c-space>",
            node_incremental = "<c-space>",
            scope_incremental = "<c-s>",
            node_decremental = "<M-space>",
          },
        },
      })
    end,
  },

  -- LSP: Because we're too lazy to read compiler errors
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      -- Mason: The package manager that should have been built-in
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "pyright", 
                    -- "lua_ls" 
                }, -- LSPs we need
      })

      -- LSP config that makes your code less terrible
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Python LSP (because Python is weird)
      lspconfig.pyright.setup({
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic", -- Because we're not masochists
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      -- C++ LSP (because C++ is weirder)
      lspconfig.clangd.setup({
        capabilities = capabilities,
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=never",
          "--all-scopes-completion",
          "--completion-style=detailed",
          "--function-arg-placeholders",
        },
      })

      -- Lua LSP (because this config is in Lua)
      -- lspconfig.lua_ls.setup({
      --   capabilities = capabilities,
      --   settings = {
      --     Lua = {
      --       runtime = { version = "LuaJIT" },
      --       diagnostics = { globals = { "vim" } },
      --       workspace = { library = vim.api.nvim_get_runtime_file("", true) },
      --       telemetry = { enable = false }, -- Because we're not narcs
      --     },
      --   },
      -- })

      -- Autocompletion that doesn't make you want to stab yourself
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
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
        }),
      })

      -- Diagnostic keymaps for when your code is trash
      keymap("n", "<leader>do", vim.diagnostic.open_float, opts)
      keymap("n", "<leader>dp", vim.diagnostic.goto_prev, opts)
      keymap("n", "<leader>dn", vim.diagnostic.goto_next, opts)
      keymap("n", "<leader>dl", vim.diagnostic.setloclist, opts)

      -- LSP keymaps for when you want to pretend you understand your code
      local on_attach = function(client, bufnr)
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        keymap("n", "gD", vim.lsp.buf.declaration, bufopts)
        keymap("n", "gd", vim.lsp.buf.definition, bufopts)
        keymap("n", "K", vim.lsp.buf.hover, bufopts)
        keymap("n", "gi", vim.lsp.buf.implementation, bufopts)
        keymap("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
        keymap("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
        keymap("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
        keymap("n", "<leader>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts)
        keymap("n", "<leader>D", vim.lsp.buf.type_definition, bufopts)
        keymap("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
        keymap("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
        keymap("n", "gr", vim.lsp.buf.references, bufopts)
        keymap("n", "<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end, bufopts)
      end

      -- Attach our LSP keymaps to all LSP servers
      local default_on_attach = function(client, bufnr)
        on_attach(client, bufnr)
      end

      -- Set up our LSP servers with our keymaps
      local servers = { "pyright", "clangd", 
                -- "lua_ls" 
            }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
          on_attach = default_on_attach,
          capabilities = capabilities,
        })
      end
    end,
  },


  -- Autopairs: because we can't be trusted to close our own brackets
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- Commenting: for when you want to explain your terrible code
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- Git integration for when you need to blame someone else
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
      keymap("n", "<leader>gb", ":Gitsigns blame_line<CR>", opts) -- Blame someone else
      keymap("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", opts) -- Preview changes
    end,
  },

  -- Terminal because sometimes you need to pretend you're a hacker
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20, -- Because we're not savages
        open_mapping = [[<c-\>]], -- Toggle terminal
        direction = "float", -- Float because we're fancy
      })
    end,
  },

  -- Indent guides for when you can't tell where your code blocks end
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("ibl").setup()
    end,
  },

-- {
--   "dmtrKovalenko/fff.nvim",
--   build = "cargo build --release",
--   -- or if you are using nixos
--   -- build = "nix run .#release",
--   opts = {
--     -- pass here all the options
--   },
--   keys = {
--     {
--       "e", -- try it if you didn't it is a banger keybinding for a picker
--       function()
--         require("fff").find_files() -- or find_in_git_root() if you only want git files
--       end,
--       desc = "Open file picker",
--     },
--   },
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

  -- Which-key: for when you can't remember your own keybinds
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup()
    end,
  },
}, {
  checker = {
    enabled = true, -- Automatically check for updates
    notify = false, -- Don't spam me about updates
  },
  change_detection = {
    notify = false, -- Don't spam me about config changes
  },
})


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

-- Custom functions because we're special snowflakes
vim.api.nvim_create_user_command("Format", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format current buffer with LSP" })

-- Final message because we're dramatic
print("Neovim config loaded. Brace for impact.")
