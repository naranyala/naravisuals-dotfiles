local function show_blame(file)
    local repo = vim.fn.system('git rev-parse --show-toplevel'):gsub('\n', '')
    local cmd = { 'nvim-gitanalyze', repo, '--file=' .. file, '--blame', '--json' }
    local result = vim.system(cmd):wait()
    if result.code == 0 then
        local blames = vim.json.decode(result.stdout)
        for _, b in ipairs(blames) do
            -- Add virtual text or signs
            vim.api.nvim_buf_set_extmark(0, vim.api.nvim_create_namespace(''), b.line_start - 1, 0, {
                virt_text = {{ b.author .. ' (' .. b.commit_id:sub(1,7) .. ')', 'Comment' }},
                virt_text_pos = 'right_align'
            })
        end
    else
        vim.notify("Git analyze failed: " .. result.stderr, vim.log.levels.ERROR)
    end
end

-- Keymap example
vim.keymap.set('n', '<leader>gb', function() show_blame(vim.fn.expand('%')) end, { desc = 'Show Git blame' })
