;; Treesitter highlighting for the overview's real (added/context) lines,
;; "projection" mode: parse the whole file once so multi-line constructs
;; still parse correctly, then bucket captures by line for O(1) lookup at
;; render time. Deleted lines (virt_lines) are out of scope -- see
;; overview.fnl. Multi-line captures (e.g. block comments) are dropped
;; rather than split across lines; not worth the complexity for content
;; that's mostly being scanned, not read closely.

(fn lang-for [path]
  (let [ft (vim.filetype.match {:filename path})]
    (when ft
      (or (vim.treesitter.language.get_lang ft) ft))))

(fn captures-by-line [parser query text]
  (let [root (: (. (parser:parse) 1) :root)
        by-line {}]
    (each [id node (query:iter_captures root text)]
      (let [(row-start col-start row-end col-end) (node:range)]
        (when (= row-start row-end)
          (tset by-line row-start (or (. by-line row-start) []))
          (table.insert (. by-line row-start)
                        {:hl (.. "@" (. query.captures id))
                         : col-start
                         : col-end}))))
    by-line))

(fn highlights-for [lines path]
  "lines: array of source lines for one file snapshot. Returns
  {0-indexed-line -> [{hl col-start col-end} ...]}, or nil if no
  filetype/parser/highlights query is available for `path`."
  (let [lang (lang-for path)]
    (if (not lang) nil
        (let [query (vim.treesitter.query.get lang :highlights)]
          (if (not query) nil
              (let [text (table.concat lines "\n")
                    (ok parser) (pcall vim.treesitter.get_string_parser text
                                       lang)]
                (if (not ok) nil (captures-by-line parser query text))))))))

{: highlights-for}
