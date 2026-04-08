vim.opt_local.wrap = true
vim.opt_local.spell = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
vim.opt_local.conceallevel = 2

local function vmove(normal, visual)
  return function()
    return vim.v.count > 0 and normal or visual
  end
end

vim.keymap.set({ "n", "x" }, "j", vmove("j", "gj"), { buffer = true, expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", vmove("k", "gk"), { buffer = true, expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "0", "g0", { buffer = true, silent = true })
vim.keymap.set({ "n", "x" }, "$", "g$", { buffer = true, silent = true })
