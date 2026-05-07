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
      vim.opt.wrap = false
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.termguicolors = true
      vim.opt.cursorline = true
      vim.opt.signcolumn = "yes"
      vim.opt.updatetime = 250
      vim.opt.timeoutlen = 400
      vim.opt.clipboard = "unnamedplus"
      vim.opt.mouse = "a"
      vim.opt.scrolloff = 8
      vim.opt.sidescrolloff = 8
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
          vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
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
        pattern = { "help", "man", "lspinfo", "qf", "neo-tree" },
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
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require("rose-pine").setup({ variant = "moon" })
      vim.cmd.colorscheme("rose-pine-moon")
    end,
  },

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    keys = { "<leader>e" },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        window = { width = 30 },
        filesystem = { filtered_items = { visible = true } },
      })
      vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle file explorer" })
    end,
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = { "<leader>ff", "<leader>fg", "<leader>fb" },
    config = function()
      require("telescope").setup({
        extensions = { fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true } },
      })
      require("telescope").load_extension("fzf")
      vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
    end,
  },

  -- Statusline
  {
    "feline-nvim/feline.nvim",
    config = function()
      require("feline").setup({
        components = {
          active = {
            { { provider = "file_info", icon = " " }, { provider = "git_branch" } },
            { { provider = "diagnostic_errors" }, { provider = "diagnostic_warnings" } },
          },
        },
      })
    end,
  },

  -- Completion
  {
    "ms-jpq/coq_nvim",
    branch = "coq",
    dependencies = { "ms-jpq/coq.artifacts" },
    event = "InsertEnter",
    config = function()
      vim.g.coq_settings = {
        auto_start = "shut-up",
        keymap = { recommended = true },
        clients = { lsp = { enabled = true }, snippets = { enabled = true }, paths = { enabled = true } },
      }
    end,
  },

  -- LSP
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },


  -- Syntax highlighting
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim", "neovim/nvim-lspconfig", "ms-jpq/coq_nvim" },
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
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = vim.g.coq_settings.clients.lsp.capabilities,
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
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "javascript", "typescript", "go", "vim" },
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = { enable = true, keymaps = {
          init_selection = "<C-n>",
          node_incremental = "<C-n>",
          node_decremental = "<C-p>",
        }},
      })
    end,
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { buffer = bufnr, desc = "Stage hunk" })
          vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { buffer = bufnr, desc = "Reset hunk" })
          vim.keymap.set("n", "<leader>gb", gs.blame_line, { buffer = bufnr, desc = "Blame line" })
        end,
      })
    end,
  },
  {
    "kdheepak/lazygit.nvim",
    keys = { "<leader>gg" },
    config = function()
      vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "Open LazyGit" })
    end,
  },

  -- Navigation
  {
    "ggandor/leap.nvim",
    config = function()
      require("leap").create_default_mappings()
    end,
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    keys = { "<leader>f" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "black" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          go = { "gofmt" },
        },
        format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
      })
      vim.keymap.set("n", "<leader>f", function() require("conform").format({ async = true }) end, { desc = "Format buffer" })
    end,
  },

  -- Terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = { "<leader>t" },
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = "<leader>t",
        direction = "float",
        float_opts = { border = "curved" },
      })
    end,
  },

  -- Miscellaneous
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup()
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("todo-comments").setup()
      vim.keymap.set("n", "<leader>td", "<cmd>TodoTelescope<cr>", { desc = "Show TODOs" })
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
