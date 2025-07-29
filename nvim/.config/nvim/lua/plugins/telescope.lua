return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    lazy = false,
    dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    opts = {
        extensions = {
            fzf = {}
        }
    },
    config = function(_, opts)
        local telescope = require('telescope')
        telescope.setup(opts)
        telescope.load_extension('fzf')
    end,
    keys = {
        { '<leader>ff', function() require('telescope.builtin').find_files() end, desc = 'Find Files' },
        { '<leader>fh', function() require('telescope.builtin').help_tags() end, desc = 'Find Help' },
        { '<leader>fg', function() require('telescope.builtin').live_grep() end, desc = 'Find Grep' },
    }
}
