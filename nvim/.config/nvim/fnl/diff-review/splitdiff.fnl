;; <C-CR>: native split diff-mode, in a disposable new tab. Left window is a
;; scratch buffer holding the old (git) blob; right window is the real file
;; buffer, so LSP/existing buffer state on the new side just works. Window-
;; local diff options are set directly (equivalent to :diffthis per window)
;; -- no explicit teardown needed since :tabclose discards window-local
;; options for free. `q` on the scratch buffer jumps back to the DiffReview
;; tab explicitly, since :tabclose's own "which tab next" heuristic isn't
;; guaranteed to land there once more than two tabs are open.

(local git (require :diff-review.git))
(local config (require :diff-review.config))

(fn apply-diff-winopts [win]
  (each [_ [name val] (ipairs [[:diff true]
                               [:scrollbind true]
                               [:cursorbind true]
                               [:foldmethod :diff]
                               [:foldenable true]
                               [:foldcolumn :1]])]
    (vim.api.nvim_set_option_value name val {: win})))

(fn back-to-overview [overview-tab]
  (vim.cmd.tabclose)
  (when (vim.api.nvim_tabpage_is_valid overview-tab)
    (vim.api.nvim_set_current_tabpage overview-tab)))

(fn open [root ref files target overview-tab]
  (let [file (. files target.file-idx)
        abs-new (.. root "/" file.path)]
    (set vim.o.scrollopt "ver,hor,jump")
    (git.old-content root ref file.old-path
                     (fn [old-lines]
                       (vim.schedule (fn []
                                       (vim.cmd.tabnew)
                                       (let [win-old (vim.api.nvim_get_current_win)
                                             scratch (vim.api.nvim_create_buf false
                                                                              true)]
                                         (vim.api.nvim_buf_set_lines scratch 0
                                                                     -1 false
                                                                     old-lines)
                                         (vim.api.nvim_set_option_value :buftype
                                                                        :nofile
                                                                        {:buf scratch})
                                         (vim.api.nvim_set_option_value :bufhidden
                                                                        :wipe
                                                                        {:buf scratch})
                                         (vim.api.nvim_set_option_value :modifiable
                                                                        false
                                                                        {:buf scratch})
                                         (pcall vim.api.nvim_buf_set_name
                                                scratch
                                                (.. "diff-review://" ref "/"
                                                    file.old-path))
                                         (vim.api.nvim_win_set_buf win-old
                                                                   scratch)
                                         (vim.keymap.set :n
                                                         config.keymaps.close
                                                         #(back-to-overview overview-tab)
                                                         {:buffer scratch
                                                          :silent true
                                                          :nowait true
                                                          :desc "Diff review: back to overview"})
                                         (vim.cmd.vsplit)
                                         (let [win-new (vim.api.nvim_get_current_win)]
                                           (vim.cmd.edit (vim.fn.fnameescape abs-new))
                                           (let [real-buf (vim.api.nvim_win_get_buf win-new)
                                                 ft (vim.api.nvim_get_option_value :filetype
                                                                                   {:buf real-buf})]
                                             (vim.api.nvim_set_option_value :filetype
                                                                            ft
                                                                            {:buf scratch})
                                             (vim.keymap.set :n
                                                             config.keymaps.close
                                                             #(back-to-overview overview-tab)
                                                             {:buffer real-buf
                                                              :silent true
                                                              :nowait true
                                                              :desc "Diff review: back to overview"})
                                             ;; Buffer-local keymaps outlive the window --
                                             ;; without this, `q` would stay hijacked on
                                             ;; this real file forever (breaking normal
                                             ;; macro record/stop) after the split closes.
                                             (vim.api.nvim_create_autocmd :WinClosed
                                                                          {:pattern (tostring win-new)
                                                                           :once true
                                                                           :callback #(pcall vim.keymap.del
                                                                                             :n
                                                                                             config.keymaps.close
                                                                                             {:buffer real-buf})}))
                                           (pcall vim.api.nvim_win_set_cursor
                                                  win-new
                                                  [target.source-line
                                                   target.source-col])
                                           (apply-diff-winopts win-old)
                                           (apply-diff-winopts win-new)
                                           (vim.cmd :diffupdate)
                                           (vim.api.nvim_set_current_win win-new)
                                           (vim.cmd "normal! zz")))))))))

{: open}
