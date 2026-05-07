-- ~/.config/nvim/init.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local clone = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",  -- ✅ removed trailing spaces
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to clone lazy.nvim:\n" .. clone, vim.log.levels.ERROR)
    return
  end
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({

    require("./_shared/missing_native_apis"),
    require("./_shared/tpope_goodies"),
    require("./_shared/lualine_and_theme"),


  -- LSP & Rust
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "folke/neodev.nvim",
      "simrat39/rust-tools.nvim", -- ✅ provides :RustRunnables, etc.
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup()
      require("neodev").setup()

      -- Ensure cmp_nvim_lsp is loaded if you use it
      local capabilities = vim.tbl_deep_extend(
        "force",
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities()
      )

      local lspconfig = require("lspconfig")
      lspconfig.clangd.setup({
        capabilities = capabilities,
        cmd = { "clangd", "--background-index", "--clang-tidy" }
      })

      -- rust-tools handles rust_analyzer setup + extra commands
      require("rust-tools").setup({
        server = {
          capabilities = capabilities,
          settings = {
            ["rust-analyzer"] = {
              checkOnSave = { command = "clippy" },
              cargo = { allFeatures = true },
              procMacro = { enable = true }
            }
          }
        }
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buf = args.buf
          local km = function(lhs, rhs)
            vim.keymap.set("n", lhs, rhs, { buffer = buf, noremap = true, silent = true })
          end
          km("gd", vim.lsp.buf.definition)
          km("K", vim.lsp.buf.hover)
          km("<leader>ca", vim.lsp.buf.code_action)
          km("<leader>rr", "<cmd>RustRunnables<cr>")
          km("<leader>re", "<cmd>RustExpandMacro<cr>")
        end,
      })
    end
  },

  -- Completion
  { "hrsh7th/cmp-nvim-lsp" }, -- ✅ explicit plugin so require() works
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets"
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer", keyword_length = 3 },
        })
      })
    end
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufReadPost",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "cpp", "rust" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn"
          }
        }
      })
    end
  },

  -- Git
  {
    "lewis6991/gitsigns.nvim",
    event = "BufRead",
    opts = { current_line_blame = true }
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--type-not", "minidump"
        }
      }
    }
  },

  -- Optional: DAP UI (uncomment later if needed)
  -- { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap" } },
}, {
  defaults = { lazy = true },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "netrwPlugin", "tarPlugin",
        "tohtml", "tutor", "zipPlugin"
      }
    }
  }
})

-- === Rest of your config (unchanged, but with minor cleanup) ===
local map = function(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

vim.g.mapleader = " "

-- UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes:2"
vim.opt.updatetime = 100
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Buffer/Tab
map("n", "<Tab>", function()
  if vim.fn.tabpagenr("$") > 1 then vim.cmd("tabnext") else vim.cmd("bnext") end
end)
map("n", "<S-Tab>", function()
  if vim.fn.tabpagenr("$") > 1 then vim.cmd("tabprev") else vim.cmd("bprev") end
end)

-- Diagnostics
map("n", "[d", vim.diagnostic.goto_prev)
map("n", "]d", vim.diagnostic.goto_next)
map("n", "[q", "<cmd>cprev<CR>")
map("n", "]q", "<cmd>cnext<CR>")

-- Paste
map("x", "<leader>p", "\"_dP")

-- Clear search
map("n", "<esc><esc>", "<cmd>nohl<CR>")

-- Utilities
local M = {}

M.compile_or_run = function()
  if vim.bo.filetype == "rust" then
    vim.cmd([[silent !cargo build]])
  elseif vim.bo.filetype == "c" or vim.bo.filetype == "cpp" then
    local file = vim.fn.expand("%:r")
    vim.cmd(string.format([[silent !gcc -g -O0 -std=c11 %s.c -o %s]], file, file))
  else
    return
  end
  vim.notify("Compiled", "info")
end

M.run_current = function()
  local cmd
  if vim.bo.filetype == "rust" then
    cmd = "cargo run"
  else
    local exec = "./" .. vim.fn.expand("%:r")
    if vim.fn.executable(exec) == 1 then
      cmd = exec
    else
      vim.notify("Not executable or unsupported filetype", "warn")
      return
    end
  end
  vim.cmd("silent !" .. cmd)
end

-- Debugging (will error if DAP not loaded — consider guarding)
-- map("n", "<F5>", function() pcall(require, "dap") and require("dap").continue() end)

-- Toggles
M.toggle_diagnostics = function()
  if vim.diagnostic.is_disabled() then
    vim.diagnostic.enable()
    vim.notify("Diagnostics ON")
  else
    vim.diagnostic.disable()
    vim.notify("Diagnostics OFF")
  end
end

M.toggle_relative_number = function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end

-- Keymaps
map("n", "<leader>cc", M.compile_or_run, { desc = "Compile" })
map("n", "<leader>cr", M.run_current, { desc = "Run" })
map("n", "<leader>td", M.toggle_diagnostics, { desc = "Toggle Diagnostics" })
map("n", "<leader>rn", M.toggle_relative_number, { desc = "Toggle Relative Numbers" })

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
