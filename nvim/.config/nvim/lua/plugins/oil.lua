return {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
    opts = {},
    keys = {
        { '-', function() require('oil').open() end, desc='Open Parent Directory' },
    },
}
