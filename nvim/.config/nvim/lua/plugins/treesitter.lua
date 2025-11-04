return {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    branch = 'master',
    build = ':TSUpdate',
    opts = {
        ensure_installed = { 'lua', 'rust', 'clojure', 'java', 'vim', 'vimdoc' },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
            enable = true
        },
    },
    config = function (_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end
}
