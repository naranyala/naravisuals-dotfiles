local function show_diff(file1, file2)
    local cmd = { 'nvim-diffmerge', file1, file2, '--ignore-whitespace' }
    local result = vim.system(cmd):wait()
    if result.code == 0 then
        -- Open a new buffer with diff output
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result.stdout, '\n'))
        vim.api.nvim_buf_set_option(buf, 'filetype', 'diff')
        vim.api.nvim_win_set_buf(0, buf)  -- Or split: vim.cmd('split')
    else
        vim.notify("Diff failed: " .. result.stderr, vim.log.levels.ERROR)
    end
end

-- Command example
vim.api.nvim_create_user_command('ShowDiff', function(opts) show_diff(opts.args[1], opts.args[2]) end, { nargs = 2 })
