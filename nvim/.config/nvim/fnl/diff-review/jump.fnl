;; Resolves an overview cursor position into a real {file line col} target
;; and opens it. Deleted lines are real buffer lines (scrollable/searchable/
;; selectable, unlike virt_lines) but are never entered into `line-map`, so
;; `resolve` just returns nil for them -- <CR>/<C-CR> on one is a no-op.

(local gutter-width 2)

(fn resolve [line-map lnum col]
  "line-map: {lnum -> {file-idx source-line}}. col: 0-indexed cursor column.
  Returns {file-idx source-line source-col} or nil if `lnum` isn't a mapped
  diff line (header/separator/hunk-line)."
  (let [entry (. line-map lnum)]
    (when entry
      {:file-idx entry.file-idx
       :source-line entry.source-line
       :source-col (math.max 0 (- col gutter-width))})))

(fn open-file [root files target]
  "Opens the real file for `target` (from `resolve`) in the current window,
  replacing the overview buffer there (bufhidden=hide keeps it alive), with
  the cursor at the exact line+column. `:edit` in-place is what makes <C-o>
  return to the overview -- Neovim's jumplist is per-window, so a jump only
  gets recorded when the target and source share a window."
  (let [file (. files target.file-idx)
        abs (.. root "/" file.path)]
    (vim.cmd.edit (vim.fn.fnameescape abs))
    (vim.api.nvim_win_set_cursor 0 [target.source-line target.source-col])
    (vim.cmd "normal! zz")))

{: resolve : open-file}
