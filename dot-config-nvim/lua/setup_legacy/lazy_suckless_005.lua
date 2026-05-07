-- init.lua - Suckless Neovim Config v2
-- Evaluated approach: minimal but practical with quality-of-life improvements

-- Bootstrap lazy.nvim
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

-- Core settings (suckless but practical)
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.opt.undofile = true
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.cmdheight = 1
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80,120"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.mouse = "a" -- Practical compromise for terminal usage

-- Custom functions (suckless philosophy: build what you need)
local M = {}

-- Quickfix list helper
function M.toggle_quickfix()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      qf_exists = true
      break
    end
  end
  if qf_exists then
    vim.cmd("cclose")
    return
  end
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd("copen")
  end
end

-- Buffer management
function M.kill_buffer()
  local bufnr = vim.fn.bufnr()
  if vim.bo.modified then
    local choice = vim.fn.confirm("Save changes?", "&Yes\n&No\n&Cancel")
    if choice == 1 then     -- Yes
      vim.cmd("write")
    elseif choice == 3 then -- Cancel
      return
    end
  end
  vim.cmd("bdelete " .. bufnr)
end

-- Terminal helper
function M.toggle_terminal()
  local term_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" then
      term_buf = buf
      break
    end
  end

  if term_buf and vim.fn.bufwinnr(term_buf) ~= -1 then
    vim.cmd("hide")
  else
    vim.cmd("botright 10split | terminal")
    vim.cmd("startinsert")
  end
end

-- Smart line movement
function M.move_line(direction)
  local move_cmd = direction > 0 and "m .+1<CR>==" or "m .-2<CR>=="
  return move_cmd
end

-- Session management (minimal)
function M.save_session()
  local session_file = vim.fn.getcwd() .. "/.nvim_session"
  vim.cmd("mksession! " .. session_file)
  print("Session saved: " .. session_file)
end

function M.load_session()
  local session_file = vim.fn.getcwd() .. "/.nvim_session"
  if vim.fn.filereadable(session_file) == 1 then
    vim.cmd("source " .. session_file)
    print("Session loaded: " .. session_file)
  else
    print("No session file found")
  end
end

-- Enhanced keymaps with ergonomic improvements
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Quality of life mappings
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", M.kill_buffer, { desc = "Close buffer" })
vim.keymap.set("n", "<leader>Q", "<cmd>quitall<cr>", { desc = "Quit Neovim" })
vim.keymap.set("n", "<leader>c", "<cmd>nohlsearch<cr>", { desc = "Clear search" })

-- Window management
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Terminal mappings
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("n", "<leader>t", M.toggle_terminal, { desc = "Toggle terminal" })

-- Quickfix
vim.keymap.set("n", "<leader>co", "<cmd>copen<cr>", { desc = "Open quickfix" })
vim.keymap.set("n", "<leader>cc", "<cmd>cclose<cr>", { desc = "Close quickfix" })
vim.keymap.set("n", "<leader>cn", "<cmd>cnext<cr>", { desc = "Next quickfix" })
vim.keymap.set("n", "<leader>cp", "<cmd>cprev<cr>", { desc = "Prev quickfix" })

-- Session management
vim.keymap.set("n", "<leader>ss", M.save_session, { desc = "Save session" })
vim.keymap.set("n", "<leader>sl", M.load_session, { desc = "Load session" })

-- Line movement with visual feedback
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
vim.keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
vim.keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Plugin configuration with careful selection
require("lazy").setup({

	require("./_shared/missing_native_apis"),
	require("./_shared/tpope_goodies"),
    require("./_shared/lualine_and_theme"),

  -- ESSENTIAL: File navigation and editing
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
      vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
    end
  },


 {
   "pmizio/typescript-tools.nvim",
   dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
   config = function()
     require("typescript-tools").setup({})
   end
 },

  -- ESSENTIAL: Syntax and parsing
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        -- ensure_installed = { "lua", "vim", "vimdoc", "query", "bash", "markdown", "python", "javascript", "typescript" },
        ensure_installed = { "lua", "vim", "vimdoc", "c", "python", "bash", "markdown", "json", "yaml"},
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
      })
    end
  },

  -- ESSENTIAL: LSP
  -- {
  --   "neovim/nvim-lspconfig",
  --   dependencies = {
  --     "williamboman/mason.nvim",
  --     "williamboman/mason-lspconfig.nvim",
  --   },
  --   config = function()
  --     require("mason").setup()
  --     require("mason-lspconfig").setup({
  --       ensure_installed = { "lua_ls", "bashls", "pyright" }
  --     })
  --
  --     local lspconfig = require("lspconfig")
  --     local capabilities = require("cmp_nvim_lsp").default_capabilities()
  --
  --     -- Enhanced LSP keymaps
  --     vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
  --     vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
  --     vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
  --     vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
  --     vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References" })
  --     vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
  --     vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
  --     vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format buffer" })
  --
  --     -- Auto-format on save
  --     vim.api.nvim_create_autocmd("LspAttach", {
  --       callback = function(args)
  --         vim.api.nvim_create_autocmd("BufWritePre", {
  --           buffer = args.buf,
  --           callback = function()
  --             vim.lsp.buf.format({ async = false })
  --           end,
  --         })
  --       end,
  --     })
  --
  --     lspconfig.lua_ls.setup({ capabilities = capabilities })
  --     lspconfig.bashls.setup({ capabilities = capabilities })
  --     lspconfig.pyright.setup({ capabilities = capabilities })
  --   end
  -- },

  -- -- ESSENTIAL: Completion
  -- {
  --   "hrsh7th/nvim-cmp",
  --   dependencies = {
  --     "hrsh7th/cmp-nvim-lsp",
  --     "hrsh7th/cmp-buffer",
  --     "hrsh7th/cmp-path",
  --     "L3MON4D3/LuaSnip",
  --     "saadparwaiz1/cmp_luasnip",
  --   },
  --   config = function()
  --     local cmp = require("cmp")
  --     cmp.setup({
  --       snippet = {
  --         expand = function(args)
  --           require("luasnip").lsp_expand(args.body)
  --         end,
  --       },
  --       mapping = cmp.mapping.preset.insert({
  --         ["<C-p>"] = cmp.mapping.select_prev_item(),
  --         ["<C-n>"] = cmp.mapping.select_next_item(),
  --         ["<C-b>"] = cmp.mapping.scroll_docs(-4),
  --         ["<C-f>"] = cmp.mapping.scroll_docs(4),
  --         ["<C-Space>"] = cmp.mapping.complete(),
  --         ["<C-e>"] = cmp.mapping.abort(),
  --         ["<CR>"] = cmp.mapping.confirm({ select = true }),
  --         ["<Tab>"] = cmp.mapping(function(fallback)
  --           if cmp.visible() then
  --             cmp.select_next_item()
  --           else
  --             fallback()
  --           end
  --         end, { "i", "s" }),
  --       }),
  --       sources = cmp.config.sources({
  --         { name = "nvim_lsp" },
  --         { name = "luasnip" },
  --       }, {
  --         { name = "buffer" },
  --         { name = "path" },
  --       }),
  --     })
  --   end
  -- },

  -- -- QUALITY OF LIFE: Minimal statusline
  -- {
  --   "nvim-lualine/lualine.nvim",
  --   config = function()
  --     require("lualine").setup({
  --       options = {
  --         theme = "auto",
  --         component_separators = "|",
  --         section_separators = "",
  --         disabled_filetypes = { "packer", "NvimTree" },
  --       },
  --       sections = {
  --         lualine_a = {"mode"},
  --         lualine_b = {"filename", "diagnostics"},
  --         lualine_c = {},
  --         lualine_x = {"filetype"},
  --         lualine_y = {"progress"},
  --         lualine_z = {"location"}
  --       },
  --     })
  --   end
  -- },
  --
  -- QUALITY OF LIFE: Git integration
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          vim.keymap.set("n", "<leader>gb", gs.toggle_current_line_blame, { buffer = bufnr, desc = "Toggle blame" })
          vim.keymap.set("n", "<leader>gd", gs.diffthis, { buffer = bufnr, desc = "Git diff" })
        end,
      })
    end
  },

  -- QUALITY OF LIFE: Better commenting
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
      vim.keymap.set("n", "<leader>/", "<cmd>lua require('Comment.api').toggle.linewise.current()<cr>",
        { desc = "Toggle comment" })
      vim.keymap.set("v", "<leader>/", "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
        { desc = "Toggle comment" })
    end
  },

  -- QUALITY OF LIFE: Color scheme
  -- {
  --   "rose-pine/neovim",
  --   name = "rose-pine",
  --   config = function()
  --     require("rose-pine").setup({
  --       disable_background = false,
  --       disable_float_background = false,
  --     })
  --     vim.cmd.colorscheme("rose-pine")
  --   end
  -- },


  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- { "windwp/nvim-autopairs",    event = "InsertEnter", config = true },
  -- ERGONOMIC HACK: Smooth scrolling
  {
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup()
    end
  },

  -- ERGONOMIC HACK: Better window resizing
  {
    "simeji/winresizer",
    config = function()
      vim.g.winresizer_start_key = "<C-w>e"
    end
  },

}, {
  -- Lazy.nvim options
  install = { colorscheme = { "rose-pine" } },
  checker = { enabled = false },
  change_detection = { enabled = false },
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

-- Auto-commands for specific file types
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 2
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.spell = true
  end
})

-- Restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Performance monitoring
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local stats = require("lazy").stats()
    local startup_time = math.floor(stats.startuptime * 100) / 100
    local plugin_count = stats.count
    print(string.format("Neovim started in %.2fms with %d plugins", startup_time, plugin_count))
  end
})

-- Export functions for potential external use
return M
