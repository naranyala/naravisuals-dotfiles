-- ~/.config/nvim/init.lua

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

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Basic Neovim settings
vim.opt.number = true          -- Line numbers
vim.opt.relativenumber = true  -- Relative line numbers
vim.opt.wrap = false           -- No line wrapping
vim.opt.tabstop = 2            -- 2 spaces for tabs
vim.opt.shiftwidth = 2         -- 2 spaces for indentation
vim.opt.expandtab = true       -- Use spaces instead of tabs
vim.opt.termguicolors = true   -- Enable true colors

-- Enable English spell-checking
vim.opt.spell = true
vim.opt.spelllang = { "en_us" }
vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
vim.keymap.set("n", "<leader>ss", "zg", { desc = "Add word to spellfile" })
vim.keymap.set("n", "<leader>sc", "]s", { desc = "Next spelling error" })
vim.keymap.set("n", "<leader>sC", "[s", { desc = "Previous spelling error" })

-- Plugin specifications
require("lazy").setup({
  -- Treesitter for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua_ls",               -- Lua
          "clangd",               -- C
          "bashls",               -- Bash
          "kotlin_language_server" -- Kotlin
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Gen.nvim for LLM interaction
  {
    "David-Kunz/gen.nvim",
    config = function()
      local gen = require("gen")
      gen.setup({
        model = "mistral", -- Default model (Ollama)
        display_mode = "split", -- Show responses in a vertical split
        show_prompt = true, -- Show the prompt sent to the LLM
        show_model = true, -- Show the model name in responses
      })
      -- Define multiple LLMs
      gen.models = {
        mistral = { provider = "ollama", model = "mistral" },
        llama3 = { provider = "ollama", model = "llama3" },
        grok = {
          provider = "custom",
          command = function(options)
            return {
              "curl",
              "--request", "POST",
              "--url", "https://api.x.ai/v1/grok",
              "--header", "Authorization: Bearer " .. os.getenv("XAI_API_KEY"),
              "--header", "Content-Type: application/json",
              "--data", vim.json.encode({
                model = "grok-3",
                prompt = options.prompt,
                max_tokens = 2048,
                temperature = 0.7,
              }),
            }
          end,
          parse = function(data)
            local response = vim.json.decode(data)
            return response.choices[1].text
          end,
        },
        openai = {
          provider = "custom",
          command = function(options)
            return {
              "curl",
              "--request", "POST",
              "--url", "https://api.openai.com/v1/chat/completions",
              "--header", "Authorization: Bearer " .. os.getenv("OPENAI_API_KEY"),
              "--header", "Content-Type: application/json",
              "--data", vim.json.encode({
                model = "gpt-4o",
                messages = { { role = "user", content = options.prompt } },
                max_tokens = 2048,
                temperature = 0.7,
              }),
            }
          end,
          parse = function(data)
            local response = vim.json.decode(data)
            return response.choices[1].message.content
          end,
        },
      }
      -- Keybindings for LLM interaction
      vim.keymap.set("n", "<leader>ll", ":Gen<CR>", { desc = "Run LLM on selection" })
      vim.keymap.set("v", "<leader>ll", ":Gen<CR>", { desc = "Run LLM on selection" })
      vim.keymap.set("n", "<leader>lm", function()
        vim.ui.select(vim.tbl_keys(gen.models), { prompt = "Select LLM model:" }, function(choice)
          if choice then
            gen.model = choice
            print("Switched to model: " .. choice)
          end
        end)
      end, { desc = "Switch LLM model" })
    end,
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    build = "cd app && npm install",
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_browser = "firefox" -- Change to your preferred browser
      vim.keymap.set("n", "<leader>mp", ":MarkdownPreviewToggle<CR>", { desc = "Toggle Markdown Preview" })
    end,
  },

  -- Zk for note-taking
  -- {
  --   "zk-nvim/zk",
  --   config = function()
  --     require("zk").setup({
  --       picker = "telescope",
  --       lsp = { config = { cmd = { "zk", "lsp" }, name = "zk" } },
  --     })
  --     vim.keymap.set("n", "<leader>zn", ":ZkNew { title = vim.fn.input('Title: ') }<CR>", { desc = "New Zk Note" })
  --     vim.keymap.set("n", "<leader>zf", ":ZkNotes<CR>", { desc = "Find Zk Notes" })
  --   end,
  -- },

  -- Telescope for fuzzy finding
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          mappings = {
            i = { ["<C-j>"] = "move_selection_next", ["<C-k>"] = "move_selection_previous" },
          },
        },
      })
      vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live Grep" })
    end,
  },

  -- Autocompletion with nvim-cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
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
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Which-key for keybinding hints
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup({
        plugins = { spelling = { enabled = true } },
      })
      vim.keymap.set("n", "<leader>?", ":WhichKey<CR>", { desc_evaluation = "Show Keybindings" })
    end,
  },
}, {
  performance = {
    rtp = {
      disabled_plugins = { "netrwPlugin" }, -- Disable netrw for faster startup
    },
  },
})

-- Optional: Set up LSP for Python
require("lspconfig").pyright.setup({}) -- For Python research scripts


vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})
