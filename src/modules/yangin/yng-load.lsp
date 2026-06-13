;; Yangın tesisatı modülü yükleyici. Tek başına da yüklenebilir.
(vl-load-com)

(if (not (and (boundp '*mep-core-loaded*) *mep-core-loaded*))
  (progn
    (setq *mep-core-find* (findfile "mep-core-load.lsp"))
    (if *mep-core-find*
      (load *mep-core-find*)
      (princ "\nUYARI: mep-core-load.lsp bulunamadi."))))

(setq *yng-dir* (vl-filename-directory (findfile "yng-load.lsp")))
(if (null *yng-dir*) (setq *yng-dir* "."))
(defun yng-load-file (n) (load (strcat *yng-dir* "/" n)))

(yng-load-file "yng-standards.lsp")
(yng-load-file "yng-sizing.lsp")
(yng-load-file "yng-grid.lsp")
(yng-load-file "yng-commands.lsp")

(princ "\nYangin tesisati modulu yuklendi. Komutlar: YSPRINKLER, YBORUCAP, YMETRAJ")
(princ)
