-- init.lua - Kotlin-focused Neovim config with enhanced hover documentation
-- Designed for ergonomic "read the docs" experience

-- 📝 Installation Instructions for Kotlin Language Server:
-- 
-- Method 1: Using Mason (Automatic - Recommended)
-- Add mason.nvim plugin below and run :MasonInstall kotlin-language-server
--
-- Method 2: Manual Installation
-- 1. Download from: https://github.com/fwcd/kotlin-language-server/releases
-- 2. Extract to ~/.local/share/kotlin-language-server/
-- 3. Make executable: chmod +x ~/.local/share/kotlin-language-server/server/build/install/server/bin/kotlin-language-server
-- 4. Add to PATH or use full path in config
--
-- Method 3: Using package manager
-- - Arch: yay -S kotlin-language-server
-- - Ubuntu/Debian: Download .deb from releases
-- - macOS: brew install kotlin-language-server
--
-- Troubleshooting:
-- - Ensure Java 11+ is installed: java --version
-- - Check if server is in PATH: which kotlin-language-server
-- - Run :LspInfo to see server status
-- - Check :LspLog for detailed error messages

-- 📦 Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 🧩 Plugin Setup
require("lazy").setup({
  -- Mason - LSP installer and manager
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "kotlin_language_server", "lua_ls" },
        automatic_installation = true,
      })
    end,
  },

  -- LSP Configuration with automatic setup


{
  -- nvim-lspconfig: The core plugin for Neovim's LSP client.
  "neovim/nvim-lspconfig",
  -- Dependencies required for a robust LSP setup:
  dependencies = {
    -- mason.nvim: Manages and installs LSP servers, formatters, and linters.
    "williamboman/mason.nvim",
    -- mason-lspconfig.nvim: Bridges mason.nvim with nvim-lspconfig,
    -- enabling automatic setup of installed LSP servers.
    "williamboman/mason-lspconfig.nvim",
    -- nvim-cmp: A powerful completion plugin.
    "hrsh7th/nvim-cmp",
    -- cmp-nvim-lsp: Provides LSP capabilities for nvim-cmp,
    -- allowing completion based on LSP server suggestions.
    "hrsh7th/cmp-nvim-lsp",
  },
  -- The 'config' function runs after the plugin is loaded.
  config = function()
    -- Load necessary modules
    local lspconfig = require("lspconfig")
    local mason_lspconfig = require("mason-lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local mason = require("mason")

    -- Define common LSP capabilities.
    -- These capabilities tell the LSP server what features Neovim supports (e.g., completion, diagnostics).
    -- cmp_nvim_lsp.default_capabilities() integrates with nvim-cmp.
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- ---@param client table The LSP client object.
    -- ---@param bufnr number The buffer number the client is attached to.
    -- This 'on_attach' function is called every time an LSP server attaches to a buffer.
    -- It's the ideal place to set up buffer-local keymaps and other configurations
    -- that depend on the LSP client being active for that buffer.
    local on_attach = function(client, bufnr)
      -- Set the 'omnifunc' option for the current buffer.
      -- This allows Neovim's built-in completion (Ctrl-X Ctrl-O) to use LSP.
      vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

      -- Enable inlay hints if the attached LSP client supports them.
      -- Inlay hints show additional information directly in your code (e.g., parameter names, variable types).
      if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(bufnr, true)
      end

      -- Define buffer-local keymaps for LSP functionalities.
      -- These keymaps are only active when an LSP client is attached to the buffer.
      local buf_set_keymap = vim.api.nvim_buf_set_keymap
      local opts = { noremap = true, silent = true } -- Common options: non-recursive, silent execution

      -- Go to definition
      buf_set_keymap(bufnr, "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
      -- Go to declaration
      buf_set_keymap(bufnr, "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
      -- Go to implementation
      buf_set_keymap(bufnr, "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
      -- Go to references
      buf_set_keymap(bufnr, "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
      -- Show hover documentation
      buf_set_keymap(bufnr, "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
      -- Rename symbol
      buf_set_keymap(bufnr, "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
      -- Show code actions
      buf_set_keymap(bufnr, "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
      -- Go to previous diagnostic message
      buf_set_keymap(bufnr, "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
      -- Go to next diagnostic message
      buf_set_keymap(bufnr, "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
      -- Format buffer (async)
      buf_set_keymap(bufnr, "<leader>f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)

      -- Notify the user that the LSP server has attached.
      vim.notify("LSP attached for " .. client.name .. " on buffer " .. bufnr, vim.log.levels.INFO)
    end

    -- Configure mason.nvim itself.
    -- This is where you can customize Mason's UI and behavior.
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",     -- Icon for installed packages
          package_pending = "➜",       -- Icon for packages being installed
          package_uninstalled = "✗",   -- Icon for uninstalled packages
        },
      },
    })

    -- Configure mason-lspconfig.nvim.
    -- This tells mason-lspconfig which LSP servers to manage and how to set them up.
    mason_lspconfig.setup({
      -- 'ensure_installed' lists LSP servers that Mason should automatically install.
      -- Add all the language servers you want to use here.
      ensure_installed = {
        "kotlin_language_server",
        "lua_ls",
        -- Example: Add other servers you might need
        -- "rust_analyzer",
        -- "tsserver", -- For TypeScript/JavaScript
        -- "pyright",  -- For Python
        -- "html",
        -- "cssls",
        -- "jsonls",
      },
    })

    -- Setup handlers for mason-lspconfig.
    -- This defines how each LSP server should be configured when it's started.
    -- Added a check to prevent "attempt to call field 'setup_handlers' (a nil value)"
    -- error, which typically occurs if mason-lspconfig.nvim is not up-to-date.
    if mason_lspconfig and type(mason_lspconfig.setup_handlers) == "function" then
      mason_lspconfig.setup_handlers({
        -- Default handler for all LSP servers not explicitly listed below.
        -- It applies the common capabilities and the shared 'on_attach' function.
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            -- You can add other default settings here if needed for all servers.
          })
        end,

        -- Specific configuration for the Kotlin Language Server.
        ["kotlin_language_server"] = function()
          lspconfig.kotlin_language_server.setup({
            capabilities = capabilities,
            -- Use a custom on_attach for Kotlin to add specific notifications,
            -- but make sure to call the common 'on_attach' first to get keymaps.
            on_attach = function(client, bufnr)
              on_attach(client, bufnr) -- Call the common on_attach
              vim.notify("Kotlin LSP attached successfully", vim.log.levels.INFO)
            end,
            -- Define root patterns to help the LSP server find the project root.
            -- This is crucial for correct project-wide analysis.
            root_dir = lspconfig.util.root_pattern(
              "settings.gradle",
              "settings.gradle.kts",
              "build.gradle",
              "build.gradle.kts",
              ".git"
            ),
            -- Specific settings for the Kotlin language server.
            settings = {
              kotlin = {
                compiler = {
                  jvm = {
                    target = "17", -- Ensure the correct JVM target is set.
                  },
                },
                inlayHints = {
                  enabled = true,
                  typeHints = true,
                  parameterHints = true,
                  chainedHints = true,
                },
              },
            },
            -- 'on_init' is generally not needed unless you have logic that must run
            -- *before* the client is fully attached to a buffer. 'on_attach' is usually sufficient.
            -- on_init = function(client, initialize_result)
            --   vim.notify("Kotlin LSP initialized", vim.log.levels.INFO)
            -- end,
          })
        end,

        -- Specific configuration for the Lua Language Server (lua_ls).
        ["lua_ls"] = function()
          lspconfig.lua_ls.setup({
            capabilities = capabilities,
            on_attach = on_attach, -- Use the common on_attach for Lua LSP.
            settings = {
              Lua = {
                diagnostics = {
                  -- Add 'vim' to globals to prevent warnings about undefined 'vim' variable.
                  globals = { "vim" },
                },
                workspace = {
                  -- 'library' helps the Lua LSP find Neovim's runtime files for better completion and diagnostics.
                  library = vim.api.nvim_get_runtime_file("", true),
                  -- 'checkThirdParty = false' can prevent unnecessary warnings from external Lua files.
                  checkThirdParty = false,
                },
                telemetry = { enable = false }, -- Disable telemetry for privacy.
                completion = {
                  -- Configure how snippets are handled during completion.
                  callSnippet = "Replace", -- Options: "Replace", "Keep", "Disable"
                },
              },
            },
          })
        end,
      })
    else
      vim.notify(
        "Warning: mason-lspconfig.setup_handlers is not available. Please ensure mason-lspconfig.nvim is installed and up-to-date.",
        vim.log.levels.WARN
      )
    end
  end,
},

  -- Enhanced Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      
      cmp.setup({
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
        }),
        
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
        }),
        
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        
        formatting = {
          format = function(entry, item)
            -- Show source in completion menu
            item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              buffer = "[Buf]",
              path = "[Path]",
            })[entry.source.name]
            return item
          end,
        },
        
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })
    end,
  },

  -- Enhanced Hover Documentation
  {
    "glepnir/lspsaga.nvim",
    branch = "main",
    config = function()
      require("lspsaga").setup({
        hover = {
          max_width = 0.8,
          max_height = 0.8,
          open_link = "gx",
          open_cmd = "!open",
        },
        definition = {
          edit = "<CR>",
          vsplit = "<C-v>",
          split = "<C-x>",
          tabe = "<C-t>",
          quit = "q",
        },
        finder = {
          max_height = 0.5,
          min_width = 30,
          force_max_height = false,
          keys = {
            jump_to = "p",
            expand_or_jump = "o",
            vsplit = "s",
            split = "i",
            tabe = "t",
            tabnew = "r",
            quit = { "q", "<ESC>" },
            close_in_preview = "<ESC>",
          },
        },
        ui = {
          title = true,
          border = "rounded",
          winblend = 0,
          expand = "",
          collapse = "",
          preview = " ",
          code_action = "💡",
          diagnostic = "🐞",
          incoming = " ",
          outgoing = " ",
          hover = " ",
          kind = {},
        },
      })
    end,
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "kotlin", "lua", "vim", "vimdoc" },
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = "<C-s>",
            node_decremental = "<C-backspace>",
          },
        },
      })
    end,
  },

  -- File tree for project navigation
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = { group_empty = true },
        filters = { dotfiles = false },
      })
    end,
  },

  -- Fuzzy finder for quick navigation
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
          },
        },
      })
    end,
  },

  -- Better diagnostics display
  {
    "folke/trouble.nvim",
    config = function()
      require("trouble").setup({
        icons = false,
        fold_open = "v",
        fold_closed = ">",
        indent_lines = false,
        signs = {
          error = "E",
          warning = "W",
          hint = "H",
          information = "I"
        },
        use_diagnostic_signs = false
      })
    end,
  },

  -- Color scheme optimized for readability
  {
    "folke/tokyonight.nvim",
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
        },
        sidebars = { "qf", "help", "terminal", "packer" },
        day_brightness = 0.3,
        hide_inactive_statusline = false,
        dim_inactive = false,
        lualine_bold = false,
      })
      vim.cmd([[colorscheme tokyonight]])
    end,
  },


  -- File explorer: Oil.nvim (edit directories like buffers)
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<cmd>Oil<cr>", desc = "Open file explorer" },
      -- { "<leader>e", "<cmd>Oil --float<cr>", desc = "Open file explorer" },
    },
    config = function()
      require("oil").setup({
        columns = {
          "icon",
          "permissions",
          "size",
          "mtime",
        },
        keymaps = {
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.select",
          ["<C-s>"] = "actions.select_vsplit",
          ["<C-h>"] = "actions.select_split",
          ["<C-t>"] = "actions.select_tab",
          ["<C-p>"] = "actions.preview",
          ["<C-c>"] = "actions.close",
          ["<C-l>"] = "actions.refresh",
          ["-"] = "actions.parent",
          ["_"] = "actions.open_cwd",
          ["`"] = "actions.cd",
          ["~"] = "actions.tcd",
          ["gs"] = "actions.change_sort",
          ["gx"] = "actions.open_external",
          ["g."] = "actions.toggle_hidden",
        },
      })


    end
  },


  {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("harpoon").setup()
      -- vim.keymap.set("n", "<leader>m", '<cmd>lua require("harpoon.mark").add_file()<cr>')
      -- vim.keymap.set("n", "<leader><leader>", '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>')
      -- for i = 1, 4 do
      --   vim.keymap.set("n", "<leader>" .. i, '<cmd>lua require("harpoon.ui").nav_file(' .. i .. ')<cr>')
      -- end
    end
  },


  -- Terminal: Toggleterm with better config
  {
    "akinsho/toggleterm.nvim",
    keys = {
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal float" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal horizontal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=40<cr>", desc = "Terminal vertical" },
    },
    config = function()
      require('toggleterm').setup({
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = 'float',
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = 'curved',
          winblend = 0,
          highlights = {
            border = "Normal",
            background = "Normal",
          },
        },
      })
    end
  },


})

-- 🎯 Ergonomic Keymaps for Documentation
local keymap = vim.keymap.set


keymap('n', '<leader>e', '<cmd>Oil<cr>')

keymap("n", "<leader>m", '<cmd>lua require("harpoon.mark").add_file()<cr>')
keymap("n", "<leader><leader>", '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>')
keymap("n", '1', '<cmd>lua require("harpoon.ui").nav_file(1)<cr>')
keymap("n", '2', '<cmd>lua require("harpoon.ui").nav_file(2)<cr>')
keymap("n", '3', '<cmd>lua require("harpoon.ui").nav_file(3)<cr>')
keymap("n", '4', '<cmd>lua require("harpoon.ui").nav_file(4)<cr>')

-- Primary hover documentation (immediate access)
keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "Hover Documentation" })

-- Secondary documentation actions
keymap("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { desc = "Go to Definition" })
keymap("n", "gD", "<cmd>Lspsaga goto_type_definition<CR>", { desc = "Go to Type Definition" })
keymap("n", "gr", "<cmd>Lspsaga finder<CR>", { desc = "Find References" })
keymap("n", "gp", "<cmd>Lspsaga peek_definition<CR>", { desc = "Peek Definition" })

-- Diagnostic navigation
keymap("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { desc = "Previous Diagnostic" })
keymap("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", { desc = "Next Diagnostic" })

-- Additional diagnostic keymaps
keymap("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Toggle Diagnostics" })
keymap("n", "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", { desc = "Toggle Quickfix" })

-- LSP status and restart
keymap("n", "<leader>li", "<cmd>LspInfo<CR>", { desc = "LSP Info" })
keymap("n", "<leader>lr", "<cmd>LspRestart<CR>", { desc = "LSP Restart" })
keymap("n", "<leader>ll", "<cmd>LspLog<CR>", { desc = "LSP Log" })

-- Mason management
keymap("n", "<leader>m", "<cmd>Mason<CR>", { desc = "Mason" })

-- Code actions
keymap("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { desc = "Code Action" })
keymap("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", { desc = "Rename" })

-- File navigation
-- keymap("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Tree" })
keymap("n", "<leader>f", "<cmd>Telescope find_files<CR>", { desc = "Find Files" })
keymap("n", "<leader>g", "<cmd>Telescope live_grep<CR>", { desc = "Live Grep" })
keymap("n", "<leader>b", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })

-- Toggle inlay hints
keymap("n", "<leader>h", function()
  vim.lsp.inlay_hint.enable(0, not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle Inlay Hints" })

-- 🛠️ Editor Settings (optimized for readability)
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.breakindent = true

-- Indentation for Kotlin
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Split behavior
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Hover window stays open longer
vim.opt.updatetime = 100

-- 📋 Auto Format on Save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.kt", "*.kts" },
  callback = function()
    vim.lsp.buf.format({ async = false, timeout_ms = 2000 })
  end,
})

-- 🎨 Enhanced UI for hover documentation
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    source = "always",
  },
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Hover window styling
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = "rounded",
    max_width = 80,
    max_height = 30,
  }
)

-- 🧠 Filetype-specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "kotlin",
  callback = function()
    vim.opt_local.commentstring = "// %s"
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})
