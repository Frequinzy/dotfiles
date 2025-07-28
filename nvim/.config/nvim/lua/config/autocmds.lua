-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        vim.cmd([[silent! keepjumps keeppatterns %s/\s\+$//e]])
    end,
})
