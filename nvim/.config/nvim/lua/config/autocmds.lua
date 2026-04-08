-- Remove trailing whitespace on save
vim.api.nvim_create_augroup('TrailingWhitespace', { clear = true })

vim.api.nvim_create_autocmd('BufWritePre', {
    group = 'TrailingWhitespace',
    pattern = '*',
    callback = function()
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd([[silent! keepjumps keeppatterns %s/\s\+$//e]])
        pcall(vim.api.nvim_win_set_cursor, 0, pos)
    end,
})
