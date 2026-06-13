;; Havalandırma modülü yükleyici.
;; Tek başına da yüklenebilir: core yüklü değilse otomatik çeker.
(vl-load-com)

;; Core hazır değilse yükle (modül bağımsız çalışabilsin).
(if (not (and (boundp '*mep-core-loaded*) *mep-core-loaded*))
  (progn
    (setq *mep-core-find* (findfile "mep-core-load.lsp"))
    (if *mep-core-find*
      (load *mep-core-find*)
      (princ "\nUYARI: mep-core-load.lsp bulunamadi. Core'u once yukleyin veya support path'e ekleyin."))))

(setq *hva-dir* (vl-filename-directory (findfile "hva-load.lsp")))
(if (null *hva-dir*) (setq *hva-dir* "."))

(defun hva-load-file (n)
  (load (strcat *hva-dir* "/" n)))

(hva-load-file "hva-standards.lsp")
(hva-load-file "hva-sizing.lsp")
(hva-load-file "hva-takeoff.lsp")
(hva-load-file "hva-rules.lsp")
(hva-load-file "hva-commands.lsp")

(princ "\nHavalandirma modulu yuklendi. Komutlar: HKBOYUT, HKMETRAJ")
(princ)
