
--------------------------------------------------------------------------------
-- OPTIONS
--------------------------------------------------------------------------------
local o, g = vim.opt, vim.g

o.number, o.relativenumber = true, true
o.tabstop, o.shiftwidth, o.expandtab = 4, 4, true
o.smartindent = true
o.wrap, o.linebreak = false, true       -- wrap off, but linebreak if toggled
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
o.virtualedit = "block"                 -- better visual block mode
o.inccommand = "split"                  -- live preview :s commands
o.grepprg = "rg --vimgrep --smart-case" -- use ripgrep if available
o.grepformat = "%f:%l:%c:%m"
o.completeopt = "menu,menuone,noselect"
o.shortmess:append("cI")                -- less noise
o.fillchars = { eob = " ", vert = "│" }

-- disable unused providers
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
g.loaded_node_provider = 0

--------------------------------------------------------------------------------
-- STATUSLINE (minimal, no plugin)
--------------------------------------------------------------------------------
local function statusline()
    local mode_map = {
        n = "NOR", i = "INS", v = "VIS", V = "V-L", [""] = "V-B",
        c = "CMD", R = "REP", t = "TER",
    }
    local mode = mode_map[vim.fn.mode()] or vim.fn.mode()
    local file = "%f %m%r"
    local git = vim.b.gitsigns_head and ("  " .. vim.b.gitsigns_head) or ""
    local pos = "[%l:%c]"
    local ft = vim.bo.filetype ~= "" and vim.bo.filetype or "none"
    return " " .. mode .. " │ " .. file .. git .. "%=" .. ft .. " │ " .. pos .. " "
end
vim.o.statusline = "%!v:lua.Statusline()"
function Statusline() return statusline() end

--------------------------------------------------------------------------------
-- KEYMAPS
--------------------------------------------------------------------------------
g.mapleader = " "
g.maplocalleader = " "
local map = vim.keymap.set

-- essentials
map("n", "<Esc>", "<cmd>noh<CR>")
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Quit all" })

-- splits (ergonomic)
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
map("n", "<C-Up>", "<cmd>resize +2<CR>")
map("n", "<C-Down>", "<cmd>resize -2<CR>")
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>")
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>")

-- buffers
map("n", "<S-l>", "<cmd>bnext<CR>")
map("n", "<S-h>", "<cmd>bprev<CR>")
map("n", "<leader>x", "<cmd>bd<CR>", { desc = "Close buffer" })
map("n", "<leader>X", "<cmd>%bd|e#|bd#<CR>", { desc = "Close others" })

-- move lines (visual)
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- keep cursor centered
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "J", "mzJ`z")                  -- join without cursor jump

-- better paste/yank
map("x", "<leader>p", '"_dP', { desc = "Paste no yank" })
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system" })
map("n", "<leader>Y", '"+Y', { desc = "Yank line to system" })
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete no yank" })

-- quick fix navigation
map("n", "]q", "<cmd>cnext<CR>zz")
map("n", "[q", "<cmd>cprev<CR>zz")
map("n", "]l", "<cmd>lnext<CR>zz")
map("n", "[l", "<cmd>lprev<CR>zz")

-- ergonomic escapes
map("i", "jk", "<Esc>")
map("i", "kj", "<Esc>")
map("t", "<Esc><Esc>", "<C-\\><C-n>")   -- terminal escape

-- indent and stay in visual
map("v", "<", "<gv")
map("v", ">", ">gv")

-- select all
map("n", "<leader>sa", "ggVG", { desc = "Select all" })

-- add blank lines without entering insert
map("n", "]<Space>", "o<Esc>k", { desc = "Blank line below" })
map("n", "[<Space>", "O<Esc>j", { desc = "Blank line above" })

--------------------------------------------------------------------------------
-- CUSTOM FUNCTIONS (no plugins needed)
--------------------------------------------------------------------------------

-- Toggle options quickly
local function toggle(opt, on, off)
    return function()
        if vim.opt[opt]:get() == on then
            vim.opt[opt] = off
        else
            vim.opt[opt] = on
        end
        vim.notify(opt .. " = " .. tostring(vim.opt[opt]:get()))
    end
end

map("n", "<leader>tw", toggle("wrap", true, false), { desc = "Toggle wrap" })
map("n", "<leader>tn", toggle("number", true, false), { desc = "Toggle number" })
map("n", "<leader>tr", toggle("relativenumber", true, false), { desc = "Toggle relative" })
map("n", "<leader>ts", toggle("spell", true, false), { desc = "Toggle spell" })

-- Smart dd: don't yank empty lines
map("n", "dd", function()
    return vim.fn.getline("."):match("^%s*$") and '"_dd' or "dd"
end, { expr = true })

-- Quick scratch buffer
map("n", "<leader>S", function()
    vim.cmd("enew")
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.swapfile = false
    vim.notify("Scratch buffer")
end, { desc = "Scratch buffer" })

-- Run current file
local runners = {
    lua = "luafile %",
    python = "!python3 %",
    sh = "!bash %",
    javascript = "!node %",
    go = "!go run %",
    rust = "!cargo run",
}
map("n", "<leader>R", function()
    local ft = vim.bo.filetype
    if runners[ft] then
        vim.cmd("w")
        vim.cmd(runners[ft])
    else
        vim.notify("No runner for " .. ft, vim.log.levels.WARN)
    end
end, { desc = "Run file" })

-- Quick terminal (bottom split)
map("n", "<leader>T", function()
    vim.cmd("split | resize 12 | terminal")
    vim.cmd("startinsert")
end, { desc = "Terminal" })

-- Grep word under cursor (uses ripgrep)
map("n", "<leader>*", function()
    local word = vim.fn.expand("<cword>")
    vim.cmd("silent grep! " .. word)
    vim.cmd("copen")
end, { desc = "Grep word" })

-- Find and replace word under cursor
map("n", "<leader>sr", function()
    local word = vim.fn.expand("<cword>")
    vim.api.nvim_feedkeys(":%s/\\<" .. word .. "\\>//gcI<Left><Left><Left><Left>", "n", false)
end, { desc = "Replace word" })

-- Duplicate line or selection
map("n", "<leader>D", "yyp", { desc = "Duplicate line" })
map("v", "<leader>D", "y'>p", { desc = "Duplicate selection" })

-- Close all floating windows (lsp hover, etc)
map("n", "<leader>cf", function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_config(win).relative ~= "" then
            vim.api.nvim_win_close(win, false)
        end
    end
end, { desc = "Close floats" })

-- Sudo write (when you forgot to open with sudo)
map("c", "w!!", "w !sudo tee % >/dev/null", { desc = "Sudo write" })

-- Quick note (append to ~/notes.md)
map("n", "<leader>N", function()
    vim.ui.input({ prompt = "Note: " }, function(note)
        if note and note ~= "" then
            local f = io.open(os.getenv("HOME") .. "/notes.md", "a")
            if f then
                f:write(string.format("- [%s] %s\n", os.date("%Y-%m-%d %H:%M"), note))
                f:close()
                vim.notify("Note saved")
            end
        end
    end)
end, { desc = "Quick note" })

-- Smart buffer close (quit if last buffer)
map("n", "<leader>c", function()
    local bufs = vim.fn.getbufinfo({ buflisted = 1 })
    if #bufs <= 1 then
        vim.cmd("q")
    else
        vim.cmd("bd")
    end
end, { desc = "Smart close" })

--------------------------------------------------------------------------------
-- AUTOCOMMANDS
--------------------------------------------------------------------------------
local au = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup("Suckless", { clear = true })

-- highlight on yank
au("TextYankPost", {
    group = augroup,
    callback = function() vim.highlight.on_yank({ timeout = 150 }) end,
})

-- restore cursor position
au("BufReadPost", {
    group = augroup,
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lines = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lines then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- strip trailing whitespace
au("BufWritePre", {
    group = augroup,
    pattern = "*",
    callback = function()
        if vim.bo.filetype == "markdown" then return end -- preserve in md
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd([[%s/\s\+$//e]])
        pcall(vim.api.nvim_win_set_cursor, 0, pos)
    end,
})

-- auto resize splits on window resize
au("VimResized", {
    group = augroup,
    callback = function() vim.cmd("wincmd =") end,
})

-- close some buffers with q
au("FileType", {
    group = augroup,
    pattern = { "help", "qf", "man", "lspinfo", "checkhealth" },
    callback = function()
        vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, silent = true })
    end,
})

-- auto create parent dirs on save
au("BufWritePre", {
    group = augroup,
    callback = function(ev)
        local dir = vim.fn.fnamemodify(ev.file, ":p:h")
        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, "p")
        end
    end,
})

-- terminal settings
au("TermOpen", {
    group = augroup,
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
    end,
})

-- brief highlight on cursor after big jump
au("CursorMoved", {
    group = augroup,
    callback = (function()
        local last_line = 0
        return function()
            local cur = vim.fn.line(".")
            if math.abs(cur - last_line) > 10 then
                vim.cmd("normal! zz")
            end
            last_line = cur
        end
    end)(),
})

--------------------------------------------------------------------------------
-- NETRW (built-in file explorer, no plugin needed)
--------------------------------------------------------------------------------
g.netrw_banner = 0
g.netrw_liststyle = 3
g.netrw_winsize = 25
map("n", "<leader>e", "<cmd>Ex<CR>", { desc = "Explorer" })
map("n", "-", "<cmd>Ex<CR>", { desc = "Explorer" })

--------------------------------------------------------------------------------
-- LAZY.NVIM BOOTSTRAP
--------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------------------------------
-- PLUGINS (minimal)
--------------------------------------------------------------------------------
require("lazy").setup({
	require("./_shared/missing_native_apis"),
	require("./_shared/tpope_goodies"),
        require("./_shared/lualine_and_theme"),


    -- colorscheme
    -- {
    --     "rebelot/kanagawa.nvim",
    --     priority = 1000,
    --     config = function() vim.cmd.colorscheme("kanagawa") end,
    -- },

    -- fuzzy finder
    {
        "ibhagwan/fzf-lua",
        keys = {
            { "<leader>f", "<cmd>FzfLua files<CR>", desc = "Files" },
            { "<leader>g", "<cmd>FzfLua live_grep<CR>", desc = "Grep" },
            { "<leader>b", "<cmd>FzfLua buffers<CR>", desc = "Buffers" },
            { "<leader>/", "<cmd>FzfLua grep_curbuf<CR>", desc = "Search buf" },
            { "<leader>:", "<cmd>FzfLua command_history<CR>", desc = "Cmd hist" },
            { "<leader>h", "<cmd>FzfLua help_tags<CR>", desc = "Help" },
            { "<leader>o", "<cmd>FzfLua oldfiles<CR>", desc = "Recent" },
            { "<leader>m", "<cmd>FzfLua marks<CR>", desc = "Marks" },
            { "gd", "<cmd>FzfLua lsp_definitions<CR>", desc = "Definition" },
            { "gr", "<cmd>FzfLua lsp_references<CR>", desc = "References" },
        },
        config = function()
            require("fzf-lua").setup({
                "fzf-native",
                winopts = { height = 0.85, width = 0.85 },
            })
        end,
    },

    -- treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = "BufReadPost",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "lua", "vim", "vimdoc", "c", "python", "bash", "markdown" },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },


    -- git
    {
        "lewis6991/gitsigns.nvim",
        event = "BufReadPre",
        opts = {
            on_attach = function(buf)
                local gs = require("gitsigns")
                map("n", "]h", gs.next_hunk, { buffer = buf, desc = "Next hunk" })
                map("n", "[h", gs.prev_hunk, { buffer = buf, desc = "Prev hunk" })
                map("n", "<leader>hs", gs.stage_hunk, { buffer = buf, desc = "Stage" })
                map("n", "<leader>hr", gs.reset_hunk, { buffer = buf, desc = "Reset" })
                map("n", "<leader>hp", gs.preview_hunk, { buffer = buf, desc = "Preview" })
                map("n", "<leader>hb", gs.blame_line, { buffer = buf, desc = "Blame" })
            end,
        },
    },

    -- tpope essentials
    { "tpope/vim-commentary", keys = { "gc", { "gc", mode = "v" } } },
    { "tpope/vim-surround", event = "VeryLazy" },
    { "tpope/vim-repeat", event = "VeryLazy" },

    -- autopairs (optional, delete if you prefer manual)
    { "windwp/nvim-autopairs", event = "InsertEnter", config = true },

}, {
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
                "netrwPlugin", -- we use netrw manually above
            },
        },
    },
    ui = { border = "rounded" },
})

