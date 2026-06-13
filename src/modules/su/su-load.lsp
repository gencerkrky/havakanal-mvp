;; Su tesisatı modülü yükleyici. Tek başına da yüklenebilir.
(vl-load-com)

(if (not (and (boundp '*mep-core-loaded*) *mep-core-loaded*))
  (progn
    (setq *mep-core-find* (findfile "mep-core-load.lsp"))
    (if *mep-core-find*
      (load *mep-core-find*)
      (princ "\nUYARI: mep-core-load.lsp bulunamadi."))))

(setq *su-dir* (vl-filename-directory (findfile "su-load.lsp")))
(if (null *su-dir*) (setq *su-dir* "."))
(defun su-load-file (n) (load (strcat *su-dir* "/" n)))

(su-load-file "su-standards.lsp")
(su-load-file "su-sizing.lsp")
(su-load-file "su-takeoff.lsp")
(su-load-file "su-commands.lsp")

(princ "\nSu tesisati modulu yuklendi. Komutlar: SUCAP, SUMETRAJ")
(princ)
