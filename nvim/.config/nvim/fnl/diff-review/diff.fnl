;; Pure hunk computation: wraps `vim.text.diff` and normalizes its
;; {start_a count_a start_b count_b} index tuples into hunks carrying actual
;; line slices, so nothing downstream touches `vim.text.diff` directly.
;; No git/IO dependency.

(fn lines->text [lines]
  "Every line list is treated as newline-terminated (like a normal source
  file) so appending lines at EOF doesn't spuriously diff the previous last
  line against itself due to a missing trailing newline."
  (if (= (length lines) 0) "" (.. (table.concat lines "\n") "\n")))

(fn slice [lines first count]
  (if (= count 0)
      []
      (let [out []]
        (for [i first (+ first count -1)]
          (table.insert out (. lines i)))
        out)))

(fn compute-hunks [old-lines new-lines]
  "old-lines/new-lines: 1-indexed arrays of strings (no embedded newlines).
  Returns a list of hunks: {old-start old-count new-start new-count
  old-lines new-lines}, in the same {start count} convention vim.text.diff
  uses (count = 0 means a pure insertion/deletion anchored after `start`)."
  (let [indices (vim.text.diff (lines->text old-lines) (lines->text new-lines)
                               {:result_type :indices})]
    (icollect [_ [old-start old-count new-start new-count] (ipairs indices)]
      {: old-start
       : old-count
       : new-start
       : new-count
       :old-lines (slice old-lines old-start old-count)
       :new-lines (slice new-lines new-start new-count)})))

{: compute-hunks}
