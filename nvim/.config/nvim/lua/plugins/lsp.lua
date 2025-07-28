return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp"
    },
    config = function ()
        require("mason").setup()

        require("mason-lspconfig").setup()


        local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

        local on_attach = function(client, bufnr)
            local opts = { buffer=bufnr, noremap = true, silent = true }

            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "<leader>qe", function()
                vim.diagnostic.setqflist({
                    severity = vim.diagnostic.severity.ERROR,
                    open = false,
                    namespace = nil,
                })
            end, { noremap = true, silent = true })
        end

        require("mason-lspconfig").setup_handlers {
            function (server_name)
                require("lspconfig")[server_name].setup({
                    on_attach = on_attach,
                    capabilities = lsp_capabilities,
                    settings = {
                        Lua = {
                            diagnostics = { globals = {"vim"} }
                        }
                    },
                })
            end,
        }
    end,
}
