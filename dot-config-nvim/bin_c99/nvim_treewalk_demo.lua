local function refresh_tree(dir)
    local cmd = { 'nvim-treewalk', dir, '--filter=*.lua,*.vim', '--depth=5', '--json' }
    local result = vim.system(cmd):wait()
    if result.code == 0 then
        local files = vim.json.decode(result.stdout)
        -- Update your buffer/tree view here, e.g.:
        vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.tbl_map(function(f) return f.path end, files))
    else
        vim.notify("Tree walk failed: " .. result.stderr, vim.log.levels.ERROR)
    end
end

-- Keymap example
vim.keymap.set('n', '<leader>rt', function() refresh_tree(vim.fn.getcwd()) end, { desc = 'Refresh file tree' })
