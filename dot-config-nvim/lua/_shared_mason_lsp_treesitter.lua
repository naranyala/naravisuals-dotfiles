-- File: lua/plugins/devtools.lua
-- Elite Systems Programming Setup (C/C++/Zig/C3/Rust/Kernel/Embedded)
-- Requires: Neovim ≥0.10 (vim.lsp.config API)

return {
  -- Mason: LSP installer
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    keys = { { "<leader>m", "<cmd>Mason<cr>", desc = "Mason" } },
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- Mason LSP bridge
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "clangd",        -- C/C++/CUDA
        "zls",           -- Zig
        "rust_analyzer", -- Rust
        -- "cmake",         -- CMake
        -- "asm_lsp",       -- Assembly (x86/ARM/RISC-V)
      },
      automatic_installation = true,
    },
  },

  -- Treesitter: syntax highlighting on steroids
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      { "<c-space>", desc = "Increment selection" },
      { "<bs>",      desc = "Decrement selection", mode = "x" },
    },
    opts = {
      ensure_installed = {
        -- Core systems languages
        "c", "cpp", "objc", "objcpp", "cuda",
        "zig", "rust", "asm",

        -- Build systems & scripting
        "bash", "make",
        -- "cmake", "meson",

        -- Embedded/Kernel
        "devicetree",   -- DTS files
        "kconfig",      -- Linux Kconfig
        "linkerscript", -- LD scripts

        -- DevOps
        "dockerfile", "yaml", "toml", "json",

        -- Version control
        "diff", "git_rebase", "gitcommit", "gitignore",
      },

      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },

      indent = { enable = true },

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<c-space>",
          node_incremental = "<c-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    },
    config = function(_, opts)
      -- require("nvim-treesitter.configs").setup(opts)

      -- -- C3 external grammar (not in default registry)
      -- local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      -- parser_config.c3 = {
      --   install_info = {
      --     url = "https://github.com/c3lang/tree-sitter-c3",
      --     files = { "src/parser.c", "src/scanner.c" },
      --     branch = "main",
      --   },
      --   filetype = "c3",
      -- }
    end,
  },

  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    keys = {
      { "gd",         vim.lsp.buf.definition,      desc = "Go to definition" },
      { "gD",         vim.lsp.buf.declaration,     desc = "Go to declaration" },
      { "gr",         vim.lsp.buf.references,      desc = "References" },
      { "gi",         vim.lsp.buf.implementation,  desc = "Implementation" },
      { "gt",         vim.lsp.buf.type_definition, desc = "Type definition" },
      { "K",          vim.lsp.buf.hover,           desc = "Hover docs" },
      { "<leader>rn", vim.lsp.buf.rename,          desc = "Rename" },
      { "<leader>ca", vim.lsp.buf.code_action,     desc = "Code action" },
      { "<leader>f",  vim.lsp.buf.format,          desc = "Format" },
      { "[d",         vim.diagnostic.goto_prev,    desc = "Previous diagnostic" },
      { "]d",         vim.diagnostic.goto_next,    desc = "Next diagnostic" },
      { "<leader>e",  vim.diagnostic.open_float,   desc = "Show diagnostic" },
    },
    config = function()
      -- Diagnostics UI
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded" },
      })

      -- LSP handlers with borders
      local handlers = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
        ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
      }

      -- Enhanced capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      -- C/C++/CUDA - clangd
      vim.lsp.config("clangd", {
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
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        root_markers = {
          "compile_commands.json",
          "compile_flags.txt",
          ".clangd",
          ".git",
        },
        capabilities = capabilities,
        handlers = handlers,
      })

      -- Zig - zls
      vim.lsp.config("zls", {
        cmd = { "zls" },
        filetypes = { "zig" },
        root_markers = { "build.zig", ".git" },
        capabilities = capabilities,
        handlers = handlers,
      })

      -- Rust - rust-analyzer
      vim.lsp.config("rust_analyzer", {
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
        root_markers = { "Cargo.toml", ".git" },
        settings = {
          ["rust-analyzer"] = {
            check = { command = "clippy" },
            procMacro = { enable = true },
            cargo = {
              allFeatures = true,
              buildScripts = { enable = true },
            },
            inlayHints = {
              bindingModeHints = { enable = false },
              chainingHints = { enable = true },
              closingBraceHints = { enable = true, minLines = 25 },
              closureReturnTypeHints = { enable = "never" },
              lifetimeElisionHints = { enable = "never" },
              maxLength = 25,
              parameterHints = { enable = true },
              reborrowHints = { enable = "never" },
              renderColons = true,
              typeHints = { enable = true, hideNamedConstructor = false },
            },
          },
        },
        capabilities = capabilities,
        handlers = handlers,
      })

      -- CMake
      -- vim.lsp.config("cmake", {
      --   cmd = { "cmake-language-server" },
      --   filetypes = { "cmake" },
      --   root_markers = { "CMakeLists.txt", ".git" },
      --   init_options = { buildDirectory = "build" },
      --   capabilities = capabilities,
      --   handlers = handlers,
      -- })

      -- Assembly
      if vim.fn.executable("asm-lsp") == 1 then
        vim.lsp.config("asm_lsp", {
          cmd = { "asm-lsp" },
          filetypes = { "asm", "s", "S" },
          capabilities = capabilities,
          handlers = handlers,
        })
      end

      -- -- C3 (manual install required)
      -- if vim.fn.executable("c3lsp") == 1 then
      --   vim.lsp.config("c3_lsp", {
      --     cmd = { "c3lsp", "--stdio" },
      --     filetypes = { "c3" },
      --     root_markers = { "project.json", ".git" },
      --     capabilities = capabilities,
      --     handlers = handlers,
      --   })
      -- end

      -- Auto-attach LSP to buffers
      vim.api.nvim_create_autocmd("FileType", {
        -- pattern = { "c", "cpp", "objc", "objcpp", "cuda", "zig", "rust", "cmake", "asm", "c3" },
        pattern = { "c", "cpp", "objc", "objcpp", "cuda", "zig", "rust", "asm" },
        callback = function()
          -- local ft = vim.bo.filetype
          -- local server_name = ft == "c3" and "c3_lsp"
          --     or ft == "cmake" and "cmake"
          --     or (ft == "asm" or ft == "s" or ft == "S") and "asm_lsp"
          --     or ft
          --
          -- vim.lsp.start({
          --   name = server_name,
          --   reuse_client = function(client, config)
          --     return client.name == config.name
          --         and vim.fs.dirname(client.config.root_dir) == vim.fs.dirname(config.root_dir)
          --   end,
          -- })
        end,
      })

      -- Show line diagnostics on cursor hold
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          local opts = {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = "rounded",
            source = "always",
            prefix = " ",
            scope = "cursor",
          }
          vim.diagnostic.open_float(nil, opts)
        end,
      })
    end,
  },
}
