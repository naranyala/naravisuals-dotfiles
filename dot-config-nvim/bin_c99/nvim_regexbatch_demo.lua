local function batch_regex(dir, pattern, replace)
    local cmd = { 'nvim-regexbatch', dir, '--pattern=' .. pattern, '--replace=' .. replace, '--recursive' }
    local job_id = vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            -- Update quickfix or notify
            vim.fn.setqflist({}, 'r', { title = 'Regex Batch', lines = data })
            vim.cmd('copen')
        end,
        on_stderr = function(_, data) vim.notify(table.concat(data, '\n'), vim.log.levels.ERROR) end,
    })
    if job_id == 0 then vim.notify("Job failed to start", vim.log.levels.ERROR) end
end

-- Command example
vim.api.nvim_create_user_command('BatchRegex', function(opts) batch_regex(opts.args[1], opts.args[2], opts.args[3]) end, { nargs = 3 })
