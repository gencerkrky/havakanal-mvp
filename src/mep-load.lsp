;; MEP Paketi — ANA yükleyici. Core + tüm mevcut modülleri getirir.
;; Kurulum: AutoCAD komut satırına:
;;   (load "C:/MEP/src/mep-load.lsp")
;; Windows yollarında "\" yerine "/" kullanın.
(vl-load-com)

(setq *mep-dir* (vl-filename-directory (findfile "mep-load.lsp")))
(if (null *mep-dir*) (setq *mep-dir* "."))

;; Core (mutlak yolla, findfile bağımlılığını azalt).
(load (strcat *mep-dir* "/core/mep-core-load.lsp"))

;; Modüller.
(load (strcat *mep-dir* "/modules/havalandirma/hva-load.lsp"))
;; Gelecek modüller buraya eklenecek:
;; (load (strcat *mep-dir* "/modules/su/su-load.lsp"))
;; (load (strcat *mep-dir* "/modules/elektrik/elk-load.lsp"))
;; (load (strcat *mep-dir* "/modules/yangin/yng-load.lsp"))
;; (load (strcat *mep-dir* "/modules/isi/isi-load.lsp"))

(princ "\n=== MEP Paketi yuklendi. ===\n")
(princ)
