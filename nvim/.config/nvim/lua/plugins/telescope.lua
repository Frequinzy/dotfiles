return {
    "nvim-telescope/telescope.nvim", tag = '0.1.2',
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
        defaults = {
            mappings = {
                n = {
                    ["q"] = function(...)
                        return require("telescope.actions").close(...)
                    end,
                },
            },
        },
    },
    keys = {
        {"<leader>ff", function() require("telescope.builtin").find_files() end,
        desc="Find files"},
    },
}
