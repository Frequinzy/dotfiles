(import-macros {: augroup! : plugin!} :macros)
(local {: gh} (require :core.util))

(fn try-attach [buf lang]
  (when (vim.treesitter.language.add lang)
    (vim.treesitter.start buf lang)
    (set vim.bo.indentexpr "v:lua.require'nvim-treesitter'.indentexpr()") ; Is evaluated as a vimscript string. `v:lua` is an escape hatch to lua.
    true))

(plugin! {:src (gh :nvim-treesitter/nvim-treesitter)
          :build (fn [_] (vim.cmd :TSUpdate))
          :setup (fn [ts]
                   (let [installable? #(vim.tbl_contains (ts.get_available) $1)]
                     (augroup! :treesitter
                               [:FileType
                                {:callback (fn [{: buf :match filetype}]
                                             (let [lang (vim.treesitter.language.get_lang filetype)]
                                               (when (and lang
                                                          (not (try-attach buf
                                                                           lang))
                                                          (installable? lang))
                                                 (-> (ts.install lang)
                                                     (: :await
                                                        #(try-attach buf lang))))))}])))})
