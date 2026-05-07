--------------------------------------------------------------------------------
-- OPTIONS
--------------------------------------------------------------------------------
local o, g = vim.opt, vim.g

o.number, o.relativenumber = true, true
o.tabstop, o.shiftwidth, o.expandtab = 4, 4, true
o.smartindent = true
o.wrap, o.linebreak = false, true
o.ignorecase, o.smartcase = true, true
o.incsearch, o.hlsearch = true, true
o.splitbelow, o.splitright = true, true
o.termguicolors = true
o.signcolumn = "yes"
o.scrolloff, o.sidescrolloff = 8, 8
o.undofile = true
o.updatetime = 250
o.timeoutlen = 350
o.clipboard = "unnamedplus"
o.mouse = "a"
o.showmode = false
o.laststatus = 2
o.cursorline = true
o.virtualedit = "block"
o.inccommand = "split"
o.grepprg = "rg --vimgrep --smart-case"
o.grepformat = "%f:%l:%c:%m"
o.completeopt = "menu,menuone,noselect,preview"
-- o.shortmess:append("cI")
o.fillchars = { eob = " ", vert = "│", fold = " " }
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldlevel = 99
o.smoothscroll = true -- nvim 0.10+

g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
g.loaded_node_provider = 0

--------------------------------------------------------------------------------
-- STATUSLINE
--------------------------------------------------------------------------------
function Statusline()
    local modes = {
        n = "NOR",
        i = "INS",
        v = "VIS",
        V = "V·L",
        [""] = "V·B",
        c = "CMD",
        R = "REP",
        t = "TER",
        s = "SEL",
        S = "S·L",
    }
    local m = modes[vim.fn.mode()] or vim.fn.mode()
    local git = vim.b.gitsigns_head and (" " .. vim.b.gitsigns_head) or ""
    local diag = ""
    local d = vim.diagnostic.count(0)
    if d[1] then diag = diag .. " E" .. d[1] end
    if d[2] then diag = diag .. " W" .. d[2] end
    return " " .. m .. " │ %f %m%r" .. git .. diag .. "%=  %y │ %l:%c "
end

vim.o.statusline = "%!v:lua.Statusline()"

--------------------------------------------------------------------------------
-- KEYMAPS (core)
--------------------------------------------------------------------------------
g.mapleader, g.maplocalleader = " ", " "
local map = vim.keymap.set

map("n", "<leader>w", "<cmd>w<CR>")
map("n", "<leader>q", "<cmd>q<CR>")
map("n", "<leader>Q", "<cmd>qa!<CR>")

map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
map("n", "<C-Up>", "<cmd>resize +2<CR>")
map("n", "<C-Down>", "<cmd>resize -2<CR>")
map("n", "<C-Left>", "<cmd>vert resize -2<CR>")
map("n", "<C-Right>", "<cmd>vert resize +2<CR>")

map("n", "<S-l>", "<cmd>bnext<CR>")
map("n", "<S-h>", "<cmd>bprev<CR>")
map("n", "<leader>x", "<cmd>bd<CR>")

map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "J", "mzJ`z")

map("x", "<leader>p", '"_dP')
map({ "n", "v" }, "<leader>y", '"+y')
map({ "n", "v" }, "<leader>d", '"_d')
map("v", "<", "<gv")
map("v", ">", ">gv")

map("n", "]q", "<cmd>cnext<CR>zz")
map("n", "[q", "<cmd>cprev<CR>zz")
map("n", "]d", vim.diagnostic.goto_next)
map("n", "[d", vim.diagnostic.goto_prev)


map("n", "<Esc>", "<cmd>noh<CR>")
map("i", "jk", "<Esc>")
map("t", "<Esc><Esc>", "<C-\\><C-n>")

--------------------------------------------------------------------------------
-- OPTION A: COMPLETION
-- Choose ONE approach, comment out the other
--------------------------------------------------------------------------------

-- A1: NATIVE COMPLETION (0 plugins, surprisingly good)
-- Uses omnifunc (LSP) + buffer + path completion
local function native_completion()
    map("i", "<C-Space>", function()
        if vim.fn.pumvisible() == 1 then return end
        local col = vim.fn.col(".") - 1
        if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
            return "<Tab>"
        end
        return "<C-x><C-o>" -- omnifunc (LSP)
    end, { expr = true })

    map("i", "<Tab>", function()
        return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
    end, { expr = true })

    map("i", "<S-Tab>", function()
        return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
    end, { expr = true })

    map("i", "<CR>", function()
        return vim.fn.pumvisible() == 1 and "<C-y>" or "<CR>"
    end, { expr = true })

    -- useful native completion keys:
    -- <C-x><C-o>  omni (LSP)
    -- <C-x><C-n>  buffer keywords
    -- <C-x><C-f>  file paths
    -- <C-x><C-l>  whole lines
    -- <C-n>       generic keyword
end
native_completion()

-- A2: NVIM-CMP (add to plugins section if you want richer completion)
-- See plugins section below for the minimal cmp setup

--------------------------------------------------------------------------------
-- OPTION B: FILE EXPLORER
-- Choose your style
--------------------------------------------------------------------------------

-- B1: NETRW (built-in, minimal)
g.netrw_banner = 0
g.netrw_liststyle = 3
g.netrw_winsize = 25
map("n", "-", "<cmd>Ex<CR>")
map("n", "<leader>e", "<cmd>Ex<CR>")

-- B2: OIL.NVIM - edit filesystem like a buffer (add to plugins if preferred)
-- Superior to netrw, still minimal philosophy
-- See plugins section

--------------------------------------------------------------------------------
-- OPTION C: COLORSCHEMES (all minimal, well-maintained)
--------------------------------------------------------------------------------
-- Pick ONE in plugins section:
-- "rebelot/kanagawa.nvim"      -- warm, low contrast, great for long sessions
-- "rose-pine/neovim"           -- elegant, soft colors
-- "sainnhe/gruvbox-material"   -- classic gruvbox, softer
-- "folke/tokyonight.nvim"      -- modern, many variants
-- "EdenEast/nightfox.nvim"     -- well-balanced, many variants
-- "zenbones-theme/zenbones.nvim" -- paper-like, easy on eyes
-- "mcchrish/zenbones.nvim"     -- minimal bone-white theme
-- "nyoom-engineering/oxocarbon.nvim" -- IBM carbon design

--------------------------------------------------------------------------------
-- OPTION E: HARDMODE (force better vim habits)
--------------------------------------------------------------------------------
local hardmode = false -- set true to enable

if hardmode then
    -- disable arrow keys
    map({ "n", "i", "v" }, "<Up>", "<Nop>")
    map({ "n", "i", "v" }, "<Down>", "<Nop>")
    map({ "n", "i", "v" }, "<Left>", "<Nop>")
    map({ "n", "i", "v" }, "<Right>", "<Nop>")

    -- disable mouse
    o.mouse = ""

    -- warn on repeated hjkl
    local last_key, repeat_count = "", 0
    for _, key in ipairs({ "h", "j", "k", "l" }) do
        map("n", key, function()
            if last_key == key then
                repeat_count = repeat_count + 1
                if repeat_count > 5 then
                    vim.notify("Use w/b/f/t/{}!", vim.log.levels.WARN)
                end
            else
                last_key, repeat_count = key, 1
            end
            return key
        end, { expr = true })
    end
end

--------------------------------------------------------------------------------
-- OPTION F: ZEN MODE (no plugin, just toggle distractions)
--------------------------------------------------------------------------------
local zen_active = false
map("n", "<leader>z", function()
    zen_active = not zen_active
    if zen_active then
        vim.opt.number = false
        vim.opt.relativenumber = false
        vim.opt.signcolumn = "no"
        vim.opt.laststatus = 0
        vim.opt.cmdheight = 0
        vim.opt.showtabline = 0
        vim.cmd("highlight Normal guibg=#1a1a1a")
        vim.notify("Zen ON")
    else
        vim.opt.number = true
        vim.opt.relativenumber = true
        vim.opt.signcolumn = "yes"
        vim.opt.laststatus = 2
        vim.opt.cmdheight = 1
        vim.opt.showtabline = 1
        vim.cmd("colorscheme kanagawa") -- restore
        vim.notify("Zen OFF")
    end
end, { desc = "Zen mode" })

--------------------------------------------------------------------------------
-- OPTION G: SESSION MANAGEMENT (no plugin)
--------------------------------------------------------------------------------
local session_dir = vim.fn.stdpath("data") .. "/sessions/"
vim.fn.mkdir(session_dir, "p")

local function session_name()
    local cwd = vim.fn.getcwd()
    return session_dir .. cwd:gsub("/", "%%") .. ".vim"
end

map("n", "<leader>ss", function()
    vim.cmd("mksession! " .. session_name())
    vim.notify("Session saved")
end, { desc = "Save session" })

map("n", "<leader>sl", function()
    local f = session_name()
    if vim.fn.filereadable(f) == 1 then
        vim.cmd("source " .. f)
        vim.notify("Session loaded")
    else
        vim.notify("No session for this dir", vim.log.levels.WARN)
    end
end, { desc = "Load session" })

--------------------------------------------------------------------------------
-- OPTION H: BETTER QUICKFIX (no plugin)
--------------------------------------------------------------------------------
local function quickfix_toggle()
    local qf_exists = false
    for _, win in pairs(vim.fn.getwininfo()) do
        if win.quickfix == 1 then qf_exists = true end
    end
    if qf_exists then
        vim.cmd("cclose")
    else
        vim.cmd("copen")
    end
end
map("n", "<leader>qf", quickfix_toggle, { desc = "Toggle quickfix" })

-- auto-open quickfix after grep
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    pattern = { "[^l]*" },
    callback = function() vim.cmd("copen") end,
})

--------------------------------------------------------------------------------
-- CUSTOM FUNCTIONS
--------------------------------------------------------------------------------
local function toggle(opt, on, off)
    return function()
        vim.opt[opt] = vim.opt[opt]:get() == on and off or on
        vim.notify(opt .. " = " .. tostring(vim.opt[opt]:get()))
    end
end

map("n", "<leader>tw", toggle("wrap", true, false))
map("n", "<leader>tn", toggle("number", true, false))
map("n", "<leader>ts", toggle("spell", true, false))

map("n", "dd", function()
    return vim.fn.getline("."):match("^%s*$") and '"_dd' or "dd"
end, { expr = true })

local runners = {
    lua = "luafile %",
    python = "!python3 %",
    sh = "!bash %",
    javascript = "!node %",
    typescript = "!npx ts-node %",
    go = "!go run %",
    rust = "!cargo run",
    c = "!gcc % -o /tmp/a.out && /tmp/a.out",
}
map("n", "<leader>R", function()
    local ft = vim.bo.filetype
    if runners[ft] then
        vim.cmd("w"); vim.cmd(runners[ft])
    else
        vim.notify("No runner: " .. ft, vim.log.levels.WARN)
    end
end, { desc = "Run file" })

map("n", "<leader>T", function()
    vim.cmd("split | resize 12 | terminal")
    vim.cmd("startinsert")
end, { desc = "Terminal" })

map("n", "<leader>*", function()
    vim.cmd("silent grep! " .. vim.fn.expand("<cword>"))
    vim.cmd("copen")
end, { desc = "Grep word" })

map("n", "<leader>sr", function()
    local w = vim.fn.expand("<cword>")
    vim.api.nvim_feedkeys(":%s/\\<" .. w .. "\\>//gcI<Left><Left><Left><Left>", "n", false)
end, { desc = "Replace word" })

--------------------------------------------------------------------------------
-- AUTOCOMMANDS
--------------------------------------------------------------------------------
local aug = vim.api.nvim_create_augroup("Suckless", { clear = true })
local au = function(ev, opts)
    opts.group = aug
    vim.api.nvim_create_autocmd(ev, opts)
end

au("TextYankPost", { callback = function() vim.highlight.on_yank({ timeout = 150 }) end })

au("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- au("BufWritePre", {
--     callback = function(e)
--         if vim.bo.filetype == "markdown" then return end
--         local pos = vim.api.nvim_win_get_cursor(0)
--         vim.cmd([[%s/\s\+$//e]])
--         pcall(vim.api.nvim_win_set_cursor, 0, pos)
--         local dir = vim.fn.fnamemodify(e.file, ":p:h")
--         if vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, "p") end
--     end,
-- })

au("VimResized", { callback = function() vim.cmd("wincmd =") end })

au("FileType", {
    pattern = { "help", "qf", "man", "lspinfo", "checkhealth", "gitcommit" },
    callback = function() map("n", "q", "<cmd>close<CR>", { buffer = true }) end,
})

au("TermOpen", {
    callback = function()
        vim.opt_local.number, vim.opt_local.relativenumber = false, false
        vim.opt_local.signcolumn = "no"
    end,
})

--------------------------------------------------------------------------------
-- LAZY.NVIM
--------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------------------------------
-- PLUGINS
--------------------------------------------------------------------------------
require("lazy").setup({

    require("./_shared_other_modules"),
    require("./_shared_mason_lsp_treesitter"),


    -- COLORSCHEME (pick one)
    {
        "rebelot/kanagawa.nvim",
        priority = 1000,
        config = function() vim.cmd.colorscheme("kanagawa") end
    },
    -- { "rose-pine/neovim", name = "rose-pine", priority = 1000,
    --     config = function() vim.cmd.colorscheme("rose-pine") end },

    -- FUZZY FINDER
    {
        "ibhagwan/fzf-lua",
        keys = {
            { "<leader>f", "<cmd>FzfLua files<CR>" },
            { "<leader>g", "<cmd>FzfLua live_grep<CR>" },
            { "<leader>b", "<cmd>FzfLua buffers<CR>" },
            { "<leader>/", "<cmd>FzfLua grep_curbuf<CR>" },
            { "<leader>o", "<cmd>FzfLua oldfiles<CR>" },
            { "<leader>h", "<cmd>FzfLua help_tags<CR>" },
            { "<leader>:", "<cmd>FzfLua command_history<CR>" },
            { "gd",        "<cmd>FzfLua lsp_definitions<CR>" },
            { "gr",        "<cmd>FzfLua lsp_references<CR>" },
            { "gs",        "<cmd>FzfLua lsp_document_symbols<CR>" },
        },
        config = function()
            require("fzf-lua").setup({ "fzf-native", winopts = { height = 0.85, width = 0.85 } })
        end,
    },

    -- TREESITTER
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = "BufReadPost",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "lua", "vim", "vimdoc", "c", "python", "bash", "markdown", "json", "yaml", "typescript" },
                highlight = { enable = true },
                indent = { enable = true },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<CR>",
                        node_incremental = "<CR>",
                        node_decremental = "<BS>",
                    },
                },
            })
        end,
    },

    -- LSP
    -- { "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" },
    --     config = function()
    --         local lsp = require("lspconfig")
    --         -- UNCOMMENT SERVERS YOU NEED:
    --         -- lsp.lua_ls.setup({})
    --         -- lsp.pyright.setup({})
    --         -- lsp.clangd.setup({})
    --         -- lsp.gopls.setup({})
    --         -- lsp.rust_analyzer.setup({})
    --         -- lsp.tsserver.setup({})
    --
    --         vim.api.nvim_create_autocmd("LspAttach", {
    --             callback = function(e)
    --                 local b = { buffer = e.buf }
    --                 map("n", "K", vim.lsp.buf.hover, b)
    --                 map("n", "<leader>r", vim.lsp.buf.rename, b)
    --                 map("n", "<leader>a", vim.lsp.buf.code_action, b)
    --                 map("n", "<leader>ld", vim.diagnostic.open_float, b)
    --                 map("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, b)
    --             end,
    --         })
    --
    --         vim.diagnostic.config({
    --             virtual_text = { prefix = "●", spacing = 2 },
    --             signs = { text = { [1] = "E", [2] = "W", [3] = "I", [4] = "H" } },
    --             float = { border = "rounded" },
    --         })
    --     end,
    -- },
    --
    -- GIT
    {
        "lewis6991/gitsigns.nvim",
        event = "BufReadPre",
        opts = {
            on_attach = function(buf)
                local gs = require("gitsigns")
                map("n", "]h", gs.next_hunk, { buffer = buf })
                map("n", "[h", gs.prev_hunk, { buffer = buf })
                map("n", "<leader>hs", gs.stage_hunk, { buffer = buf })
                map("n", "<leader>hr", gs.reset_hunk, { buffer = buf })
                map("n", "<leader>hp", gs.preview_hunk, { buffer = buf })
                map("n", "<leader>hb", gs.blame_line, { buffer = buf })
            end,
        },
    },

    {
        "stevearc/oil.nvim",
        keys = { { "-", "<cmd>oil<cr>" } },
        opts = { view_options = { show_hidden = true } }
    },

    {
        "hrsh7th/nvim-cmp",
        event = "insertenter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
        },
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ["<c-space>"] = cmp.mapping.complete(),
                    ["<cr>"] = cmp.mapping.confirm({ select = true }),
                    ["<tab>"] = cmp.mapping.select_next_item(),
                    ["<s-tab>"] = cmp.mapping.select_prev_item(),
                }),
                sources = {
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "path" },
                },
            })
        end,
    },


    -- QUALITY OF LIFE: Better commenting
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
            vim.keymap.set("n", "<leader>/", "<cmd>lua require('Comment.api').toggle.linewise.current()<cr>",
                { desc = "Toggle comment" })
            vim.keymap.set("v", "<leader>/",
                "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
                { desc = "Toggle comment" })
        end
    },

    -- { "echasnovski/mini.nvim", config = function()
    --     require("mini.pairs").setup()      -- autopairs
    --     require("mini.surround").setup()   -- surround (replaces vim-surround)
    --     require("mini.comment").setup()    -- comments (replaces vim-commentary)
    --     require("mini.ai").setup()         -- better text objects
    --     require("mini.files").setup()      -- file explorer
    -- end },

    -- TPOPE ESSENTIALS (or use mini.nvim above)
    { "tpope/vim-commentary",  keys = { "gc", { "gc", mode = "v" } } },
    { "tpope/vim-surround",    event = "VeryLazy" },
    { "tpope/vim-repeat",      event = "VeryLazy" },

    -- AUTOPAIRS
    { "windwp/nvim-autopairs", event = "InsertEnter",                config = true },

}, {
    performance = {
        rtp = { disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
    },
    ui = { border = "rounded" },
})



-- Auto format on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.c,*.h",
    callback = function()
        vim.lsp.buf.format()
    end,
})



-- vim.cmd.colorscheme("kanagawa")
vim.cmd.colorscheme("onedark")
