;; MEP çekirdek (core) yükleyici. Tüm domain-bağımsız araçları yükler.
(vl-load-com)

(setq *mep-core-dir* (vl-filename-directory (findfile "mep-core-load.lsp")))
(if (null *mep-core-dir*) (setq *mep-core-dir* "."))

(defun mep-core-load-file (n)
  (load (strcat *mep-core-dir* "/" n)))

(mep-core-load-file "mep-units.lsp")
(mep-core-load-file "mep-csv.lsp")
(mep-core-load-file "mep-ui.lsp")
(mep-core-load-file "mep-cad.lsp")

;; Modüllerin "core hazır mı?" kontrolü için bayrak.
(setq *mep-core-loaded* T)
(princ "\nMEP core yuklendi.")
(princ)
