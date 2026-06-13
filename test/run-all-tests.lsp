;; Tüm SAF test dosyalarını yükleyip çalıştırır.
;; Kullanım (AutoCAD veya AutoLISP-uyumlu yorumlayıcı):
;;   (load "test/run-all-tests.lsp")
;; NOT: Sadece AutoCAD'den bağımsız saf çekirdek test edilir.
;; CAD katmanı (mep-cad, hva-commands) AutoCAD'de elle doğrulanır.

(load "test/hk-test-framework.lsp")
(setq *hk-test-pass* 0)
(setq *hk-test-fail* 0)

;; --- Core (saf) ---
(load "src/core/mep-units.lsp")
(load "src/core/mep-csv.lsp")

;; --- Havalandırma (saf) ---
(load "src/modules/havalandirma/hva-standards.lsp")
(load "src/modules/havalandirma/hva-sizing.lsp")
(load "src/modules/havalandirma/hva-takeoff.lsp")
(load "src/modules/havalandirma/hva-rules.lsp")

;; --- Testler ---
(load "test/core/test-units.lsp")
(load "test/core/test-csv.lsp")
(load "test/havalandirma/test-standards.lsp")
(load "test/havalandirma/test-sizing.lsp")
(load "test/havalandirma/test-takeoff.lsp")
(load "test/havalandirma/test-rules.lsp")

(hk-test-summary)
