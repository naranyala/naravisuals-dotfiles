-- Neovim Configuration for C Programming

-- General Settings
vim.opt.number = true             -- Enable line numbers
vim.opt.relativenumber = true     -- Enable relative line numbers
vim.opt.tabstop = 4               -- Number of spaces tabs count for
vim.opt.shiftwidth = 4            -- Size of an indent
vim.opt.expandtab = true          -- Use spaces instead of tabs
vim.opt.autoindent = true         -- Auto-indent new lines
vim.opt.smartindent = true        -- Smart auto-indenting
vim.opt.ignorecase = true         -- Ignore case in search patterns
vim.opt.smartcase = true          -- Override 'ignorecase' if search pattern contains uppercase characters
vim.opt.termguicolors = true      -- Enable 24-bit RGB colors
vim.opt.signcolumn = "yes"        -- Always show sign column
vim.opt.updatetime = 250          -- Faster completion
vim.opt.timeoutlen = 300          -- Timeout for mapped sequences
vim.opt.clipboard = "unnamedplus" -- Use system clipboard

-- Leader key setup
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Key Mappings

-- Compile and run C code
vim.api.nvim_set_keymap('n', '<leader>cc', '<cmd>lua CompileAndRun()<CR>', { noremap = true, silent = true })

-- Format C code
vim.api.nvim_set_keymap('n', '<leader>cf', '<cmd>lua FormatCode()<CR>', { noremap = true, silent = true })

-- View man page for current word
vim.api.nvim_set_keymap('n', '<leader>ch', '<cmd>lua ViewManPage()<CR>', { noremap = true, silent = true })

-- Debug C code with gdb
vim.api.nvim_set_keymap('n', '<leader>cs', '<cmd>lua DebugWithGdb()<CR>', { noremap = true, silent = true })

-- Custom Functions
function CompileAndRun()
    local filename = vim.fn.expand('%:r')
    local command = 'gcc % -o ' .. filename .. ' && ./' .. filename
    vim.cmd('!clear && ' .. command)
end

function FormatCode()
    vim.cmd('!clang-format -i %')
    vim.cmd('e') -- reload the file after formatting
end

function ViewManPage()
    local function_name = vim.fn.expand('<cword>')
    if function_name ~= '' then
        vim.cmd('!man ' .. function_name)
    else
        print("No word under cursor")
    end
end

function DebugWithGdb()
    local filename = vim.fn.expand('%:r')
    local executable = filename
    vim.cmd('!gdb ./' .. executable)
end

function CreateHeaderFile()
    local filename = vim.fn.expand('%:r')
    local header_filename = filename .. '.h'
    if vim.fn.filereadable(header_filename) == 0 then
        local header_content = [[
#ifndef ]] .. string.upper(filename) .. [[_H
#define ]] .. string.upper(filename) .. [[_H

// Add your function declarations here

#endif /* ]] .. string.upper(filename) .. [[_H */
]]
        local file = io.open(header_filename, "w")
        if file then
            file:write(header_content)
            file:close()
            print("Header file created: " .. header_filename)
        else
            print("Could not create header file: " .. header_filename)
        end
    else
        print("Header file already exists: " .. header_filename)
    end
end

function CreateMakefile()
    local filename = vim.fn.expand('%:t:r') -- Get filename without extension
    local makefile_content = [[
CC=gcc
CFLAGS=-Wall -Wextra -g
TARGET=]] .. filename .. [[

all: $(TARGET)

$(TARGET): %.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f $(TARGET)

install:
	sudo cp $(TARGET) /usr/local/bin/

.PHONY: all clean install
]]
    local file = io.open("Makefile", "w")
    if file then
        file:write(makefile_content)
        file:close()
        print("Makefile created successfully")
    else
        print("Could not create Makefile")
    end
end

function SearchFunctionDefinition()
    local function_name = vim.fn.expand('<cword>')
    if function_name ~= '' then
        vim.cmd('!grep -rn "' .. function_name .. '" . --exclude-dir=.git')
    else
        print("No word under cursor")
    end
end

-- Keybindings for custom functions
vim.api.nvim_set_keymap('n', '<leader>cr', '<cmd>lua CompileAndRun()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>lua FormatCode()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>hm', '<cmd>lua ViewManPage()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>dg', '<cmd>lua DebugWithGdb()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ch', '<cmd>lua CreateHeaderFile()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>mk', '<cmd>lua CreateMakefile()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fd', '<cmd>lua SearchFunctionDefinition()<CR>', { noremap = true, silent = true })

-- Lazy.nvim Configuration
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--single-branch",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "clangd" },
            })
            require("lspconfig").clangd.setup({
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "c", "cpp", "bash" },
                highlight = {
                    enable = true,
                },
                indent = { enable = true },
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
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
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
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                }, {
                    { name = 'buffer' },
                })
            })
        end,
    },
    -- {
    --     "nvim-tree/nvim-tree.lua",
    --     dependencies = {
    --         -- "nvim-tree/nvim-web-devicons",
    --     },
    --     config = function()
    --         require("nvim-tree").setup({
    --             view = {
    --                 width = 30,
    --             },
    --             renderer = {
    --                 group_empty = true,
    --             },
    --             filters = {
    --                 dotfiles = false,
    --             },
    --         })
    --     end,
    -- },
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
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup({
                window = { border = "rounded" },
            })
        end,
    },


    -- END OF PLUGINS
})

-- Autocommands
-- Set C-specific settings
vim.api.nvim_create_autocmd("FileType", {
    pattern = "c",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.softtabstop = 4
        vim.opt_local.cindent = true
    end,
})

-- Auto format on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.c,*.h",
    callback = function()
        vim.lsp.buf.format()
    end,
})
