return {
    "nvim-lspconfig",
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
            local function keybind(...)
                vim.api.nvim_buf_set_keymap(bufnr, ...)
            end
            local opts = { noremap = true, silent = true }

            keybind("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
            keybind("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
            keybind("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
            keybind("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
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
