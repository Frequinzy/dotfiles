function LineNumberColors()
    local color = "#e83d84"
    vim.api.nvim_set_hl(0, "LineNrAbove", { fg=color, bold=true })
    vim.api.nvim_set_hl(0, "LineNr", { fg="white", bold=true })
    vim.api.nvim_set_hl(0, "LineNrBelow", { fg=color, bold=true })
end

return {
    {
        "datasektionen/dsekt.nvim",
        priority = 1000,
    },
    {
        "olimorris/onedarkpro.nvim",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme "onedark"
            LineNumberColors()
        end
    }
}
