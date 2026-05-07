local function apply_highlights(file)
    local cmd = { 'nvim-synhigh', file, '--lang=markdown', '--format=json' }
    local result = vim.system(cmd):wait()
    if result.code == 0 then
        local tokens = vim.json.decode(result.stdout)
        local ns = vim.api.nvim_create_namespace('synhigh')
        for _, t in ipairs(tokens) do
            vim.api.nvim_buf_add_highlight(0, ns, t.type == 'header' and 'Title' or 'Bold', 0, t.start, t.end)
        end
    else
        vim.notify("Syntax high failed: " .. result.stderr, vim.log.levels.ERROR)
    end
end

-- Autocmd example
vim.api.nvim_create_autocmd('BufReadPost', {
    pattern = '*.md',
    callback = function() apply_highlights(vim.fn.expand('%')) end,
})
