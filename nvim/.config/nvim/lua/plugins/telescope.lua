return {
    "nvim-telescope/telescope.nvim", tag = '0.1.8',
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
        {"<leader>fg", function() require("telescope.builtin").live_grep() end,
            desc="Rip grep in project"},
        {"<leader>fw", function() require("telescope.builtin").grep_string() end,
            desc="Search for word under cursor"},
        {"<leader>fh", function() require("telescope.builtin").help_tags() end,
            desc="Find help tags"},
    },
}
