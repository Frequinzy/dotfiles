;; :DiffReview [ref] and top-level keymaps. Not a `plugin!` -- there's no
;; :src to fetch, this is entirely custom code, so it's required directly
;; from config/init.fnl instead of going through fnl/plugins/*.

(import-macros {: defcmd!} :macros)
(local overview (require :diff-review.overview))
(local git (require :diff-review.git))
(local config (require :diff-review.config))

(defcmd! :DiffReview
  (fn [opts]
    (overview.open (if (= opts.args "") :HEAD opts.args)))
  {:nargs "?"
   :complete (fn [arglead]
               (let [root (git.root)]
                 (icollect [_ name (ipairs (git.refs root))]
                   (when (= (name:sub 1 (length arglead)) arglead)
                     name))))
   :desc "Review uncommitted changes (or vs [ref])"})

(vim.keymap.set :n :<leader>dr #(overview.open :HEAD)
                {:desc "Diff review (uncommitted)"})

(vim.keymap.set :n :<leader>dR #(overview.open config.default-branch)
                {:desc (.. "Diff review (vs " config.default-branch ")")})
