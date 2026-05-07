--=============================================================================
-- Neovim init.lua  –  C + Assembly IDE (Enhanced)
--=============================================================================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- -------------------- OPTIONS --------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.signcolumn = 'yes'
vim.opt.termguicolors = true
vim.opt.completeopt = { 'menuone', 'noselect' }
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.cursorline = true
vim.opt.mouse = 'a'

-- C/Assembly specific settings
vim.opt.colorcolumn = '80'
vim.opt.textwidth = 80

-- -------------------- PLUGIN BOOTSTRAP --------------------
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system { 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath }
end
vim.opt.rtp:prepend(lazypath)

-- -------------------- PLUGIN SPEC --------------------
require('lazy').setup({


    require("./_shared_other_modules"),
    require("./_shared_mason_lsp_treesitter"),

    -- COLORSCHEME (pick one)
    {
        "rebelot/kanagawa.nvim",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("kanagawa")
        end
    },

    -- syntax
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup {
                ensure_installed = { 'c', 'cpp', 'asm', 'lua', 'vim', 'vimdoc', 'make', 'cmake', 'rust' },
                highlight = { enable = true, additional_vim_regex_highlighting = false },
                indent = { enable = true },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = '<C-space>',
                        node_incremental = '<C-space>',
                        scope_incremental = false,
                        node_decremental = '<bs>',
                    },
                },
            }
        end
    },

    -- LSP
    {
        'neovim/nvim-lspconfig',
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
                ensure_installed = { 'clangd', 'cmake', 'lua_ls' }
            }

            local cap = require('cmp_nvim_lsp').default_capabilities()

            vim.lsp.config('lua_ls', {
                on_init = function(client)
                    if client.workspace_folders then
                        local path = client.workspace_folders[1].name
                        if
                            path ~= vim.fn.stdpath('config')
                            and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
                        then
                            return
                        end
                    end

                    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                        runtime = {
                            -- Tell the language server which version of Lua you're using (most
                            -- likely LuaJIT in the case of Neovim)
                            version = 'LuaJIT',
                            -- Tell the language server how to find Lua modules same way as Neovim
                            -- (see `:h lua-module-load`)
                            path = {
                                'lua/?.lua',
                                'lua/?/init.lua',
                            },
                        },
                        -- Make the server aware of Neovim runtime files
                        workspace = {
                            checkThirdParty = false,
                            library = {
                                vim.env.VIMRUNTIME
                                -- Depending on the usage, you might want to add additional paths
                                -- here.
                                -- '${3rd}/luv/library'
                                -- '${3rd}/busted/library'
                            }
                            -- Or pull in all of 'runtimepath'.
                            -- NOTE: this is a lot slower and will cause issues when working on
                            -- your own configuration.
                            -- See https://github.com/neovim/nvim-lspconfig/issues/3189
                            -- library = {
                            --   vim.api.nvim_get_runtime_file('', true),
                            -- }
                        }
                    })
                end,
                settings = {
                    Lua = {}
                }
            })


            -- Clangd with enhanced settings
            -- require('lspconfig').clangd.setup {

            vim.lsp.config('clangd', {

                cmd = {
                    'clangd',
                    '--background-index',
                    '--clang-tidy',
                    '--header-insertion=iwyu',
                    '--completion-style=detailed',
                    '--function-arg-placeholders',
                    '--fallback-style=llvm',
                },
                init_options = {
                    usePlaceholders = true,
                    completeUnimported = true,
                    clangdFileStatus = true,
                },
                on_attach = function(client, bufnr)
                    -- Example keymap to show hover info
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = "LSP Hover" })

                    -- Example: Show diagnostics in a floating window
                    vim.keymap.set('n', '<space>i', vim.diagnostic.open_float,
                        { buffer = bufnr, desc = "Open Diagnostic Float" })
                    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,
                        { buffer = bufnr, desc = "Go to Previous Diagnostic" })
                    vim.keymap.set('n', ']d', vim.diagnostic.goto_next,
                        { buffer = bufnr, desc = "Go to Next Diagnostic" })
                end,
            })

            -- Asm LSP (if available)
            -- require('lspconfig').asm_lsp.setup { capabilities = cap }
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

    -- finder
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            { 'nvim-lua/plenary.nvim' },
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
        },
        keys = {
            { '<leader>ff', '<cmd>Telescope find_files<cr>',  desc = 'Find files' },
            { '<leader>fg', '<cmd>Telescope live_grep<cr>',   desc = 'Live grep' },
            { '<leader>fb', '<cmd>Telescope buffers<cr>',     desc = 'Buffers' },
            { '<leader>fh', '<cmd>Telescope help_tags<cr>',   desc = 'Help tags' },
            { '<leader>fr', '<cmd>Telescope oldfiles<cr>',    desc = 'Recent files' },
            { '<leader>fc', '<cmd>Telescope grep_string<cr>', desc = 'Grep cursor word' },
        },
        config = function()
            -- You dont need to set any of these options. These are the default ones. Only
            -- the loading is important
            require('telescope').setup {
                extensions = {
                    fzf = {
                        fuzzy = true,                   -- false will only do exact matching
                        override_generic_sorter = true, -- override the generic sorter
                        override_file_sorter = true,    -- override the file sorter
                        case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
                        -- the default case_mode is "smart_case"
                    }
                }
            }
            -- To get fzf loaded and working with telescope, you need to call
            -- load_extension, somewhere after setup function:
            require('telescope').load_extension('fzf')
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

    -- -- explorer
    -- {
    --     'nvim-tree/nvim-tree.lua',
    --     dependencies = { 'nvim-tree/nvim-web-devicons' },
    --     keys = {
    --         { '<leader>e', '<cmd>NvimTreeToggle<cr>',   desc = 'Explorer' },
    --         { '<leader>E', '<cmd>NvimTreeFindFile<cr>', desc = 'Explorer (current file)' },
    --     },
    --     config = function()
    --         require('nvim-tree').setup {
    --             view = { width = 35 },
    --             renderer = { group_empty = true },
    --             filters = { dotfiles = false },
    --         }
    --     end
    -- },
    --
    -- git
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup {
                signs = {
                    add          = { text = '│' },
                    change       = { text = '│' },
                    delete       = { text = '_' },
                    topdelete    = { text = '‾' },
                    changedelete = { text = '~' },
                },
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns
                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end
                    map('n', ']c', gs.next_hunk, { desc = 'Next hunk' })
                    map('n', '[c', gs.prev_hunk, { desc = 'Prev hunk' })
                    map('n', '<leader>hs', gs.stage_hunk, { desc = 'Stage hunk' })
                    map('n', '<leader>hr', gs.reset_hunk, { desc = 'Reset hunk' })
                    map('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview hunk' })
                    map('n', '<leader>hb', function() gs.blame_line { full = true } end, { desc = 'Blame line' })
                end,
            }
        end
    },


    -- extras
    {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    },

    {
        'windwp/nvim-autopairs',
        config = function()
            require('nvim-autopairs').setup()
            local cmp_autopairs = require('nvim-autopairs.completion.cmp')
            local cmp = require('cmp')
            cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
        end
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
        "lewis6991/gitsigns.nvim",
        config = function()
            require('gitsigns').setup()
        end,
    },
    -- {
    --     "folke/tokyonight.nvim",
    --     priority = 1000,
    --     config = function()
    --         vim.cmd.colorscheme("tokyonight")
    --     end,
    -- },


    -- hex editor
    {
        'RaafatTurki/hex.nvim',
        config = function()
            require('hex').setup()
        end
    },

    -- indent guides
    {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        config = function()
            require('ibl').setup()
        end
    },

    {
        'gelguy/wilder.nvim',
        config = function()
            local wilder = require('wilder')
            wilder.setup({ modes = { ':', '/', '?' } })
        end,
    },

    -- better quickfix
    { 'kevinhwang91/nvim-bqf' },

    -- LSP progress
    { 'j-hui/fidget.nvim',    opts = {} },

    {
        'mhartington/formatter.nvim',
        config = function()
            -- Utilities for creating configurations
            local util = require "formatter.util"

            -- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
            require("formatter").setup {
                -- Enable or disable logging
                logging = true,
                -- Set the log level
                log_level = vim.log.levels.WARN,
                -- All formatter configurations are opt-in
                filetype = {
                    -- Formatter configurations for filetype "lua" go here
                    -- and will be executed in order
                    lua = {
                        -- "formatter.filetypes.lua" defines default configurations for the
                        -- "lua" filetype
                        require("formatter.filetypes.lua").stylua,

                        -- You can also define your own configuration
                        function()
                            -- Supports conditional formatting
                            if util.get_current_buffer_file_name() == "special.lua" then
                                return nil
                            end

                            -- Full specification of configurations is down below and in Vim help
                            -- files
                            return {
                                exe = "stylua",
                                args = {
                                    "--search-parent-directories",
                                    "--stdin-filepath",
                                    util.escape_path(util.get_current_buffer_file_path()),
                                    "--",
                                    "-",
                                },
                                stdin = true,
                            }
                        end
                    },

                    -- Use the special "*" filetype for defining formatter configurations on
                    -- any filetype
                    ["*"] = {
                        -- "formatter.filetypes.any" defines default configurations for any
                        -- filetype
                        require("formatter.filetypes.any").remove_trailing_whitespace,
                        -- Remove trailing whitespace without 'sed'
                        -- require("formatter.filetypes.any").substitute_trailing_whitespace,
                    }
                }
            }
        end
    },

    {
        'ray-x/cmp-treesitter',
        config = function()
            require('cmp').setup {
                sources = {
                    { name = 'treesitter' }
                }
            }
        end
    },

    { 'preservim/tagbar' },
    -- {'itchyny/lightline.vim'}
    { 'mhinz/vim-startify' },
    {
        "rmagatti/goto-preview",
        dependencies = { "rmagatti/logger.nvim" },
        event = "BufEnter",
        -- config = true, -- necessary as per https://github.com/rmagatti/goto-preview/issues/88
        config = function()
            require('goto-preview').setup {
                width = 120, -- Width of the floating window
                height = 15, -- Height of the floating window
                border = { "↖", "─", "┐", "│", "┘", "─", "└", "│" }, -- Border characters of the floating window
                default_mappings = false, -- Bind default mappings
                debug = false, -- Print debug information
                opacity = nil, -- 0-100 opacity level of the floating window where 100 is fully transparent.
                resizing_mappings = false, -- Binds arrow keys to resizing the floating window.
                post_open_hook = nil, -- A function taking two arguments, a buffer and a window to be ran as a hook.
                post_close_hook = nil, -- A function taking two arguments, a buffer and a window to be ran as a hook.
                references = { -- Configure the telescope UI for slowing the references cycling window.
                    provider = "telescope", -- telescope|fzf_lua|snacks|mini_pick|default
                    telescope = require("telescope.themes").get_dropdown({ hide_preview = false })
                },
                -- These two configs can also be passed down to the goto-preview definition and implementation calls for one off "peak" functionality.
                focus_on_open = true,                                        -- Focus the floating window when opening it.
                dismiss_on_move = false,                                     -- Dismiss the floating window when moving the cursor.
                force_close = true,                                          -- passed into vim.api.nvim_win_close's second argument. See :h nvim_win_close
                bufhidden = "wipe",                                          -- the bufhidden option to set on the floating window. See :h bufhidden
                stack_floating_preview_windows = true,                       -- Whether to nest floating windows
                same_file_float_preview = true,                              -- Whether to open a new floating window for a reference within the current file
                preview_window_title = { enable = true, position = "left" }, -- Whether to set the preview window title as the filename
                zindex = 1,                                                  -- Starting zindex for the stack of floating windows
                vim_ui_input = true,                                         -- Whether to override vim.ui.input with a goto-preview floating window

            }
        end
    },


    {
        'cocopon/iceberg.vim',
        config = function()
            vim.cmd("colorscheme iceberg")
        end
    },


    {
        'sainnhe/gruvbox-material',
        config = function()
            -- vim.cmd("colorscheme gruvbox-material")
        end
    },

    {
        'nathanaelkane/vim-indent-guides',
        config = function()

        end
    },

    { 'luochen1990/rainbow' },

    {
        "ray-x/lsp_signature.nvim",
        event = "InsertEnter",
        opts = {
            -- cfg options
        },
    }



    -- END PLUGINS
})

-- -------------------- MAKE / QUICKFIX --------------------
vim.api.nvim_create_user_command('Make', function()
    vim.cmd('write')
    local file = vim.fn.expand '%:t'
    local base = vim.fn.expand '%:r'
    local cmd

    if file:match '%.c$' then
        cmd = string.format('gcc -Wall -Wextra -Wpedantic -std=c17 -g -O0 %s -o %s', file, base)
    elseif file:match '%.cpp$' then
        cmd = string.format('g++ -Wall -Wextra -Wpedantic -std=c++20 -g -O0 %s -o %s', file, base)
    elseif file:match '%.s$' or file:match '%.asm$' then
        cmd = string.format('nasm -felf64 -g -F dwarf %s -o %s.o && ld %s.o -o %s', file, base, base, base)
    else
        if vim.fn.filereadable('Makefile') == 1 or vim.fn.filereadable('makefile') == 1 then
            cmd = 'make'
        else
            vim.notify('No compilation rule for this file type', vim.log.levels.ERROR)
            return
        end
    end

    vim.cmd('set makeprg=' .. vim.fn.escape(cmd, ' '))
    vim.cmd 'make'
    vim.cmd 'copen'
end, { nargs = 0 })

-- Run compiled binary
vim.api.nvim_create_user_command('Run', function()
    local base = vim.fn.expand '%:r'
    if vim.fn.executable(base) == 1 then
        vim.cmd('split | terminal ./' .. base)
    else
        vim.notify('No executable found. Compile first with :Make', vim.log.levels.ERROR)
    end
end, {})

-- Clean build artifacts
vim.api.nvim_create_user_command('Clean', function()
    local base = vim.fn.expand '%:r'
    vim.fn.delete(base)
    vim.fn.delete(base .. '.o')
    vim.notify('Cleaned build artifacts', vim.log.levels.INFO)
end, {})

-- -------------------- KEYMAPS --------------------
vim.keymap.set('n', '<leader>m', ':Make<CR>', { desc = 'Compile' })
vim.keymap.set('n', '<leader>r', ':Run<CR>', { desc = 'Run executable' })
vim.keymap.set('n', '<leader>x', ':Clean<CR>', { desc = 'Clean build' })

-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Go to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Go to lower window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Go to upper window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Go to right window' })

-- Resize with arrows
vim.keymap.set('n', '<C-Up>', ':resize +2<CR>', { desc = 'Increase window height' })
vim.keymap.set('n', '<C-Down>', ':resize -2<CR>', { desc = 'Decrease window height' })
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', { desc = 'Decrease window width' })
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', { desc = 'Increase window width' })

-- Buffer navigation
vim.keymap.set('n', '<S-l>', ':bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<S-h>', ':bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { desc = 'Close buffer' })

-- Quickfix navigation
vim.keymap.set('n', ']q', ':cnext<CR>', { desc = 'Next quickfix item' })
vim.keymap.set('n', '[q', ':cprev<CR>', { desc = 'Previous quickfix item' })
vim.keymap.set('n', '<leader>q', ':copen<CR>', { desc = 'Open quickfix' })
vim.keymap.set('n', '<leader>Q', ':cclose<CR>', { desc = 'Close quickfix' })

-- Better visual indenting
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right' })

-- Move text up and down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move line down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move line up' })

-- Keep cursor centered
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')


vim.keymap.set("n", "<Esc>", "<cmd>noh<CR>")
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")

-- Terminal mode escape
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- -------------------- LSP ON-ATTACH --------------------
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('LspKeymaps', {}),
    callback = function(args)
        local buf = args.buf
        local opts = function(desc)
            return { buffer = buf, desc = desc }
        end

        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts('Goto definition'))
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts('Goto declaration'))
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts('Goto implementation'))
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts('References'))
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts('Hover'))
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts('Signature help'))
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts('Rename'))
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts('Code action'))
        vim.keymap.set('n', '<leader>cf', function() vim.lsp.buf.format { async = true } end, opts('Format'))
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts('Previous diagnostic'))
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts('Next diagnostic'))
        vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float, opts('Line diagnostics'))
    end,
})

-- -------------------- AUTOCOMMANDS --------------------
-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank { timeout = 200 }
    end,
})

-- Assembly file type detection
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    pattern = { '*.asm', '*.s', '*.S' },
    callback = function()
        vim.bo.filetype = 'asm'
        vim.bo.commentstring = '; %s'
    end,
})

-- Auto-format C/C++ on save (optional - comment out if not desired)
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = { '*.c', '*.h', '*.cpp', '*.hpp' },
    callback = function()
        vim.lsp.buf.format { async = false }
    end,
})



-- vim.cmd.colorscheme("kanagawa")
-- vim.cmd.colorscheme("onedark")
