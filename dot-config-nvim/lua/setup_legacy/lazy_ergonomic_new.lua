-- ~/.config/nvim/init.lua
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

-- Leaders first
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Core ergonomic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 8
vim.opt.updatetime = 100
vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 10
vim.opt.clipboard = "unnamedplus"
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.signcolumn = "yes:1"
vim.opt.colorcolumn = "100"
vim.opt.pumheight = 10
vim.opt.cmdheight = 0
vim.opt.laststatus = 3
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.mouse = "a"
vim.opt.virtualedit = "block"
vim.opt.inccommand = "split"
vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"

require("lazy").setup({
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      -- Essential mini modules only

      -- Mini.ai - better text objects
      require('mini.ai').setup({
        n_lines = 500,
        custom_textobjects = {
          o = require('mini.ai').gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = require('mini.ai').gen_spec.treesitter({
            a = "@function.outer", i = "@function.inner"
          }),
          c = require('mini.ai').gen_spec.treesitter({
            a = "@class.outer", i = "@class.inner"
          }),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = { -- entire buffer
            "%^", "%$",
          },
        },
      })

      -- Mini.align - align text
      require('mini.align').setup()

      -- Mini.bracketed - navigate with ][
      require('mini.bracketed').setup()

      -- Mini.bufremove - better buffer deletion
      require('mini.bufremove').setup()

      -- Mini.comment - smart commenting
      require('mini.comment').setup({
        options = {
          custom_commentstring = function()
            return require('ts_context_commentstring.internal').calculate_commentstring()
              or vim.bo.commentstring
          end,
        },
      })

      -- Mini.completion - lightweight completion
      require('mini.completion').setup({
        lsp_completion = {
          source_func = 'omnifunc',
          auto_setup = false,
        },
        fallback_action = '<C-x><C-n>',
        delay = { completion = 100, info = 100, signature = 50 },
        window = {
          info = { height = 25, width = 80, border = 'rounded' },
          signature = { height = 25, width = 80, border = 'rounded' },
        },
      })

      -- Mini.files - file explorer
      require('mini.files').setup({
        content = {
          filter = function(entry)
            return entry.name ~= '.DS_Store' and entry.name ~= '.git'
          end,
        },
        mappings = {
          close = 'q',
          -- go_in = 'l',
          go_in = 'ArrowRight',
          go_in_plus = '<CR>',
          -- go_out = 'h',
          go_out = 'ArrowLeft',
          go_out_plus = 'H',
          reset = '<BS>',
          reveal_cwd = '@',
          show_help = 'g?',
          synchronize = '=',
          trim_left = '<',
          trim_right = '>',
        },
        options = {
          permanent_delete = false,
          use_as_default_explorer = true,
        },
        windows = {
          max_number = 3,
          preview = true,
          width_focus = 25,
          width_nofocus = 15,
          width_preview = 50,
        },
      })

      -- Mini.git - git integration
      require('mini.git').setup()

      -- Mini.hipatterns - highlight patterns
      require('mini.hipatterns').setup({
        highlighters = {
          fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
          hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
          todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
          note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },
          hex_color = require('mini.hipatterns').gen_highlighter.hex_color(),
        },
      })

      -- Mini.indentscope - indent guides
      require('mini.indentscope').setup({
        symbol = "▏",
        options = {
          try_as_border = true,
          border = 'both',
          indent_at_cursor = true,
        },
        draw = {
          delay = 50,
          animation = require('mini.indentscope').gen_animation.none(),
        },
      })

      -- Mini.jump2d - jump anywhere with 2 chars
      require('mini.jump2d').setup({
        allowed_lines = {
          blank = false,
          cursor_before = true,
          cursor_at = true,
          cursor_after = true,
          fold = true,
        },
        allowed_windows = {
          current = true,
          not_current = false,
        },
        labels = 'abcdefghijklmnopqrstuvwxyz',
        mappings = {
          start_jumping = '<CR>',
        },
        view = {
          dim = true,
          n_steps_ahead = 0,
        },
        silent = true,
      })

      -- Mini.move - move lines and selections
      require('mini.move').setup({
        mappings = {
          left = '<M-h>',
          right = '<M-l>',
          down = '<M-j>',
          up = '<M-k>',
          line_left = '<M-h>',
          line_right = '<M-l>',
          line_down = '<M-j>',
          line_up = '<M-k>',
        },
      })

      -- Mini.pairs - auto pairs
      require('mini.pairs').setup({
        modes = { insert = true, command = false, terminal = false },
        skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
        skip_ts = { 'string' },
        skip_unbalanced = true,
        markdown = true,
      })

      -- Mini.pick - fuzzy finder
      require('mini.pick').setup({
        options = {
          content_from_bottom = false,
          use_cache = true,
        },
        mappings = {
          caret_left  = '<C-h>',
          caret_right = '<C-l>',
          choose = '<CR>',
          choose_in_split = '<C-s>',
          choose_in_tabpage = '<C-t>',
          choose_in_vsplit = '<C-v>',
          choose_marked = '<M-CR>',
          delete_char = '<BS>',
          delete_char_right = '<Del>',
          delete_left = '<C-u>',
          delete_word = '<C-w>',
          mark = '<C-x>',
          mark_all = '<C-a>',
          move_down = '<C-n>',
          move_start = '<C-g>',
          move_up = '<C-p>',
          paste = '<C-r>',
          refine = '<C-Space>',
          refine_marked = '<M-Space>',
          scroll_down = '<C-f>',
          scroll_left = '<C-h>',
          scroll_right = '<C-l>',
          scroll_up = '<C-b>',
          stop = '<Esc>',
          toggle_info = '<S-Tab>',
          toggle_preview = '<Tab>',
        },
        window = {
          config = {
            border = 'rounded',
            height = math.floor(0.618 * vim.o.lines),
            width = math.floor(0.618 * vim.o.columns),
          },
        },
      })

      -- Mini.splitjoin - split/join arguments
      require('mini.splitjoin').setup({
        mappings = {
          toggle = 'gS',
          split = '',
          join = '',
        },
      })

      -- Mini.statusline - lightweight statusline
      local statusline = require('mini.statusline')
      statusline.setup({
        content = {
          active = function()
            local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
            local git           = statusline.section_git({ trunc_width = 40 })
            local diff          = statusline.section_diff({ trunc_width = 75 })
            local diagnostics   = statusline.section_diagnostics({ trunc_width = 75 })
            local lsp           = statusline.section_lsp({ trunc_width = 75 })
            local filename      = statusline.section_filename({ trunc_width = 140 })
            local fileinfo      = statusline.section_fileinfo({ trunc_width = 120 })
            local location      = statusline.section_location({ trunc_width = 75 })
            local search        = statusline.section_searchcount({ trunc_width = 75 })

            return statusline.combine_groups({
              { hl = mode_hl,                  strings = { mode } },
              { hl = 'MiniStatuslineDevinfo',  strings = { git, diff, diagnostics, lsp } },
              '%<', -- Mark general truncate point
              { hl = 'MiniStatuslineFilename', strings = { filename } },
              '%=', -- End left alignment
              { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
              { hl = mode_hl,                  strings = { search, location } },
            })
          end,
          inactive = function()
            local filename = statusline.section_filename({ trunc_width = 140 })
            return statusline.combine_groups({
              { hl = 'MiniStatuslineInactive', strings = { filename } },
            })
          end
        },
        use_icons = vim.g.have_nerd_font,
        set_vim_settings = false,
      })

      -- Mini.surround - surround operations
      require('mini.surround').setup({
        custom_surroundings = nil,
        highlight_duration = 500,
        mappings = {
          add = 'sa',
          delete = 'sd',
          find = 'sf',
          find_left = 'sF',
          highlight = 'sh',
          replace = 'sr',
          update_n_lines = 'sn',
        },
        n_lines = 20,
        respect_selection_type = false,
        search_method = 'cover',
        silent = false,
      })

      -- Mini.trailspace - manage trailing whitespace
      require('mini.trailspace').setup()

      -- Mini.visits - track file visits
      require('mini.visits').setup()

    end,
  },

  -- LSP with minimal setup
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "williamboman/mason.nvim",
        config = function()
          require("mason").setup({
            ui = {
              border = "rounded",
              height = 0.8,
            }
          })
        end
      },
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "pyright", "rust_analyzer", "clangd",
          "gopls", "tsserver", "bashls", "jsonls"
        },
        automatic_installation = true,
      })

      local lspconfig = require("lspconfig")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('mini.completion').get_capabilities())

      -- Server configurations
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = {
                globals = { "vim" },
                disable = { "missing-fields" }
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = { enable = false },
              hint = { enable = true },
            },
          },
        },
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--offset-encoding=utf-16",
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              checkOnSave = { command = "clippy" },
              procMacro = { enable = true },
              diagnostics = { disabled = { "unresolved-proc-macro" } },
            },
          },
        },
      }

      -- Setup servers
      for server, config in pairs(servers) do
        config.capabilities = capabilities
        lspconfig[server].setup(config)
      end

      -- Setup remaining servers with default config
      local default_servers = { "pyright", "gopls", "tsserver", "bashls", "jsonls" }
      for _, server in ipairs(default_servers) do
        lspconfig[server].setup({ capabilities = capabilities })
      end

      -- LSP keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", require('mini.pick').builtin.lsp({ scope = 'definition' }), "Goto Definition")
          map("gr", require('mini.pick').builtin.lsp({ scope = 'references' }), "Goto References")
          map("gI", require('mini.pick').builtin.lsp({ scope = 'implementation' }), "Goto Implementation")
          map("gy", require('mini.pick').builtin.lsp({ scope = 'type_definition' }), "Type Definition")
          map("gs", require('mini.pick').builtin.lsp({ scope = 'document_symbol' }), "Document Symbols")
          map("gS", require('mini.pick').builtin.lsp({ scope = 'workspace_symbol' }), "Workspace Symbols")

          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("gK", vim.lsp.buf.signature_help, "Signature Documentation")
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format")

          -- Highlight references under cursor
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      -- Diagnostic configuration
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          prefix = "●",
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "✘",
            [vim.diagnostic.severity.WARN] = "▲",
            [vim.diagnostic.severity.HINT] = "⚑",
            [vim.diagnostic.severity.INFO] = "»",
          },
        },
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })
    end,
  },

  -- Treesitter for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c", "cpp", "lua", "python", "rust", "go", "javascript",
          "typescript", "html", "css", "json", "yaml", "markdown",
          "vim", "vimdoc", "query", "bash"
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
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
      require('ts_context_commentstring').setup({
        enable_autocmd = false,
      })
    end,
  },

  -- Minimal colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        light_style = "day",
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          sidebars = "dark",
          floats = "dark",
        },
        sidebars = { "qf", "help", "terminal", "packer" },
        day_brightness = 0.3,
        hide_inactive_statusline = false,
        dim_inactive = false,
        lualine_bold = false,
        on_colors = function(colors) end,
        on_highlights = function(highlights, colors) end,
      })
      vim.cmd.colorscheme("tokyonight")
    end,
  },
}, {
  ui = {
    border = "rounded",
    backdrop = 60,
  },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
})

-- Ergonomic keymaps
local map = vim.keymap.set

-- Better defaults
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("n", "U", "<C-r>", { desc = "Redo" })
map("n", "Y", "y$", { desc = "Yank to end of line" })
map("n", "n", "nzzzv", { desc = "Next search result centered" })
map("n", "N", "Nzzzv", { desc = "Previous search result centered" })
map("x", "<", "<gv", { desc = "Indent left and reselect" })
map("x", ">", ">gv", { desc = "Indent right and reselect" })
map("x", "p", '"_dP', { desc = "Paste without yanking" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Window resizing
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Files and buffers
map("n", "<leader>e", function() require('mini.files').open() end, { desc = "File Explorer" })
map("n", "<leader>E", function() require('mini.files').open(vim.api.nvim_buf_get_name(0), false) end, { desc = "Explorer (cwd)" })

-- Fuzzy finding
map("n", "<leader>f", function() require('mini.pick').builtin.files() end, { desc = "Find Files" })
map("n", "<leader>F", function() require('mini.pick').builtin.files({}, { source = { cwd = vim.fn.expand('%:p:h') }}) end, { desc = "Find Files (cwd)" })
map("n", "<leader>/", function() require('mini.pick').builtin.grep_live() end, { desc = "Live Grep" })
map("n", "<leader>*", function() require('mini.pick').builtin.grep({ pattern = vim.fn.expand('<cword>') }) end, { desc = "Grep Word" })
map("n", "<leader>b", function() require('mini.pick').builtin.buffers() end, { desc = "Find Buffers" })
map("n", "<leader>h", function() require('mini.pick').builtin.help() end, { desc = "Find Help" })
map("n", "<leader>:", function() require('mini.pick').builtin.commands() end, { desc = "Commands" })
map("n", "<leader>'", function() require('mini.pick').builtin.marks() end, { desc = "Marks" })
map("n", '<leader>"', function() require('mini.pick').builtin.registers() end, { desc = "Registers" })
map("n", "<leader>r", function() require('mini.pick').builtin.resume() end, { desc = "Resume" })

-- Buffer operations
map("n", "<leader>bd", function() require('mini.bufremove').delete() end, { desc = "Delete Buffer" })
map("n", "<leader>bD", function() require('mini.bufremove').delete(0, true) end, { desc = "Force Delete Buffer" })
map("n", "<leader>ba", "<cmd>%bd|e#<cr>", { desc = "Delete All Buffers But Current" })

-- Git
map("n", "<leader>gg", function() require('mini.git').show_at_cursor() end, { desc = "Git Show at Cursor" })
map({ "n", "x" }, "<leader>gh", function() require('mini.git').show_at_cursor() end, { desc = "Git Show at Cursor" })

-- Jump
map("n", "<leader>j", function() require('mini.jump2d').start() end, { desc = "Jump 2D" })

-- Visits
map("n", "<leader>v", function()
  require('mini.pick').start({
    source = { items = require('mini.visits').list_visits() }
  })
end, { desc = "Visit List" })

-- Diagnostics
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show Diagnostics" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Quickfix Diagnostics" })

-- Terminal
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to Left Window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to Lower Window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to Upper Window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to Right Window" })

-- Miscellaneous
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit All" })
map("n", "<Esc>", function()
  vim.cmd("nohlsearch")
  vim.cmd("echo ''")
end, { desc = "Clear Search and Messages" })

-- Auto commands for peak ergonomics
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
})

-- Auto-trim trailing whitespace on save
autocmd("BufWritePre", {
  group = augroup("trim_whitespace", { clear = true }),
  callback = function() require('mini.trailspace').trim() end,
})

-- Auto-create directories
autocmd("BufWritePre", {
  group = augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Restore cursor position
autocmd("BufReadPost", {
  group = augroup("restore_cursor", { clear = true }),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-save on focus lost
autocmd({ "FocusLost", "BufLeave" }, {
  group = augroup("auto_save", { clear = true }),
  callback = function(event)
    if vim.bo[event.buf].buftype == "" and not vim.bo[event.buf].readonly then
      vim.cmd("silent! w")
    end
  end,
})

-- Close some filetypes with <q>
autocmd("FileType", {
  group = augroup("close_with_q", { clear = true }),
  pattern = {
    "PlenaryTestPopup", "help", "lspinfo", "man", "notify",
    "qf", "spectre_panel", "startuptime", "tsplayground", "neotest-output",
    "checkhealth", "neotest-summary", "neotest-output-panel", "dbout",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Smart indent settings per filetype
autocmd("FileType", {
  group = augroup("indent_settings", { clear = true }),
  pattern = { "go", "make" },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

