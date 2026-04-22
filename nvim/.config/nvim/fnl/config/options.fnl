; Leader keys
(set vim.g.mapleader " ")
(set vim.g.maplocalleader ",")

; Disable mouse
(set vim.opt.mouse "")

; Left side-bar
(set vim.opt.number true)
(set vim.opt.relativenumber true)
(set vim.opt.signcolumn :yes)

; Indentation
(set vim.opt.expandtab true)
(set vim.opt.softtabstop 4)
(set vim.opt.shiftwidth 4)

; Complete menu
(set vim.opt.pumborder :rounded)
(set vim.opt.pummaxwidth 40)
(set vim.opt.completeopt [:noselect :fuzzy :menu :menuone :popup])

; Improve searching
(set vim.opt.hlsearch false)
(set vim.opt.ignorecase true)
(set vim.opt.infercase true)
(set vim.opt.smartcase true)

; Misc
(set vim.opt.undofile true)

(set vim.opt.wrap false)

(set vim.opt.scrolloff 8)

(set vim.opt.colorcolumn :80)

(set vim.opt.splitright true)
