-- LSP Configuration

-- Enable Servers, configured in lsp/<name>
vim.lsp.enable('lua_ls')
vim.lsp.enable('rust_analyzer')

-- Set up LSP functionality
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp', {}),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        -- Autocomplete
        if client:supports_method('textDocument/completion') then
            vim.opt.completeopt = { 'fuzzy', 'menu', 'menuone', 'noinsert', 'popup' }
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end
    end
})
