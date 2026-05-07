return {
  -- Treesitter – rock-solid parsing
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufReadPre",
    dependencies = { 
      -- "nvim-treesitter/nvim-treesitter-textobjects" 
  },
    config = function()
      require("nvim-treesitter.configs").setup({
        -- ensure_installed = { "c", "cpp", "rust", "zig", "bash", "make", "cmake", "lua", "toml", "json", "c3" },
        ensure_installed = { "c", "cpp", "rust", "zig", "bash", "make", "cmake", "lua", "toml", "json" },
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = { enable = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
        },
      })
    end,
  },

  -- LSP + Mason + Completion
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/nvim-cmp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "rust_analyzer", "zls", "lua_ls" },
        automatic_installation = true,
      })

      local cmp = require("cmp")
      cmp.setup({
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        window = { completion = cmp.config.window.bordered(), documentation = cmp.config.window.bordered() },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<C-e>"] = cmp.mapping.abort(),
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
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 800 },
          { name = "buffer",   priority = 500 },
          { name = "path",     priority = 250 },
        }),
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      -- local lsp = require("lspconfig")

      -- vim.lsp.setup('clangd', { capabilities = capabilities })
      --
      -- vim.lsp.setup('rust_analyzer', {
      --   capabilities = capabilities,
      --   settings = {
      --     ["rust-analyzer"] = {
      --       check = { command = "clippy" },
      --       cargo = { allFeatures = true },
      --       procMacro = { enable = true },
      --     },
      --   },
      -- })
      --
      -- vim.lsp.setup('zls', { capabilities = capabilities })
      --
      -- vim.lsp.setup('lua_ls', {
      --   capabilities = capabilities,
      --   settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      -- })

    end,
  },

}
