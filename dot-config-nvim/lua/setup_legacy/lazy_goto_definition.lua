-- ~/.config/nvim/init.lua
-- Minimalist, cutting-edge Neovim configuration with lazy.nvim

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)



-- Core settings - minimal but essential
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Modern Neovim options
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes:1"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.linebreak = true
opt.breakindent = true
opt.showmode = false
opt.conceallevel = 2
opt.concealcursor = 'nc'

-- Search and replace
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.inccommand = "split"

-- Indentation
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

-- File handling
opt.undofile = true
opt.swapfile = false
opt.backup = false

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300
opt.redrawtime = 10000
opt.lazyredraw = true

-- Modern terminal features
opt.termguicolors = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"

-- Plugin specifications
require("lazy").setup({
    -- Colorscheme - Tokyo Night with modern variants
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                style = "night", -- night, storm, day, moon
                transparent = false,
                terminal_colors = true,
                styles = {
                    comments = { italic = true },
                    keywords = { italic = true },
                    functions = {},
                    variables = {},
                },
                on_highlights = function(hl, c)
                    hl.CursorLineNr = { fg = c.orange, bold = true }
                end,
            })
            vim.cmd("colorscheme tokyonight")
        end,
    },

    -- Treesitter - Modern syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "lua", "vim", "vimdoc", "query", "javascript", "typescript", "python", "rust", "go", "html", "css", "json" },
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<C-space>",
                        node_incremental = "<C-space>",
                        scope_incremental = false,
                        node_decremental = "<bs>",
                    },
                },
            })
        end,
    },

    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("conform").setup {
                formatters_by_ft = {
                    c = { "clang_format" },
                },
                format_on_save = {
                    timeout_ms = 500,
                    lsp_fallback = true,
                },
            }
        end
    },

    -- LSP
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "nvimtools/none-ls.nvim",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",
                    "ts_ls",
                    "html", "cssls", "eslint" },
            })

            local on_attach = function(client, bufnr)
                local opts = { buffer = bufnr }
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
                vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            end

            local lspconfig = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            lspconfig.ts_ls.setup({ on_attach = on_attach, capabilities = capabilities })
            lspconfig.html.setup({ on_attach = on_attach, capabilities = capabilities })
            lspconfig.cssls.setup({ on_attach = on_attach, capabilities = capabilities })
            lspconfig.eslint.setup({ on_attach = on_attach, capabilities = capabilities })

            -- Formatting with none-ls
            local null_ls = require("null-ls")
            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.prettier.with({
                        filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact", "html", "css" },
                    }),
                },
            })

            -- Diagnostics
            vim.diagnostic.config({
                virtual_text = false,
                signs = true,
                float = { border = "rounded" },
            })
            vim.keymap.set("n", "<leader>ds", vim.diagnostic.open_float)
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
        end,
    },

    -- Autocompletion - Modern completion engine
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
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
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete({}),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
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


    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    file_ignore_patterns = { "%.o", "%.out", "build/", "cmake-build-.*" },
                },
            })
        end,
    },

    -- Telescope - Fuzzy finder
    -- {
    --   "nvim-telescope/telescope.nvim",
    --   branch = "0.1.x",
    --   dependencies = {
    --     "nvim-lua/plenary.nvim",
    --     { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    --   },
    --   config = function()
    --     require("telescope").setup({
    --       defaults = {
    --         prompt_prefix = " ",
    --         selection_caret = " ",
    --         path_display = { "truncate" },
    --         file_ignore_patterns = { "%.git/", "node_modules/", "%.cache/" },
    --       },
    --       extensions = {
    --         fzf = {
    --           fuzzy = true,
    --           override_generic_sorter = true,
    --           override_file_sorter = true,
    --           case_mode = "smart_case",
    --         },
    --       },
    --     })
    --     require("telescope").load_extension("fzf")
    --
    --     -- Telescope keymaps
    --     local builtin = require("telescope.builtin")
    --     vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
    --     vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
    --     vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
    --     vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })
    --     vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent Files" })
    --   end,
    -- },

    {
        "ibhagwan/fzf-lua",
        -- optional for icon support
        dependencies = {
            -- "nvim-tree/nvim-web-devicons"
        },
        -- or if using mini.icons/mini.nvim
        -- dependencies = { "nvim-mini/mini.icons" },
        opts = {}
    },

    -- Oil.nvim (alternative to neo-tree/nvim-tree)
    {
        "stevearc/oil.nvim",
        dependencies = {
            -- "nvim-tree/nvim-web-devicons"

        },
        keys = {
            -- { "<leader><leader>", "<cmd>Oil<cr>", desc = "Open file explorer" },
            { "<leader>e", "<cmd>Oil<cr>", desc = "Open file explorer" },
            { "-",         "<cmd>Oil<cr>", desc = "Open parent directory" },
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


    -- Git integration - Gitsigns
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns
                    local map = function(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    -- Navigation
                    map("n", "]c", function()
                        if vim.wo.diff then return "]c" end
                        vim.schedule(function() gs.next_hunk() end)
                        return "<Ignore>"
                    end, { expr = true, desc = "Next Hunk" })

                    map("n", "[c", function()
                        if vim.wo.diff then return "[c" end
                        vim.schedule(function() gs.prev_hunk() end)
                        return "<Ignore>"
                    end, { expr = true, desc = "Previous Hunk" })

                    -- Actions
                    map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage Hunk" })
                    map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset Hunk" })
                    map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage Buffer" })
                    map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
                    map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset Buffer" })
                    map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview Hunk" })
                    map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, { desc = "Blame Line" })
                    map("n", "<leader>hd", gs.diffthis, { desc = "Diff This" })
                end,
            })
        end,
    },

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            -- "nvim-tree/nvim-web-devicons"
        },
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
    -- Which-key for discoverable keybindings
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup()
            -- require("which-key").register({
            --   ["<leader>f"] = { name = "+Find" },
            --   ["<leader>h"] = { name = "+Git Hunks" },
            --   ["<leader>c"] = { name = "+Code" },
            --   ["<leader>d"] = { name = "+Diagnostics" },
            --   ["<leader>g"] = { name = "+Goto" },
            -- })
        end,
    },

    -- Auto-pairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({})
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            local cmp = require("cmp")
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
    },

    -- Comment toggling
    {
        "numToStr/Comment.nvim",
        event = "VeryLazy",
        config = function()
            require("Comment").setup()
        end,
    },

    -- Surround operations
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup()
        end,
    },
}, {
    -- lazy.nvim options
    ui = {
        border = "rounded",
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})

-- Adaptive Go to Definition Function
local function adaptive_goto_definition()
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")

    -- Store current window and cursor position for context restoration
    local current_win = vim.api.nvim_get_current_win()
    local current_pos = vim.api.nvim_win_get_cursor(current_win)
    local current_buf = vim.api.nvim_get_current_buf()

    -- Screen size thresholds (adjustable based on preference)
    local wide_screen_threshold = 160 -- columns
    local tall_screen_threshold = 40 -- lines

    -- Determine split direction based on screen dimensions
    local should_split_vertical = width > wide_screen_threshold
    local should_split_horizontal = height > tall_screen_threshold and not should_split_vertical

    -- Function to handle the actual definition jump
    local function handle_definition()
        -- Try LSP first, fallback to built-in methods
        local clients = vim.lsp.get_active_clients({ bufnr = 0 })

        if #clients > 0 then
            -- Use LSP definition
            local params = vim.lsp.util.make_position_params()

            vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result)
                if err or not result or vim.tbl_isempty(result) then
                    -- Fallback to built-in definition methods
                    vim.cmd("normal! gd")
                    return
                end

                -- Handle multiple definitions
                local definition = result[1] or result
                if definition.uri then
                    local target_file = vim.uri_to_fname(definition.uri)
                    local target_line = definition.range.start.line + 1
                    local target_col = definition.range.start.character + 1

                    -- Check if definition is in the same file
                    local current_file = vim.api.nvim_buf_get_name(current_buf)
                    local same_file = target_file == current_file

                    if same_file and not should_split_vertical and not should_split_horizontal then
                        -- Same file, small screen - just jump
                        vim.api.nvim_win_set_cursor(current_win, { target_line, target_col - 1 })
                        vim.cmd("normal! zz") -- center the line
                    else
                        -- Different file or large screen - create split
                        local split_cmd = ""
                        local split_size = ""

                        if should_split_vertical then
                            -- Vertical split for wide screens
                            split_size = math.floor(width * 0.6) -- 60% of screen width
                            split_cmd = "vertical split"
                        elseif should_split_horizontal then
                            -- Horizontal split for tall screens
                            split_size = math.floor(height * 0.4) -- 40% of screen height
                            split_cmd = "split"
                        else
                            -- Small screen - use a smaller split
                            if width > height * 2 then
                                split_cmd = "vertical split"
                                split_size = math.floor(width * 0.5)
                            else
                                split_cmd = "split"
                                split_size = math.floor(height * 0.3)
                            end
                        end

                        -- Execute split and navigate to definition
                        vim.cmd(split_cmd)
                        if split_size > 0 then
                            if should_split_vertical then
                                vim.cmd("vertical resize " .. split_size)
                            else
                                vim.cmd("resize " .. split_size)
                            end
                        end

                        -- Open the file and go to position
                        vim.cmd("edit " .. target_file)
                        vim.api.nvim_win_set_cursor(0, { target_line, target_col - 1 })
                        vim.cmd("normal! zz")

                        -- Set up keymap to close the definition window
                        vim.keymap.set("n", "q", "<cmd>close<CR>", {
                            buffer = true,
                            desc = "Close definition window"
                        })
                        vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", {
                            buffer = true,
                            desc = "Close definition window"
                        })
                    end
                end
            end)
        else
            -- No LSP available, use built-in methods
            if should_split_vertical then
                vim.cmd("vertical split")
                vim.cmd("vertical resize " .. math.floor(width * 0.6))
            elseif should_split_horizontal then
                vim.cmd("split")
                vim.cmd("resize " .. math.floor(height * 0.4))
            end

            -- Try built-in go to definition
            local ok, _ = pcall(vim.cmd, "normal! gd")
            if not ok then
                -- If gd fails, try tag jump
                pcall(vim.cmd, "normal! <C-]>")
            end

            -- Center the definition
            vim.cmd("normal! zz")

            -- Set up keymap to close if we created a split
            if should_split_vertical or should_split_horizontal then
                vim.keymap.set("n", "q", "<cmd>close<CR>", {
                    buffer = true,
                    desc = "Close definition window"
                })
            end
        end
    end

    handle_definition()
end

-- Enhanced preview definition (peek without leaving current position)
local function preview_definition()
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })

    if #clients > 0 then
        local params = vim.lsp.util.make_position_params()

        vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result)
            if err or not result or vim.tbl_isempty(result) then
                vim.notify("No definition found", vim.log.levels.WARN)
                return
            end

            local definition = result[1] or result
            if definition.uri then
                local target_file = vim.uri_to_fname(definition.uri)
                local target_line = definition.range.start.line + 1

                -- Create a floating preview window
                local buf = vim.fn.bufnr(target_file, true)
                vim.fn.bufload(buf)

                local lines = vim.api.nvim_buf_get_lines(buf,
                    math.max(0, target_line - 10),
                    target_line + 10,
                    false
                )

                -- Create floating window
                local width = math.min(vim.api.nvim_get_option("columns") - 4, 80)
                local height = math.min(#lines, 20)

                local opts = {
                    relative = 'cursor',
                    width = width,
                    height = height,
                    col = 1,
                    row = 1,
                    anchor = 'NW',
                    style = 'minimal',
                    border = 'rounded',
                }

                local preview_buf = vim.api.nvim_create_buf(false, true)
                vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)

                -- Set filetype for syntax highlighting
                local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')
                vim.api.nvim_buf_set_option(preview_buf, 'filetype', filetype)

                local preview_win = vim.api.nvim_open_win(preview_buf, false, opts)

                -- Highlight the target line
                local target_line_in_preview = math.min(10, target_line - 1)
                vim.api.nvim_buf_add_highlight(preview_buf, -1, 'CursorLine',
                    target_line_in_preview, 0, -1)

                -- Auto-close after 3 seconds or on cursor move
                local timer = vim.loop.new_timer()
                timer:start(3000, 0, vim.schedule_wrap(function()
                    if vim.api.nvim_win_is_valid(preview_win) then
                        vim.api.nvim_win_close(preview_win, true)
                    end
                    timer:close()
                end))

                -- Close on cursor movement
                local close_on_move = vim.api.nvim_create_autocmd("CursorMoved", {
                    callback = function()
                        if vim.api.nvim_win_is_valid(preview_win) then
                            vim.api.nvim_win_close(preview_win, true)
                        end
                        timer:close()
                        return true -- Delete the autocmd
                    end,
                })
            end
        end)
    else
        vim.notify("No LSP client available", vim.log.levels.WARN)
    end
end

-- Essential keymaps
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic error messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic quickfix list" })

-- Adaptive go to definition keymaps
vim.keymap.set("n", "gd", adaptive_goto_definition, { desc = "Adaptive Go to Definition" })
vim.keymap.set("n", "gD", preview_definition, { desc = "Preview Definition" })
vim.keymap.set("n", "<leader>gd", function()
    -- Force horizontal split regardless of screen size
    vim.cmd("split")
    vim.lsp.buf.definition()
    vim.cmd("normal! zz")
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true })
end, { desc = "Go to Definition (Horizontal Split)" })
vim.keymap.set("n", "<leader>gv", function()
    -- Force vertical split regardless of screen size
    vim.cmd("vertical split")
    vim.lsp.buf.definition()
    vim.cmd("normal! zz")
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true })
end, { desc = "Go to Definition (Vertical Split)" })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Move lines up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor in place when joining lines
vim.keymap.set("n", "J", "mzJ`z")

-- Keep cursor centered when scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>")


-- Enhanced Autocmds for modern editing and workflow optimization
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- General editing enhancements
local general_group = augroup("GeneralEnhancements", { clear = true })

-- Highlight yanked text
autocmd("TextYankPost", {
    group = general_group,
    desc = "Highlight when yanking text",
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
})

-- Auto-create directories when saving files
autocmd("BufWritePre", {
    group = general_group,
    desc = "Create missing directories when saving",
    callback = function(event)
        if event.match:match("^%w%w+:[\\/][\\/]") then
            return -- Don't create directories for URLs
        end
        local file = vim.loop.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

-- Remove trailing whitespace on save for specific filetypes
autocmd("BufWritePre", {
    group = general_group,
    pattern = { "*.lua", "*.py", "*.js", "*.ts", "*.jsx", "*.tsx", "*.rs", "*.go", "*.c", "*.cpp", "*.h", "*.hpp" },
    desc = "Remove trailing whitespace on save",
    callback = function()
        local save_cursor = vim.fn.getpos(".")
        pcall(function()
            vim.cmd([[%s/\s\+$//e]])
        end)
        vim.fn.setpos(".", save_cursor)
    end,
})

-- Auto-format on save for specific filetypes (if formatter is available)
autocmd("BufWritePre", {
    group = general_group,
    pattern = { "*.lua", "*.py", "*.js", "*.ts", "*.jsx", "*.tsx", "*.rs", "*.go" },
    desc = "Auto-format on save if LSP formatter available",
    callback = function()
        if vim.lsp.buf.format then
            vim.lsp.buf.format({
                async = false,
                filter = function(client)
                    -- Only use formatters that are fast
                    local fast_formatters = { "null-ls", "efm", "prettier", "black", "rustfmt", "gofmt" }
                    for _, formatter in ipairs(fast_formatters) do
                        if client.name:find(formatter) then
                            return true
                        end
                    end
                    return client.server_capabilities.documentFormattingProvider
                end
            })
        end
    end,
})

-- Window and buffer management
local window_group = augroup("WindowManagement", { clear = true })

-- Automatically balance windows when terminal is resized
autocmd("VimResized", {
    group = window_group,
    desc = "Balance windows on terminal resize",
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
    end,
})

-- Close certain filetypes with 'q'
autocmd("FileType", {
    group = window_group,
    pattern = {
        "help", "startuptime", "qf", "lspinfo", "man", "checkhealth",
        "null-ls-info", "tsplayground", "PlenaryTestPopup"
    },
    desc = "Close with 'q' for special filetypes",
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<CR>", {
            buffer = event.buf,
            silent = true,
            desc = "Close window"
        })
    end,
})

-- Smart window closing - close empty buffers automatically
autocmd("BufEnter", {
    group = window_group,
    desc = "Close empty unnamed buffers",
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        if vim.api.nvim_buf_get_name(buf) == ""
            and vim.bo[buf].filetype == ""
            and vim.bo[buf].buftype == ""
            and not vim.bo[buf].modified then
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            if #lines == 1 and lines[1] == "" then
                vim.schedule(function()
                    if vim.api.nvim_buf_is_valid(buf) and #vim.api.nvim_list_wins() > 1 then
                        vim.api.nvim_buf_delete(buf, { force = false })
                    end
                end)
            end
        end
    end,
})

-- Code intelligence and development workflow
local dev_group = augroup("DevelopmentWorkflow", { clear = true })

-- Smart cursor placement when opening files
autocmd("BufReadPost", {
    group = dev_group,
    desc = "Restore cursor position and center screen",
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local line_count = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= line_count then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
            vim.cmd("normal! zz")
        end
    end,
})

-- Auto-reload files changed externally
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = dev_group,
    desc = "Check for external file changes",
    callback = function()
        if vim.o.buftype ~= "nofile" then
            vim.cmd("checktime")
        end
    end,
})

-- Smart line numbers - relative in normal mode, absolute in insert mode
autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
    group = dev_group,
    desc = "Set relative line numbers in normal mode",
    callback = function()
        if vim.o.number and vim.fn.mode() ~= "i" then
            vim.o.relativenumber = true
        end
    end,
})

autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
    group = dev_group,
    desc = "Set absolute line numbers in insert mode",
    callback = function()
        if vim.o.number then
            vim.o.relativenumber = false
        end
    end,
})



-- LSP and diagnostic enhancements
local lsp_group = augroup("LSPEnhancements", { clear = true })

-- Show diagnostics automatically in hover window
autocmd("CursorHold", {
    group = lsp_group,
    desc = "Show diagnostics in floating window",
    callback = function()
        local opts = {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = "rounded",
            source = "always",
            prefix = " ",
            scope = "cursor",
        }
        vim.diagnostic.open_float(nil, opts)
    end,
})

-- Smart diagnostic navigation
autocmd("DiagnosticChanged", {
    group = lsp_group,
    desc = "Update diagnostic counts for statusline",
    callback = function()
        vim.g.diagnostic_count = {
            error = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }),
            warn = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN }),
            info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO }),
            hint = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT }),
        }
    end,
})

-- Terminal enhancements
local terminal_group = augroup("TerminalEnhancements", { clear = true })

-- Terminal-specific settings
autocmd("TermOpen", {
    group = terminal_group,
    desc = "Terminal-specific settings",
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
        vim.opt_local.foldcolumn = "0"
        vim.opt_local.wrap = true
        vim.cmd("startinsert")

        -- Easy terminal escape
        vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { buffer = true, desc = "Exit terminal mode" })
        vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { buffer = true, desc = "Move to left window" })
        vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { buffer = true, desc = "Move to bottom window" })
        vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { buffer = true, desc = "Move to top window" })
        vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { buffer = true, desc = "Move to right window" })
    end,
})

-- Performance optimizations
local perf_group = augroup("PerformanceOptimizations", { clear = true })

-- Disable certain features for large files
autocmd("BufReadPre", {
    group = perf_group,
    desc = "Optimize settings for large files",
    callback = function(args)
        local file_size = vim.fn.getfsize(args.file)
        if file_size > 1024 * 1024 then -- 1MB
            vim.b.large_file = true
            vim.opt_local.eventignore:append({
                "FileType",
                "Syntax",
                "BufReadPost",
                "BufReadPre"
            })
            vim.opt_local.undolevels = -1
            vim.opt_local.undoreload = 0
            vim.opt_local.list = false
        end
    end,
})

-- Custom session management
local session_group = augroup("SessionManagement", { clear = true })

-- Auto-save session on exit
autocmd("VimLeavePre", {
    group = session_group,
    desc = "Auto-save session",
    callback = function()
        if vim.v.this_session ~= "" then
            vim.cmd("mksession! " .. vim.v.this_session)
        end
    end,
})

-- Smart session restoration
autocmd("VimEnter", {
    group = session_group,
    desc = "Auto-restore session if no files specified",
    callback = function()
        if vim.fn.argc() == 0 and vim.v.this_session == "" then
            local session_file = vim.fn.getcwd() .. "/.session.vim"
            if vim.fn.filereadable(session_file) == 1 then
                vim.cmd("source " .. session_file)
            end
        end
    end,
})

vim.keymap.set("n", "<leader>td", function()
    local datetime = os.date("%Y-%m-%d %H:%M:%S")
    local todo = "TODO (" .. datetime .. ") "
    vim.api.nvim_put({ todo }, "c", true, true)
end, { desc = "Insert TODO with timestamp" })



vim.keymap.set("n", "ff", "<cmd>FzfLua files<CR>", { buffer = true, desc = "FzfLua File Search" })
-- vim.keymap.set("n", "fg", "<cmd><CR>", { buffer = true, desc = "Ag Content Grep" })
