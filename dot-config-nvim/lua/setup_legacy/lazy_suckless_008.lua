-- ~/.config/nvim/init.lua
-- The final boss: one-file, hyper-tailored, C/Rust weapon (2025)
-- ~180 lines of pure violence and elegance

vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- ╭━━━━━━━━━━━━━━━━━━━━━━━━━━ Options ━━━━━━━━━━━━━━━━━━━━━━━━━━╮
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.signcolumn     = "yes:1"
vim.opt.cursorline     = true
vim.opt.scrolloff      = 8
vim.opt.sidescrolloff  = 8
vim.opt.tabstop        = 4
vim.opt.shiftwidth     = 4
vim.opt.expandtab      = true
vim.opt.smartindent    = true
vim.opt.termguicolors  = true
vim.opt.mouse          = "a"
vim.opt.updatetime     = 200
vim.opt.timeoutlen     = 400
vim.opt.clipboard      = "unnamedplus"
vim.opt.splitright     = true
vim.opt.splitbelow     = true
vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.grepprg        = "rg --vimgrep --smart-case"
vim.opt.completeopt    = "menu,menuone,noselect"
vim.opt.shortmess:append("c")

-- ╭━━━━━━━━━━━━━━━━━━━━━━ Bootstrap lazy.nvim ━━━━━━━━━━━━━━━━━━━━━━╮
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ╭━━━━━━━━━━━━━━━━━━━━━━ Helper functions ━━━━━━━━━━━━━━━━━━━━━━╮
local function map(m, l, r, desc) 
    vim.keymap.set(m, l, r, { desc }) 
end

-- Smart dd that doesn't yank empty line
-- map("n", "dd", function()
--   if vim.fn.getline(".") == "" then return '"_dd' end
--   return "dd"
-- end, { expr = true })


local map = vim.keymap.set

-- Better window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Resize with arrows
map("n", "<C-Up>",    ":resize +2<CR>")
map("n", "<C-Down>",  ":resize -2<CR>")
map("n", "<C-Left>",  ":vertical resize -2<CR>")
map("n", "<C-Right>", ":vertical resize +2<CR>")

-- ╭━━━━━━━━━━━━━━━━━━━━━━ GIANT lazy.setup() ━━━━━━━━━━━━━━━━━━━━━━╮
require("lazy").setup({


    require("./_shared/missing_native_apis"),
    require("./_shared/tpope_goodies"),
    require("./_shared/lualine_and_theme"),

  -- ── Colors & UI ─────────────────────────────────────
  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   priority = 1000,
  --   opts = { flavour = "mocha", integrations = { treesitter = true, native_lsp = { enabled = true } } },
  --   config = function(_, opts)
  --     require("catppuccin").setup(opts)
  --     vim.cmd.colorscheme("catppuccin")
  --   end,
  -- },
  -- { "nvim-lualine/lualine.nvim", config = true },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = { scope = { enabled = false } } },

  -- ── Motion & Editing ─────────────────────────────────
  { "ggandor/leap.nvim", config = function() require("leap").add_default_mappings() end },
  { "kylechui/nvim-surround",   event = "VeryLazy", config = true },
  { "numToStr/Comment.nvim",    config = true },
  { "windwp/nvim-autopairs",    event = "InsertEnter", config = true },

  -- ── Telescope ────────────────────────────────────────
  -- {
  --   "nvim-telescope/telescope.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  --   keys = {
  --     { "<leader>ff", "<cmd>Telescope find_files<CR>" },
  --     { "<leader>fg", "<cmd>Telescope live_grep<CR>" },
  --     { "<leader>fb", "<cmd>Telescope buffers<CR>" },
  --     { "<leader>fh", "<cmd>Telescope help_tags<CR>" },
  --     { "<leader>fr", "<cmd>Telescope lsp_references<CR>" },
  --   },
  --   config = function() require("telescope").load_extension("fzf") end,
  -- },

  -- ── Treesitter ───────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "c", "cpp", "rust", "toml", "bash", "lua", "vim", "vimdoc", "make", "cmake" },
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = { enable = true },
    },
    config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end,
  },

  -- ── LSP & Mason ──────────────────────────────────────
  { "williamboman/mason.nvim", config = true },
  -- {
  --   "neovim/nvim-lspconfig",
  --   dependencies = { "hrsh7th/cmp-nvim-lsp" },
  -- },

  -- ── Rust: the 2025 king (rustaceanvim) ───────────────
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = "rust",
    opts = {
      server = {
        on_attach = function(_, bufnr)
          map("n", "<leader>rr", "<cmd>RustLsp runnables<CR>",  { buffer = bufnr, desc = "Rust runnables" })
          map("n", "<leader>rd", "<cmd>RustLsp debuggables<CR>", { buffer = bufnr, desc = "Rust debuggables" })
          map("n", "<leader>rh", "<cmd>RustLsp hover actions<CR>", { buffer = bufnr, desc = "Hover actions" })
          map("n", "<leader>re", "<cmd>RustLsp expandMacro<CR>", { buffer = bufnr, desc = "Expand macro" })
          map("n", "<leader>rm", "<cmd>RustLsp openCargo<CR>",   { buffer = bufnr, desc = "Open Cargo.toml" })
        end,
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true, loadOutDirsFromCheck = true },
            check = { command = "clippy" },
            procMacro = { enable = true },
            inlayHints = { bindingModeHints = { enable = true }, closingBraceHints = { enable = true } },
          },
        },
      },
    },
  },
  { "saecki/crates.nvim", ft = { "rust", "toml" }, config = true },

  -- ── C/C++: clangd + inlay hints ───────────────────────
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp" },
    opts = {
      inlay_hints = { inline = vim.fn.has("nvim-0.10") == 1 },
      ast = { role_icons = { ["function"] = "ƒ" } },
    },
  },

  -- ── Completion ───────────────────────────────────────
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip", "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif require("luasnip").expand_or_jumpable() then require("luasnip").expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif require("luasnip").jumpable(-1) then require("luasnip").jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp", priority = 100 },
          { name = "luasnip",  priority = 90 },
          { name = "buffer",   priority = 70 },
          { name = "path",     priority = 60 },
        },
        formatting = {
          format = function(_, item) item.menu = "" return item end,
        },
      })
    end,
  },

  -- ── Final LSP setup (clangd) ─────────────────────────
  -- {
  --   "williamboman/mason-lspconfig.nvim",
  --   dependencies = { "mason.nvim", "nvim-lspconfig", "cmp-nvim-lsp" },
  --   config = function()
  --     require("mason-lspconfig").setup({ ensure_installed = { "clangd" } })
  --     local lspconfig = require("lspconfig")
  --     local caps = require("cmp_nvim_lsp").default_capabilities()
  --
  --     lspconfig.clangd.setup({
  --       capabilities = caps,
  --       cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu", "--all-scopes-completion" },
  --       init_options = { fallbackFlags = { "-std=c++20" } },
  --     })
  --   end,
  -- },

}, {
  checker = { enabled = true },
  performance = { rtp = { disabled_plugins = { "netrwPlugin", "tohtml", "tutor", "gzip", "tarPlugin", "zipPlugin" } } },
})

-- Final touch: make Escape cancel completion
vim.keymap.set("i", "<Esc>", function()
  if require("cmp").visible() then require("cmp").close() end
  return "<Esc>"
end, { expr = true })
