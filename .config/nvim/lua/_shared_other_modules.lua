return {

    -- === Tpope Essentials ===
    { "tpope/vim-sensible" },
    {
        "tpope/vim-surround",
        keys = { "ys", "cs", "ds", { "S", mode = "v" } },
    },
    { "tpope/vim-repeat",     event = "VeryLazy" },
    { "tpope/vim-commentary", keys = { "gc", { "gc", mode = "v" } } },
    {
        "tpope/vim-fugitive",
        cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
        keys = {
            { "<leader>gs", "<cmd>Git<cr>",        desc = "Git status" },
            { "<leader>gc", "<cmd>Git commit<cr>", desc = "Git commit" },
            { "<leader>gp", "<cmd>Git push<cr>",   desc = "Git push" },
            { "<leader>gl", "<cmd>Git pull<cr>",   desc = "Git pull" },
        },
    },
    { "tpope/vim-rhubarb",     dependencies = "tpope/vim-fugitive" },
    { "tpope/vim-eunuch",      cmd = { "Remove", "Delete", "Move", "Chmod", "Mkdir", "SudoWrite" } },
    { "tpope/vim-unimpaired",  event = "VeryLazy" },
    { "tpope/vim-abolish",     cmd = { "Abolish", "Subvert" } },
    { "tpope/vim-dispatch",    cmd = { "Dispatch", "Make", "Focus", "Start" } },
    { "tpope/vim-endwise",     event = "InsertEnter" },
    { "tpope/vim-speeddating", keys = { "<C-a>", "<C-x>" } },
    { "tpope/vim-sleuth" }, -- Auto-detect indentation


    {
        "rebelot/kanagawa.nvim",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("kanagawa")
        end
    },

    -- {
    --     'navarasu/onedark.nvim',
    --     priority = 1000,
    --     config = function()
    --         vim.cmd.colorscheme('onedark')
    --     end,
    -- },

    {
        'neovim/nvim-lspconfig',
        enabled = false,
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'hrsh7th/cmp-nvim-lsp',
            'j-hui/fidget.nvim',
        },
        config = function()
            require('fidget').setup {}
            require('mason').setup()
            require('mason-lspconfig').setup {
                ensure_installed = {
                    'cmake',
                    'clangd',
                    'zls',
                    'rust_analyzer',
                    'lua_ls',
                    'ts_ls',
                    'vue_ls',
                    'fsharp'
                }
            }

            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            local on_attach = function(client, bufnr)
                -- Enable formatting if the server supports it
                if client.server_capabilities.documentFormattingProvider then
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format({ async = false })
                        end,
                    })
                end
            end

            vim.lsp.config('clangd', {
                capabilities = capabilities,
                on_attach = on_attach,
                cmd = {
                    'clangd',
                    '--background-index',
                    '--clang-tidy',
                    '--header-insertion=iwyu',
                    '--completion-style=detailed',
                    '--function-arg-placeholders',
                    '--fallback-style=llvm', -- fallback style controls indent/format defaults
                },
                init_options = {
                    usePlaceholders = true,
                    completeUnimported = true,
                    clangdFileStatus = true,
                },
            })

            vim.lsp.config('zls', {
                cmd = { "zls" }, -- Ensure 'zls' is in your PATH
                on_attach = function(client, bufnr)
                    -- Example: keybindings for LSP
                    local opts = { noremap = true, silent = true }
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                end,
            })


            vim.lsp.config('fsharp', {})

            vim.lsp.config('rust-analyzer', {
                -- vim.lsp.config('rust_analyzer', {
                capabilities = capabilities,
                on_attach = on_attach,
                cmd = { "rust-analyzer" },
                settings = {
                    ["rust-analyzer"] = {
                        cargo = {
                            allFeatures = true,
                        },
                        checkOnSave = {
                            command = "clippy", -- run clippy on save
                        },
                        completion = {
                            postfix = { enable = true },
                        },
                        diagnostics = {
                            enable = true,
                        },
                    },
                },
            })

            vim.lsp.config('ts_ls', {
                on_attach = on_attach,
                capabilities = capabilities,
                filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
            })


            -- vim.lsp.config('volar', {
            vim.lsp.config('vue_ls', {
                capabilities = capabilities,
                on_attach = on_attach,
                -- cmd = { "vue_ls", "--stdio" },
                cmd = { "vue-language-server", "--stdio" },
                filetypes = { "vue" },
                init_options = {
                    typescript = {
                        tsdk = vim.fn.stdpath("data") ..
                            "/mason/packages/typescript-language-server/node_modules/typescript/lib"
                    },
                },
                settings = {
                    vue = {
                        format = { enable = false }, -- again, prefer prettier
                    },
                },
            })


            vim.lsp.config('lua_ls', {
                capabilities = capabilities,
                on_attach = on_attach,
                cmd = { "lua-language-server" },
                settings = {
                    Lua = {
                        runtime = {
                            -- Tell the server which version of Lua you're using
                            version = 'LuaJIT',
                            -- Setup your lua path
                            path = vim.split(package.path, ';'),
                        },
                        diagnostics = {
                            -- Recognize the `vim` global
                            globals = { 'vim' },
                        },
                        workspace = {
                            -- Make the server aware of Neovim runtime files
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false, -- avoid annoying prompts
                        },
                        telemetry = {
                            enable = false,
                        },
                        format = {
                            enable = true, -- use lua_ls as formatter
                        },
                    },
                },
            })

            -- END LSP CONFIG
        end
    },

    -- completion
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'rafamadriz/friendly-snippets',
        },
        config = function()
            local cmp = require 'cmp'
            local luasnip = require 'luasnip'
            require('luasnip.loaders.from_vscode').lazy_load()

            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    ['<C-p>'] = cmp.mapping.select_prev_item(),
                    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete {},
                    ['<CR>'] = cmp.mapping.confirm { select = true },
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
                sources = cmp.config.sources {
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'buffer',  keyword_length = 3 },
                    { name = 'path' },
                },
                formatting = {
                    format = function(entry, item)
                        item.menu = ({
                            nvim_lsp = '[LSP]',
                            luasnip = '[Snip]',
                            buffer = '[Buf]',
                            path = '[Path]',
                        })[entry.source.name]
                        return item
                    end,
                },
            }

            -- cmdline completion
            cmp.setup.cmdline('/', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = { { name = 'buffer' } }
            })
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = { { name = 'path' }, { name = 'cmdline' } }
            })
        end
    },

    -- which-key (shows keybindings)
    {
        'folke/which-key.nvim',
        event = 'VeryLazy',
        config = function()
            require('which-key').setup()
            require('which-key').add({
                { '<leader>f', group = 'Find' },
                { '<leader>h', group = 'Git Hunk' },
                { '<leader>c', group = 'Code' },
                { '<leader>r', group = 'Rename' },
            })
        end
    },

    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.5",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require("telescope.builtin")
            -- vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
            vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
        end
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



    {
        "nvim-lualine/lualine.nvim",
        enabled = true,
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

    {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end,
    },

    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
        },
        config = function()
            local cmp = require('cmp')
            local luasnip = require('luasnip')

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                }, {
                    { name = 'buffer' },
                    { name = 'path' },
                }),
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-context",
        config = function()
            require 'treesitter-context'.setup {
                enable = true,
                max_lines = 3,
            }
        end,
    },
    {
        'dmtrKovalenko/fff.nvim',
        build = function()
            -- this will download prebuild binary or try to use existing rustup toolchain to build from source
            -- (if you are using lazy you can use gb for rebuilding a plugin if needed)
            require("fff.download").download_or_build_binary()
        end,
        -- if you are using nixos
        -- build = "nix run .#release",
        opts = {                    -- (optional)
            debug = {
                enabled = true,     -- we expect your collaboration at least during the beta
                show_scores = true, -- to help us optimize the scoring system, feel free to share your scores!
            },
        },
        -- No need to lazy-load with lazy.nvim.
        -- This plugin initializes itself lazily.
        lazy = false,
        keys = {
            {
                "ff", -- try it if you didn't it is a banger keybinding for a picker
                function() require('fff').find_files() end,
                desc = 'FFFind files',
            }
        },
        config = function()
            require('fff').setup({
                base_path = vim.fn.getcwd(),
                prompt = '🪿 ',
                title = 'FFFiles',
                max_results = 100,
                max_threads = 4,
                lazy_sync = true, -- set to false if you want file indexing to start on open
                layout = {
                    height = 0.8,
                    width = 0.8,
                    prompt_position = 'bottom', -- or 'top'
                    preview_position = 'right', -- or 'left', 'right', 'top', 'bottom'
                    preview_size = 0.5,
                },
                preview = {
                    enabled = true,
                    max_size = 10 * 1024 * 1024,  -- Do not try to read files larger than 10MB
                    chunk_size = 8192,            -- Bytes per chunk for dynamic loading (8kb - fits ~100-200 lines)
                    binary_file_threshold = 1024, -- amount of bytes to scan for binary content (set 0 to disable)
                    imagemagick_info_format_str = '%m: %wx%h, %[colorspace], %q-bit',
                    line_numbers = false,
                    wrap_lines = false,
                    show_file_info = true,
                    filetypes = {
                        svg = { wrap_lines = true },
                        markdown = { wrap_lines = true },
                        text = { wrap_lines = true },
                    },
                },
                keymaps = {
                    close = '<Esc>',
                    select = '<CR>',
                    select_split = '<C-s>',
                    select_vsplit = '<C-v>',
                    select_tab = '<C-t>',
                    move_up = { '<Up>', '<C-p>' },
                    move_down = { '<Down>', '<C-n>' },
                    preview_scroll_up = '<C-u>',
                    preview_scroll_down = '<C-d>',
                    toggle_debug = '<F2>',
                },
                hl = {
                    border = 'FloatBorder',
                    normal = 'Normal',
                    cursor = 'CursorLine',
                    matched = 'IncSearch',
                    title = 'Title',
                    prompt = 'Question',
                    active_file = 'Visual',
                    frecency = 'Number',
                    debug = 'Comment',
                },
                frecency = {
                    enabled = true,
                    db_path = vim.fn.stdpath('cache') .. '/fff_nvim',
                },
                debug = {
                    enabled = false, -- Set to true to show scores in the UI
                    show_scores = false,
                },
                logging = {
                    enabled = true,
                    log_file = vim.fn.stdpath('log') .. '/fff.log',
                    log_level = 'info',
                }
            })
        end
    }


}
