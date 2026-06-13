;; Elektrik tesisatı modülü yükleyici. Tek başına da yüklenebilir.
(vl-load-com)

(if (not (and (boundp '*mep-core-loaded*) *mep-core-loaded*))
  (progn
    (setq *mep-core-find* (findfile "mep-core-load.lsp"))
    (if *mep-core-find*
      (load *mep-core-find*)
      (princ "\nUYARI: mep-core-load.lsp bulunamadi."))))

(setq *elk-dir* (vl-filename-directory (findfile "elk-load.lsp")))
(if (null *elk-dir*) (setq *elk-dir* "."))
(defun elk-load-file (n) (load (strcat *elk-dir* "/" n)))

(elk-load-file "elk-standards.lsp")
(elk-load-file "elk-sizing.lsp")
(elk-load-file "elk-commands.lsp")

(princ "\nElektrik tesisati modulu yuklendi. Komutlar: ELKGUC, ELKKABLO, ELKMETRAJ")
(princ)
