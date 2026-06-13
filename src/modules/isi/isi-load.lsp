;; Isı kaybı modülü yükleyici. Tek başına da yüklenebilir.
(vl-load-com)

(if (not (and (boundp '*mep-core-loaded*) *mep-core-loaded*))
  (progn
    (setq *mep-core-find* (findfile "mep-core-load.lsp"))
    (if *mep-core-find*
      (load *mep-core-find*)
      (princ "\nUYARI: mep-core-load.lsp bulunamadi."))))

(setq *isi-dir* (vl-filename-directory (findfile "isi-load.lsp")))
(if (null *isi-dir*) (setq *isi-dir* "."))
(defun isi-load-file (n) (load (strcat *isi-dir* "/" n)))

(isi-load-file "isi-standards.lsp")
(isi-load-file "isi-sizing.lsp")
(isi-load-file "isi-commands.lsp")

(princ "\nIsi kaybi modulu yuklendi. Komut: ISIKAYBI")
(princ)
