local function load_symbols(file)
    local cmd = { 'nvim-symparse', file, '--filter=functions', '--json' }
    local result = vim.system(cmd):wait()
    if result.code == 0 then
        local symbols = vim.json.decode(result.stdout)
        -- Populate location list
        local loclist = vim.tbl_map(function(s)
            return { filename = file, lnum = s.line, col = s.col, text = s.name .. ' (' .. s.type .. ')' }
        end, symbols)
        vim.fn.setloclist(0, loclist)
        vim.cmd('lopen')
    else
        vim.notify("Symbol parse failed: " .. result.stderr, vim.log.levels.ERROR)
    end
end

-- Autocmd example
vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*.c,*.h',
    callback = function() load_symbols(vim.fn.expand('%')) end,
})
