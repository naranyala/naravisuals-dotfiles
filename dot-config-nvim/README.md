
# SINGLE FILE NEOVIM CONFIG

> TODO

```

~/.config/nvim/
├── init.lua                
├── lua/
│   ├── configs.lua
│   ├── langs.lua       
│   ├── lsp_cmp_tresitter.lua               
│   ├── ui_option_a.lua              
│   ├── ui_option_b.lua              
│   ├── others.lua              
│   └── core.lua        
└── lazy-lock.json
```

```
~/.config/nvim/
├── init.lua
├── lua/
│   ├── configs.lua              ← All vim.opt, keymaps, autocmds (outside lazy)
│   ├── langs.lua                ← rustaceanvim + crates.nvim + clangd_extensions
│   ├── lsp_cmp_treesitter.lua   ← lspconfig + mason + cmp + treesitter
│   ├── ui_option_a.lua          ← e.g. catppuccin + lualine + bufferline
│   ├── ui_option_b.lua          ← e.g. tokyonight + heirline + mini.indentlines (alternative UI)
│   ├── others.lua               ← telescope + which-key + gitsigns + comment + surround etc.
│   └── core.lua                 ← small essential plugins (autopairs, mini.nvim, etc.)
└── lazy-lock.json
```
