-- ~/.config/nvim/init.lua

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic settings for performance and usability
vim.opt.number = true          -- Show line numbers
vim.opt.relativenumber = true  -- Relative line numbers
vim.opt.tabstop = 4            -- 4 spaces for tabs
vim.opt.shiftwidth = 4         -- 4 spaces for indentation
vim.opt.expandtab = true       -- Convert tabs to spaces
vim.opt.smartindent = true     -- Auto-indent new lines
vim.opt.wrap = false           -- Disable line wrap
vim.opt.termguicolors = true   -- Enable 24-bit RGB colors
vim.opt.updatetime = 250       -- Faster completion (ms)
vim.opt.signcolumn = "yes"     -- Always show sign column
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.cursorline = true      -- Highlight current line
vim.opt.scrolloff = 8          -- Keep 8 lines visible above/below cursor
vim.opt.timeoutlen = 300       -- Faster keybinding timeout

-- Embedded Bash script to check and install dependencies
local bash_script = [[
#!/bin/bash
set -euo pipefail

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install dependencies on Debian/Ubuntu
install_dependencies() {
    echo "Updating package index..."
    sudo apt update
    echo "Installing dependencies..."
    sudo apt install -y nodejs npm clangd neovim
    npm install -g pyright
    npm install -g @fsouza/prettierd  # For formatting
    echo "Dependencies installed successfully."
}

# Check for dependencies
missing_deps=0
for cmd in node npm clangd nvim pyright prettierd; do
    if ! command_exists "$cmd"; then
        echo "$cmd is not installed."
        missing_deps=1
    fi
done

if [ $missing_deps -eq 1 ]; then
    echo "Some dependencies are missing. Attempting to install..."
    install_dependencies
else
    echo "All dependencies are present."
fi
]]

-- Execute the Bash script during initialization
local function execute_bash_script()
    local temp_file = "/tmp/nvim_setup_deps.sh"
    local file = io.open(temp_file, "w")
    if file then
        file:write(bash_script)
        file:close()
        vim.fn.system("chmod +x " .. temp_file)
        local output = vim.fn.system(temp_file)
        vim.api.nvim_echo({{output, "Normal"}}, true, {})
        vim.fn.system("rm " .. temp_file)
    else
        vim.api.nvim_echo({{"Failed to write temporary script file", "ErrorMsg"}}, true, {})
    end
end

-- Check and run script if dependencies are missing
local function check_and_run_script()
    local deps = {"node", "npm", "clangd", "nvim", "pyright", "prettierd"}
    local missing = false
    for _, cmd in ipairs(deps) do
        if vim.fn.executable(cmd) == 0 then
            missing = true
            break
        end
    end
    if missing then
        vim.api.nvim_echo({{"Checking and installing dependencies...", "WarningMsg"}}, true, {})
        execute_bash_script()
    end
end

-- Run dependency check on startup
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        check_and_run_script()
    end,
    once = true,
})

-- Install lazy.nvim (plugin manager)
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

-- Define plugins
require("lazy").setup({
    -- File explorer
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                view = { width = 30, side = "left" },
                filters = { dotfiles = false },
                git = { enable = true, ignore = false },
            })
            vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
            vim.keymap.set("n", "<leader>f", ":NvimTreeFindFile<CR>", { silent = true })
        end,
    },

    -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
        config = function()
            local telescope = require("telescope")
            telescope.setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-j>"] = "move_selection_next",
                            ["<C-k>"] = "move_selection_previous",
                        },
                    },
                },
                extensions = {
                    fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true },
                },
            })
            telescope.load_extension("fzf")
            vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { silent = true })
            vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { silent = true })
            vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", { silent = true })
            vim.keymap.set("n", "<leader>fs", ":Telescope lsp_document_symbols<CR>", { silent = true })
        end,
    },

    -- Git integration
    {
        "tpope/vim-fugitive",
        config = function()
            vim.keymap.set("n", "<leader>gs", ":Git<CR>", { silent = true }) -- Git status
            vim.keymap.set("n", "<leader>gc", ":Git commit<CR>", { silent = true }) -- Git commit
            vim.keymap.set("n", "<leader>gp", ":Git push<CR>", { silent = true }) -- Git push
        end,
    },

    -- Git signs
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                signs = {
                    add = { text = "+" },
                    change = { text = "~" },
                    delete = { text = "_" },
                },
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns
                    vim.keymap.set("n", "<leader>hn", gs.next_hunk, { buffer = bufnr, desc = "Next hunk" })
                    vim.keymap.set("n", "<leader>hp", gs.prev_hunk, { buffer = bufnr, desc = "Previous hunk" })
                    vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { buffer = bufnr, desc = "Reset hunk" })
                end,
            })
        end,
    },

    -- Autopairs
    {
        "windwp/nvim-autopairs",
        config = function()
            require("nvim-autopairs").setup({
                check_ts = true, -- Integrate with treesitter
                fast_wrap = { map = "<M-e>" },
            })
            -- Integrate with cmp
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
    },

    -- Commenting
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup({
                toggler = { line = "<leader>cc", block = "<leader>cb" },
                opleader = { line = "<leader>c", block = "<leader>cb" },
            })
        end,
    },

    -- Diagnostics panel
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("trouble").setup({
                position = "bottom",
                height = 10,
                auto_open = false,
                auto_close = true,
            })
            vim.keymap.set("n", "<leader>xx", ":TroubleToggle document_diagnostics<CR>", { silent = true })
            vim.keymap.set("n", "<leader>xw", ":TroubleToggle workspace_diagnostics<CR>", { silent = true })
        end,
    },

    -- Keybinding hints
    {
        "folke/which-key.nvim",
        config = function()
            require("which-key").setup({
                plugins = { marks = true, registers = true, spelling = { enabled = true } },
                window = { border = "single", margin = { 1, 0, 1, 0 } },
            })
            require("which-key").register({
                ["<leader>"] = {
                    f = { name = "File" },
                    g = { name = "Git" },
                    c = { name = "Code" },
                    x = { name = "Diagnostics" },
                },
            })
        end,
    },

    -- Editorconfig support
    { "gpanders/editorconfig.nvim" },

    -- LSP configuration
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require("lspconfig")

            -- Pyright for Python (Rust-based)
            lspconfig.pyright.setup({
                settings = {
                    python = {
                        analysis = {
                            typeCheckingMode = "basic",
                            diagnosticMode = "workspace",
                        },
                    },
                },
            })

            -- Clangd for C++
            lspconfig.clangd.setup({
                cmd = { "clangd", "--background-index", "--clang-tidy" },
            })

            -- Formatting with prettierd (for C++ and other files)
            lspconfig.pretterd.setup({
                filetypes = { "cpp", "c", "javascript", "typescript" },
            })

            -- Keybindings for LSP
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                    vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float, opts)
                    vim.keymap.set("n", "<leader>fm", vim.lsp.buf.format, opts)
                end,
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
            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping.select_next_item(),
                    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp", priority = 1000 },
                    { name = "luasnip", priority = 750 },
                    { name = "buffer", priority = 500 },
                    { name = "path", priority = 250 },
                }),
                formatting = {
                    format = function(entry, vim_item)
                        vim_item.menu = ({
                            nvim_lsp = "[LSP]",
                            luasnip = "[Snippet]",
                            buffer = "[Buffer]",
                            path = "[Path]",
                        })[entry.source.name]
                        return vim_item
                    end,
                },
            })

            -- Command-line completion
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = "path" },
                    { name = "cmdline" },
                },
            })

            -- Load friendly-snippets
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    },

    -- Syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "python", "cpp", "lua", "vim", "vimdoc", "query" },
                highlight = { enable = true },
                indent = { enable = true },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<C-space>",
                        node_incremental = "<C-space>",
                        scope_incremental = "<C-s>",
                        node_decremental = "<C-d>",
                    },
                },
            })
        end,
    },

    -- Status line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = { theme = "dracula" },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", { "diagnostics", sources = { "nvim_lsp" } } },
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            })
        end,
    },

    -- Theme
    {
        "dracula/vim",
        config = function()
            vim.cmd("colorscheme dracula")
        end,
    },
}, {
    performance = {
        rtp = {
            disabled_plugins = { "netrw", "netrwPlugin" },
        },
    },
})

-- General keybindings
vim.keymap.set("n", "<leader>w", ":w<CR>", { silent = true, desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { silent = true, desc = "Quit" })
vim.keymap.set("n", "<leader>bd", ":bd<CR>", { silent = true, desc = "Close buffer" })
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprev<CR>", { silent = true, desc = "Previous buffer" })
