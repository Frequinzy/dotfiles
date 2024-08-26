return {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        {"<leader>a", function() require("harpoon.mark").add_file() end, desc="Add Harpoon mark"},
        {"<leader>q", function() require("harpoon.ui").toggle_quick_menu() end, desc="Open Harpoon menu"},
        {"<leader>h", function() require("harpoon.ui").nav_file(1) end, desc="Go to Harpoon mark 1"},
        {"<leader>j", function() require("harpoon.ui").nav_file(2) end, desc="Go to Harpoon mark 2"},
        {"<leader>k", function() require("harpoon.ui").nav_file(3) end, desc="Go to Harpoon mark 3"},
        {"<leader>l", function() require("harpoon.ui").nav_file(4) end, desc="Go to Harpoon mark 4"},
    }
}
