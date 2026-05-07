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
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
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
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 10
vim.opt.clipboard = "unnamedplus"
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.signcolumn = "yes:1"
vim.opt.colorcolumn = "100"
vim.opt.pumheight = 15
vim.opt.cmdheight = 1
vim.opt.laststatus = 2
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.mouse = "a"
vim.opt.virtualedit = "block"
vim.opt.inccommand = "split"
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.completeopt = "menu,menuone,noselect"

-- Global variables for classic plugins
vim.g.have_nerd_font = true

require("lazy").setup({
  -- File explorer - NERDTree
  {
    "preservim/nerdtree",
    cmd = { "NERDTree", "NERDTreeToggle", "NERDTreeFind" },
    keys = {
      { "<leader>e", "<cmd>NERDTreeToggle<cr>", desc = "Toggle NERDTree" },
      { "<leader>E", "<cmd>NERDTreeFind<cr>", desc = "Find in NERDTree" },
    },
    init = function()
      vim.g.NERDTreeWinSize = 30
      vim.g.NERDTreeShowHidden = 1
      vim.g.NERDTreeMinimalUI = 1
      vim.g.NERDTreeDirArrows = 1
      vim.g.NERDTreeAutoDeleteBuffer = 1
      vim.g.NERDTreeShowLineNumbers = 0
      vim.g.NERDTreeCascadeSingleChildDir = 0
      vim.g.NERDTreeCascadeOpenSingleChildDir = 1
      vim.g.NERDTreeQuitOnOpen = 1
      vim.g.NERDTreeIgnore = { '^\\.DS_Store$', '^\\.git$[[dir]]', '^\\..*\\.swp$' }

      -- Auto-close NERDTree if it's the only window left
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*",
        callback = function()
          if vim.fn.tabpagenr('$') == 1 and vim.fn.winnr('$') == 1 and vim.fn.exists('b:NERDTree') == 1 and vim.b.NERDTree.isTabTree then
            vim.cmd('quit')
          end
        end
      })
    end,
  },

  -- Fuzzy finder - fzf
  {
    "junegunn/fzf",
    build = "./install --bin",
  },
  {
    "junegunn/fzf.vim",
    dependencies = { "junegunn/fzf" },
    cmd = { "Files", "Rg", "Buffers", "History", "Helptags", "Commands" },
    keys = {
      { "<leader>f", "<cmd>Files<cr>", desc = "Find Files" },
      { "<leader>F", function()
          vim.cmd("Files " .. vim.fn.expand('%:p:h'))
        end, desc = "Find Files (current dir)" },
      { "<leader>/", "<cmd>Rg<cr>", desc = "Live Grep" },
      { "<leader>*", function()
          vim.cmd("Rg " .. vim.fn.expand('<cword>'))
        end, desc = "Grep Word" },
      { "<leader>b", "<cmd>Buffers<cr>", desc = "Find Buffers" },
      { "<leader>h", "<cmd>Helptags<cr>", desc = "Find Help" },
      { "<leader>:", "<cmd>Commands<cr>", desc = "Commands" },
      { "<leader>r", "<cmd>History<cr>", desc = "Recent Files" },
    },
    init = function()
      vim.g.fzf_layout = { window = { width = 0.9, height = 0.6, border = 'rounded' } }
      vim.g.fzf_preview_window = { 'right:50%:hidden', 'ctrl-p' }
      vim.g.fzf_buffers_jump = 1
      vim.g.fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'
      vim.g.fzf_tags_command = 'ctags -R'
      vim.g.fzf_commands_expect = 'alt-enter,ctrl-x'

      -- Custom colors
      vim.env.FZF_DEFAULT_OPTS = '--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

      if vim.fn.executable('rg') == 1 then
        vim.env.FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
      end
    end,
  },

  -- Git integration - vim-fugitive
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gstatus", "Gblame", "Glog", "Gdiff" },
    keys = {
      { "<leader>gg", "<cmd>Git<cr>", desc = "Git Status" },
      { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git Blame" },
      { "<leader>gl", "<cmd>Git log<cr>", desc = "Git Log" },
      { "<leader>gd", "<cmd>Gdiff<cr>", desc = "Git Diff" },
      { "<leader>gp", "<cmd>Git push<cr>", desc = "Git Push" },
      { "<leader>gP", "<cmd>Git pull<cr>", desc = "Git Pull" },
    },
  },

  -- Git signs in gutter
  {
    "airblade/vim-gitgutter",
    event = { "BufReadPre", "BufNewFile" },
    init = function()
      vim.g.gitgutter_enabled = 1
      vim.g.gitgutter_map_keys = 0
      vim.g.gitgutter_preview_win_floating = 1
      vim.g.gitgutter_sign_added = '+'
      vim.g.gitgutter_sign_modified = '~'
      vim.g.gitgutter_sign_removed = '-'
      vim.g.gitgutter_sign_removed_first_line = '^'
      vim.g.gitgutter_sign_modified_removed = '~'
      vim.g.gitgutter_override_sign_column_highlight = 1
    end,
    keys = {
      { "]h", "<cmd>GitGutterNextHunk<cr>", desc = "Next Git Hunk" },
      { "[h", "<cmd>GitGutterPrevHunk<cr>", desc = "Previous Git Hunk" },
      { "<leader>hs", "<cmd>GitGutterStageHunk<cr>", desc = "Stage Hunk" },
      { "<leader>hu", "<cmd>GitGutterUndoHunk<cr>", desc = "Undo Hunk" },
      { "<leader>hp", "<cmd>GitGutterPreviewHunk<cr>", desc = "Preview Hunk" },
    },
  },

  -- Commenting - vim-commentary
  {
    "tpope/vim-commentary",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Toggle Comment" },
      { "gcc", desc = "Toggle Comment Line" },
    },
  },

  -- Surround operations - vim-surround
  {
    "tpope/vim-surround",
    keys = { "cs", "ds", "ys", { "S", mode = "v" } },
    dependencies = {
      "tpope/vim-repeat", -- Make surround operations repeatable
    },
  },

  -- Auto pairs
  {
    "jiangmiao/auto-pairs",
    event = "InsertEnter",
    init = function()
      vim.g.AutoPairsShortcutToggle = '<M-p>'
      vim.g.AutoPairsShortcutFastWrap = '<M-e>'
      vim.g.AutoPairsShortcutJump = '<M-n>'
      vim.g.AutoPairsShortcutBackInsert = '<M-b>'
      vim.g.AutoPairsMapCR = 1
      vim.g.AutoPairsMapSpace = 1
      vim.g.AutoPairsMapBS = 1
    end,
  },

  -- Multiple cursors
  {
    "mg979/vim-visual-multi",
    keys = {
      { "<C-n>", mode = { "n", "v" }, desc = "Add Cursor" },
      { "<C-Down>", mode = { "n", "v" }, desc = "Add Cursor Down" },
      { "<C-Up>", mode = { "n", "v" }, desc = "Add Cursor Up" },
    },
    init = function()
      vim.g.VM_theme = 'iceblue'
      vim.g.VM_default_mappings = 0
      vim.g.VM_maps = {
        ['Find Under'] = '<C-n>',
        ['Find Subword Under'] = '<C-n>',
        ['Select All'] = '<C-S-n>',
        ['Start Regex Search'] = '\\/',
        ['Add Cursor Down'] = '<C-Down>',
        ['Add Cursor Up'] = '<C-Up>',
        ['Add Cursor At Pos'] = '\\\\',
        ['Visual Regex'] = '\\/',
        ['Visual All'] = '\\A',
        ['Visual Add'] = '\\a',
        ['Visual Find'] = '\\f',
        ['Visual Cursors'] = '\\c',
      }
    end,
  },

  -- Better text objects
  {
    "wellle/targets.vim",
    event = { "BufReadPost", "BufNewFile" },
  },

  -- Indent guides
  {
    "Yggdroot/indentLine",
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      vim.g.indentLine_enabled = 1
      vim.g.indentLine_char = '│'
      vim.g.indentLine_first_char = '│'
      vim.g.indentLine_showFirstIndentLevel = 1
      vim.g.indentLine_setColors = 0
      vim.g.indentLine_color_term = 239
      vim.g.indentLine_fileTypeExclude = { 'help', 'nerdtree', 'startify' }
      vim.g.indentLine_bufTypeExclude = { 'terminal', 'nofile' }
    end,
  },

  -- Start screen
  {
    "mhinz/vim-startify",
    lazy = false,
    init = function()
      vim.g.startify_session_dir = vim.fn.stdpath('data') .. '/sessions'
      vim.g.startify_lists = {
        { type = 'files',     header = {'   Recent Files'} },
        { type = 'dir',       header = {'   Recent Files in ' .. vim.fn.getcwd()} },
        { type = 'sessions',  header = {'   Sessions'} },
        { type = 'bookmarks', header = {'   Bookmarks'} },
      }
      vim.g.startify_bookmarks = {
        { c = '~/.config/nvim/init.lua' },
        { z = '~/.zshrc' },
        { t = '~/.tmux.conf' },
      }
      vim.g.startify_session_autoload = 1
      vim.g.startify_session_delete_buffers = 1
      vim.g.startify_change_to_vcs_root = 1
      vim.g.startify_fortune_use_unicode = 1
      vim.g.startify_session_persistence = 1
      vim.g.startify_enable_special = 0
    end,
  },

  -- Statusline - vim-airline
  {
    "vim-airline/vim-airline",
    dependencies = { "vim-airline/vim-airline-themes" },
    event = "VeryLazy",
    init = function()
      vim.g.airline_powerline_fonts = 1
      vim.g.airline_theme = 'dark'
      vim.g['airline#extensions#tabline#enabled'] = 1
      vim.g['airline#extensions#tabline#buffer_nr_show'] = 1
      vim.g['airline#extensions#tabline#formatter'] = 'unique_tail_improved'
      vim.g['airline#extensions#default#layout'] = {
        { 'a', 'b', 'c' },
        { 'x', 'y', 'z' }
      }
      vim.g['airline#extensions#default#section_truncate_width'] = {
        b = 79,
        x = 60,
        y = 88,
        z = 45,
        warning = 80,
        error = 80,
      }
      vim.g.airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
      vim.g.airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'

      -- Custom symbols
      if not vim.g.have_nerd_font then
        vim.g.airline_left_sep = ''
        vim.g.airline_right_sep = ''
        vim.g.airline_symbols = {}
        vim.g.airline_symbols.linenr = '¶'
        vim.g.airline_symbols.branch = '⎇'
        vim.g.airline_symbols.paste = 'Þ'
        vim.g.airline_symbols.whitespace = 'Ξ'
      end
    end,
  },

  -- LSP and completion - coc.nvim
  {
    "neoclide/coc.nvim",
    branch = "release",
    event = { "BufReadPre", "BufNewFile" },
    build = ":CocUpdate",
    init = function()
      -- Coc extensions
      vim.g.coc_global_extensions = {
        'coc-json',
        'coc-tsserver',
        'coc-html',
        'coc-css',
        'coc-pyright',
        'coc-clangd',
        'coc-rust-analyzer',
        'coc-go',
        'coc-lua',
        'coc-sh',
        'coc-yaml',
        'coc-snippets',
      }

      -- Coc settings
      vim.g.coc_config_home = vim.fn.stdpath('config')

      -- Use tab for trigger completion
      vim.api.nvim_create_autocmd("User", {
        pattern = "CocJumpPlaceholder",
        command = "call CocActionAsync('showSignatureHelp')",
      })
    end,
    config = function()
      local keyset = vim.keymap.set

      -- Autocomplete
      function _G.check_back_space()
        local col = vim.fn.col('.') - 1
        return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
      end

      local opts = {silent = true, noremap = true, expr = true, replace_keycodes = false}
      keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
      keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
      keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)
      keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")
      keyset("i", "<c-space>", "coc#refresh()", {silent = true, expr = true})

      -- GoTo code navigation
      keyset("n", "gd", "<Plug>(coc-definition)", {silent = true})
      keyset("n", "gy", "<Plug>(coc-type-definition)", {silent = true})
      keyset("n", "gi", "<Plug>(coc-implementation)", {silent = true})
      keyset("n", "gr", "<Plug>(coc-references)", {silent = true})

      -- Use K to show documentation
      function _G.show_docs()
        local cw = vim.fn.expand('<cword>')
        if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
          vim.api.nvim_command('h ' .. cw)
        elseif vim.api.nvim_eval('coc#rpc#ready()') then
          vim.fn.CocActionAsync('doHover')
        else
          vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
        end
      end
      keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', {silent = true})

      -- Highlight symbol under cursor
      vim.api.nvim_create_augroup("CocGroup", {})
      vim.api.nvim_create_autocmd("CursorHold", {
        group = "CocGroup",
        command = "silent call CocActionAsync('highlight')",
        desc = "Highlight symbol under cursor on CursorHold"
      })

      -- Symbol renaming
      keyset("n", "<leader>cr", "<Plug>(coc-rename)", {silent = true})

      -- Formatting selected code
      keyset("x", "<leader>cf", "<Plug>(coc-format-selected)", {silent = true})
      keyset("n", "<leader>cf", "<Plug>(coc-format-selected)", {silent = true})

      -- Setup formatexpr specified filetype(s)
      vim.api.nvim_create_autocmd("FileType", {
        group = "CocGroup",
        pattern = "typescript,json",
        command = "setl formatexpr=CocAction('formatSelected')",
        desc = "Setup formatexpr specified filetype(s)."
      })

      -- Update signature help on jump placeholder
      vim.api.nvim_create_autocmd("User", {
        group = "CocGroup",
        pattern = "CocJumpPlaceholder",
        command = "call CocActionAsync('showSignatureHelp')",
        desc = "Update signature help on jump placeholder"
      })

      -- Apply codeAction to selected region
      keyset("x", "<leader>ca", "<Plug>(coc-codeaction-selected)", {silent = true})
      keyset("n", "<leader>ca", "<Plug>(coc-codeaction-selected)", {silent = true})

      -- Remap keys for apply code actions at cursor position
      keyset("n", "<leader>cc", "<Plug>(coc-codeaction-cursor)", {silent = true})

      -- Apply AutoFix to problem on current line
      keyset("n", "<leader>cq", "<Plug>(coc-fix-current)", {silent = true})

      -- Run Code Lens action on current line
      keyset("n", "<leader>cl", "<Plug>(coc-codelens-action)", {silent = true})

      -- Map function and class text objects
      keyset("x", "if", "<Plug>(coc-funcobj-i)", {silent = true})
      keyset("o", "if", "<Plug>(coc-funcobj-i)", {silent = true})
      keyset("x", "af", "<Plug>(coc-funcobj-a)", {silent = true})
      keyset("o", "af", "<Plug>(coc-funcobj-a)", {silent = true})
      keyset("x", "ic", "<Plug>(coc-classobj-i)", {silent = true})
      keyset("o", "ic", "<Plug>(coc-classobj-i)", {silent = true})
      keyset("x", "ac", "<Plug>(coc-classobj-a)", {silent = true})
      keyset("o", "ac", "<Plug>(coc-classobj-a)", {silent = true})

      -- Remap <C-f> and <C-b> to scroll float windows/popups
      local opts = {silent = true, nowait = true, expr = true}
      keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
      keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
      keyset("i", "<C-f>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
      keyset("i", "<C-b>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
      keyset("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
      keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)

      -- Use CTRL-S for selections ranges
      keyset("n", "<C-s>", "<Plug>(coc-range-select)", {silent = true})
      keyset("x", "<C-s>", "<Plug>(coc-range-select)", {silent = true})

      -- Add `:Format` command to format current buffer
      vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})

      -- Add `:Fold` command to fold current buffer
      vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", {nargs = '?'})

      -- Add `:OR` command for organize imports of current buffer
      vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})

      -- Mappings for CoCList
      keyset("n", "<leader>cd", ":<C-u>CocList diagnostics<cr>", {silent = true})
      keyset("n", "<leader>ce", ":<C-u>CocList extensions<cr>", {silent = true})
      keyset("n", "<leader>co", ":<C-u>CocList outline<cr>", {silent = true})
      keyset("n", "<leader>cs", ":<C-u>CocList -I symbols<cr>", {silent = true})
      keyset("n", "<leader>cj", ":<C-u>CocNext<cr>", {silent = true})
      keyset("n", "<leader>ck", ":<C-u>CocPrev<cr>", {silent = true})
      keyset("n", "<leader>cp", ":<C-u>CocListResume<cr>", {silent = true})

      -- Diagnostics navigation
      keyset("n", "[d", "<Plug>(coc-diagnostic-prev)", {silent = true})
      keyset("n", "]d", "<Plug>(coc-diagnostic-next)", {silent = true})
    end,
  },

  -- Syntax highlighting - vim-polyglot
  {
    "sheerun/vim-polyglot",
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      vim.g.polyglot_disabled = { 'sensible' } -- Disable conflicting plugins
    end,
  },

  -- Color scheme - gruvbox
  {
    "morhetz/gruvbox",
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.gruvbox_contrast_dark = 'hard'
      vim.g.gruvbox_invert_selection = 0
      vim.g.gruvbox_sign_column = 'bg0'
      vim.g.gruvbox_improved_strings = 1
      vim.g.gruvbox_improved_warnings = 1
    end,
    config = function()
      vim.cmd.colorscheme("gruvbox")
    end,
  },

  -- Better search
  {
    "haya14busa/incsearch.vim",
    keys = {
      { "/", "<Plug>(incsearch-forward)", mode = "n" },
      { "?", "<Plug>(incsearch-backward)", mode = "n" },
      { "g/", "<Plug>(incsearch-stay)", mode = "n" },
    },
    init = function()
      vim.g["incsearch#auto_nohlsearch"] = 1
    end,
  },

  -- Enhanced f/F/t/T motions
  {
    "rhysd/clever-f.vim",
    keys = { "f", "F", "t", "T" },
    init = function()
      vim.g.clever_f_mark_cursor = 1
      vim.g.clever_f_mark_cursor_color = "Search"
      vim.g.clever_f_hide_cursor_on_cmdline = 1
      vim.g.clever_f_chars_match_any_signs = 0
      vim.g.clever_f_smart_case = 1
      vim.g.clever_f_use_migemo = 0
      vim.g.clever_f_fix_key_direction = 0
      vim.g.clever_f_show_prompt = 1
      vim.g.clever_f_across_no_line = 0
      vim.g.clever_f_timeout_ms = 0
    end,
  },

  -- Align text
  {
    "junegunn/vim-easy-align",
    cmd = { "EasyAlign" },
    keys = {
      { "ga", "<Plug>(EasyAlign)", mode = { "n", "x" }, desc = "Easy Align" },
    },
  },

  -- Exchange text objects
  {
    "tommcdo/vim-exchange",
    keys = { "cx", "cxx", { "X", mode = "x" } },
  },

  -- Better increment/decrement
  {
    "tpope/vim-speeddating",
    keys = { "<C-a>", "<C-x>" },
  },

  -- Session management
  {
    "tpope/vim-obsession",
    cmd = { "Obsess" },
    keys = {
      { "<leader>ss", "<cmd>Obsess<cr>", desc = "Start Session" },
      { "<leader>sS", "<cmd>Obsess!<cr>", desc = "Stop Session" },
    },
  },

}, {
  ui = {
    border = "rounded",
    backdrop = 60,
  },
  performance = {
    cache = { enabled = true },
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

