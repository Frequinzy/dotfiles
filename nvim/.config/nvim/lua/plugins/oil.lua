return {
    "stevearc/oil.nvim",
    lazy = false,
    opts = {},
    keys = {
        {"-", function() require("oil").open() end, desc="Open Parent Directory"},
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
}
