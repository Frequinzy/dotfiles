return {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        highlight = { enable = true, },
        ensure_installed = { "c", "lua", "rust", "vim", "vimdoc", "query" },
        sync_install = false,
    },
    config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
    end,
}
