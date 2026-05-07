return {

  -- Essential LSP setup
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      -- Mason for LSP management
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "rust_analyzer", "zls", "lua_ls" },
        automatic_installation = true,
      })

      -- CMP setup
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
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- LSP keymaps and config
      local on_attach = function(client, bufnr)
        local nmap = function(keys, func, desc)
          if desc then desc = "LSP: " .. desc end
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
        end

        nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
        nmap("K", vim.lsp.buf.hover, "Hover Documentation")
        nmap("gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
        nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        nmap("gr", vim.lsp.buf.references, "[G]oto [R]eferences")
        nmap("<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end, "[F]ormat buffer")
      end

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Language servers
      -- local lspconfig = require("lspconfig")
      -- for _, server in ipairs({ "clangd", "rust_analyzer", "zls", "lua_ls" }) do
      --   lspconfig[server].setup({
      --     on_attach = on_attach,
      --     capabilities = capabilities,
      --   })
      -- end

      -- C/C++ specific
      -- vim.lsp.setup('clangd', {
      --   on_attach = on_attach,
      --   capabilities = capabilities,
      --   cmd = {
      --     "clangd",
      --     "--background-index",
      --     "--clang-tidy",
      --     "--header-insertion=iwyu",
      --   },
      -- })
      --
      -- -- Rust specific
      -- vim.lsp.setup('rust_analyzer', {
      --   on_attach = on_attach,
      --   capabilities = capabilities,
      --   settings = {
      --     ["rust-analyzer"] = {
      --       cargo = { allFeatures = true },
      --       checkOnSave = { command = "clippy" },
      --     },
      --   },
      -- })

    end,
  },

  -- Treesitter for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "cpp", "rust", "zig", "lua", "bash", "make", "cmake", "c3" },
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
    end,
  },
}
