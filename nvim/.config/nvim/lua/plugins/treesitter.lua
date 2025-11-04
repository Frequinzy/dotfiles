return {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    branch = 'master',
    build = ':TSUpdate',
    opts = {
        ensure_installed = { 'lua', 'rust', 'vim', 'vimdoc' },
        indent = {
            enable = true
        },
    },
    config = function (_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end
}
