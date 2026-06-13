;; HavaKanal MVP — tüm modülleri yükler.
;; AutoCAD'de: (load "TAM/YOL/src/hk-load.lsp")
;; veya bu dosyayı APPLOAD ile yükle.
(vl-load-com)

;; Bu dosyanın bulunduğu klasörü baz alarak diğer modülleri yükle.
(setq *hk-dir* (vl-filename-directory (findfile "hk-load.lsp")))
(if (null *hk-dir*) (setq *hk-dir* "."))

(defun hk-load-module (name)
  (load (strcat *hk-dir* "/" name)))

(hk-load-module "hk-standards.lsp")
(hk-load-module "hk-core-sizing.lsp")
(hk-load-module "hk-core-takeoff.lsp")
(hk-load-module "hk-rules.lsp")
(hk-load-module "hk-export-csv.lsp")
(hk-load-module "hk-cad-read.lsp")
(hk-load-module "hk-cad-write.lsp")
(hk-load-module "hk-ui.lsp")
(hk-load-module "hk-commands.lsp")

(princ "\nHavaKanal MVP yuklendi. Komutlar: HKBOYUT, HKMETRAJ\n")
(princ)
