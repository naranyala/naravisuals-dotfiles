-- SINGLE FILE NEOVIM CONFIG



-- require("setup_alt_001")
-- require("setup_alt_002")
-- require("setup_alt_003")


require("setup_crust_mode");
-- require("setup_ultimate")

-- require("setup_jsvue_mode") -- SOMETHING BROKEN
-- require("setup_casm_mode") -- BEST
-- require("setup_bare_minimum")

-- require("lib.gittutor").setup()
-- require("lib.linuxtutor").setup()
require("lib._sharedlib")
require("lib.ok_features")
require("lib.ok_vue_snippets")
require("lib.ok_c99_snippets")
require("lib.umka_as_c")

-- require("lib_grepnav").setup()
-- require("lib.simplenav")
-- require("lib.simplenav").setup()
-- require("lib.theme_paperlike_day").setup()
-- require("lib.theme_paperlike_night").setup()

require("lib.bookmark_by_line").setup()
-- require("lib.bookmark_by_file").setup()
-- require("lib.disable_tabline")
require("lib.ag_filepicker")
require("lib.display_startup_err")
require("lib.todo_search").setup()

require("lib.grepnav").setup({
    engine_priority = { "rg" }, -- never fall back to plain grep
    root_markers = { ".git", "pyproject.toml", ".root" },
    ignore = { ".git", "node_modules", "venv", "build", "*.min.js" },
    rg_args = "--vimgrep --no-heading --smart-case --type-add 'ts:*.tsx' --type-add 'vue:*.vue'",
    window_height_ratio = 0.5,
    mappings = true,
})


-- prevent command bar grow
vim.keymap.set("n", "<C-Up>", "<Nop>")
vim.keymap.set("n", "<C-Down>", "<Nop>")
vim.keymap.set("n", "<C-Left>", "<Nop>")
vim.keymap.set("n", "<C-Right>", "<Nop>")

-- vim.keymap.set("n", "<leader>mi", function()
--   vim.cmd([[g/^!.*\]\(.*\)/norm I<!-- ]])
--   vim.cmd([[g/^!.*\]\(.*\)/norm A -->]])
-- end, { desc = "Block all markdown images" })


vim.keymap.set("n", "<leader>xmi", function()
  vim.cmd([[g/^!.*\]\(.*\)/d]])
end, { desc = "Delete markdown images directly" })



-- require('lib.suckless_infobar').setup({
--     sources = {
--         -- { section = "left",   name = "get_uptime", cli = "../../../my-c-exploration/bin/get_uptime" },
--         { section = "center", name = "random", cli = "echo 'hello'" },
--        -- { section = "right",  name = "cpu_ram_usage",   cli = "../../../my-c-exploration/bin/cpu_ram_usage" },
--     },
--      separator = " │ ",
--      padding = { center = 4 }, -- extra space around center
--      debug = false,
--  })


-- require('lib.suckless_infobar').setup({
--   sources = {
--         { section = "left",   name = "get_uptime", mode="stream", cli = "../my-c-exploration/bin/get_uptime" },
--         {
--           section = "left",
--           name = "git",
--           cli = "git",
--           args = {"branch", "--show-current"},
--           mode = "oneshot",
--           interval = 30,  -- refresh every 30 seconds
--           timeout = 3
--         },
--
--         { section = "right",  name = "cpu_ram_usage", mode="stream",  cli = "../my-c-exploration/bin/cpu_ram_usage" },
--   },
--   separator = " │ ",
--   padding   = { center = 4 },
--   debug     = false,
--   click     = false,   -- set true to enable mouse
-- })


-- NO VERTICAL DIVIDER
-- vim.wo.colorcolumn = ""
-- vim.wo.signcolumn = "no"
-- vim.wo.foldcolumn = "0"
-- vim.o.fillchars = "vert: "
