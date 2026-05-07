local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
  -- Core settings and utilities
  {
    "folke/neodev.nvim",
    config = function()
      require("neodev").setup()

      -- Basic settings
      vim.g.mapleader = " "
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.smartindent = true
      vim.opt.wrap = true
      vim.opt.linebreak = true
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.termguicolors = true
      vim.opt.cursorline = true
      vim.opt.signcolumn = "yes"
      vim.opt.updatetime = 200
      vim.opt.timeoutlen = 500
      vim.opt.clipboard = "unnamedplus"
      vim.opt.mouse = "a"
      vim.opt.scrolloff = 10
      vim.opt.sidescrolloff = 10
      vim.opt.undofile = true
      vim.opt.backup = false
      vim.opt.writebackup = false
      vim.opt.swapfile = false
      vim.opt.splitright = true
      vim.opt.splitbelow = true
      vim.opt.completeopt = { "menuone", "noselect" }
      vim.opt.laststatus = 3

      -- Autocommands
      local augroup = vim.api.nvim_create_augroup
      local autocmd = vim.api.nvim_create_autocmd

      augroup("YankHighlight", { clear = true })
      autocmd("TextYankPost", {
        group = "YankHighlight",
        callback = function()
          vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
        end,
      })

      augroup("TrimWhitespace", { clear = true })
      autocmd("BufWritePre", {
        group = "TrimWhitespace",
        pattern = "*",
        command = "%s/\\s\\+$//e",
      })

      augroup("CloseWithQ", { clear = true })
      autocmd("FileType", {
        group = "CloseWithQ",
        pattern = { "help", "man", "lspinfo", "qf" },
        callback = function(event)
          vim.bo[event.buf].buflisted = false
          vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
        end,
      })

      -- Keybindings
      vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
      vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
      vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
      vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
      vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
      vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
      vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
      vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
      vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })
      vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
      vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
    end,
  },

  -- Colorscheme
  {
    "sainnhe/gruvbox-material",
    config = function()
      vim.g.gruvbox_material_background = "medium"
      vim.cmd.colorscheme("gruvbox-material")
    end,
  },

  -- File explorer
  {
    "DreamMao/yazi.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = { "<leader>e" },
    config = function()
      require("yazi").setup({
        open_for_directories = true,
      })
      vim.keymap.set("n", "<leader>e", "<cmd>Yazi<cr>", { desc = "Open Yazi file explorer" })
    end,
  },

  -- Fuzzy finder
  {
    "ibhagwan/fzf-lua",
    keys = { "<leader>ff", "<leader>fg", "<leader>fb" },
    config = function()
      require("fzf-lua").setup({
        winopts = { preview = { layout = "vertical" } },
      })
      vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Find buffers" })
    end,
  },

  -- Statusline
  {
    "rebelot/heirline.nvim",
    config = function()
      require("heirline").setup({
        statusline = {
          { provider = "%f%m" },
          { provider = "%=%l:%c" },
        },
      })
    end,
  },

  -- Completion
  {
    "hrsh7th/cmp-nvim-lsp",
    dependencies = {
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    event = "InsertEnter",
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "vsnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- LSP
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim", "neovim/nvim-lspconfig", "hrsh7th/cmp-nvim-lsp" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",               -- Lua
          "clangd",               -- C
          "bashls",               -- Bash
          "kotlin_language_server" -- Kotlin
        },
      })
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
            on_attach = function(client, bufnr)
              vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
              vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover documentation" })
              vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename symbol" })
              vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code action" })
            end,
          })
        end,
      })
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "nvim-treesitter/nvim-treesitter-context" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "javascript", "typescript", "markdown", "query" },
        highlight = { enable = true },
        indent = { enable = true },
      })
      require("treesitter-context").setup({ enable = true })
    end,
  },

  -- Git integration
  {
    "tpope/vim-fugitive",
    keys = { "<leader>gs", "<leader>gb" },
    config = function()
      vim.keymap.set("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Open Fugitive" })
      vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<cr>", { desc = "Git blame" })
    end,
  },

  -- Navigation
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = function()
      require("flash").setup()
      vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash jump" })
    end,
  },

  -- Formatting and diagnostics
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.prettier.with({ filetypes = { "javascript", "typescript" } }),
          null_ls.builtins.formatting.black,
        },
      })
      vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format buffer" })
    end,
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    ft = "markdown",
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Toggle Markdown preview" })
    end,
  },

  -- Distraction-free writing
  {
    "folke/zen-mode.nvim",
    keys = { "<leader>z" },
    config = function()
      require("zen-mode").setup({
        window = { width = 90, options = { number = false, relativenumber = false } },
      })
      vim.keymap.set("n", "<leader>z", "<cmd>ZenMode<cr>", { desc = "Toggle Zen mode" })
    end,
  },

  -- Miscellaneous
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    config = function()
      require("dressing").setup()
    end,
  },
  {
    "folke/nvim-notify",
    config = function()
      require("notify").setup({ background_colour = "#000000" })
      vim.notify = require("notify")
    end,
  },
  {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = { "<leader>s" },
    config = function()
      require("spectre").setup()
      vim.keymap.set("n", "<leader>s", "<cmd>lua require('spectre').open()<cr>", { desc = "Open Spectre search" })
    end,
  },
})


vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})
