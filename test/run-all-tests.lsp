;; Tüm SAF test dosyalarını yükleyip çalıştırır.
;; Kullanım (AutoCAD veya AutoLISP-uyumlu yorumlayıcı):
;;   (load "test/run-all-tests.lsp")
;; NOT: Sadece AutoCAD'den bağımsız saf çekirdek test edilir.
;; CAD katmanı (hk-cad-read/write, hk-ui, hk-commands) AutoCAD'de elle doğrulanır.

(load "test/hk-test-framework.lsp")
(setq *hk-test-pass* 0)
(setq *hk-test-fail* 0)

;; Saf kaynak modülleri
(load "src/hk-standards.lsp")
(load "src/hk-core-sizing.lsp")
(load "src/hk-core-takeoff.lsp")
(load "src/hk-rules.lsp")
(load "src/hk-export-csv.lsp")

;; Saf testler
(load "test/test-standards.lsp")
(load "test/test-sizing.lsp")
(load "test/test-takeoff.lsp")
(load "test/test-rules.lsp")
(load "test/test-export.lsp")

(hk-test-summary)
