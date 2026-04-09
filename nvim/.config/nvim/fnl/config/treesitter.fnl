(import-macros {: augroup!} :macros)

(local treesitter (require :nvim-treesitter))

(fn try-attach [buf lang]
  (when (vim.treesitter.language.add lang)
    (vim.treesitter.start buf lang)
    ; Is evaluated as a vimscript string. `v:lua` is an escape hatch to lua.
    (set vim.bo.indentexpr "v:lua.require'nvim-treesitter'.indentexpr()")
    true))

(local installable-parsers (treesitter.get_available))
(fn installable? [lang]
  (vim.tbl_contains installable-parsers lang))

(augroup! :treesitter
          [:FileType
            {:pattern installable-parsers
            :callback (fn [{: buf :match filetype}]
                         (let [lang (vim.treesitter.language.get_lang filetype)]
                           (when (and
                                   lang
                                   (not (try-attach buf lang))
                                   (installable? lang))
                               (-> (treesitter.install lang)
                                   (: :await #(try-attach buf lang))))))}])
