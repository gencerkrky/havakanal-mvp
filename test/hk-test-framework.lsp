;; Minik AutoLISP test çerçevesi — AutoCAD gerektirmez.
;; Neden: AutoLISP'in standart test aracı yok; saf çekirdeği TDD ile
;; geliştirebilmek için hafif bir assert + sayaç mekanizması gerekir.

(setq *hk-test-pass* 0)
(setq *hk-test-fail* 0)

;; Float karşılaştırma toleransı — ondalık hesap sonuçları birebir eşleşmez.
;; 1e-3: rtos 4-hane yuvarlamasıyla uyumlu, son hane sapmasını tolere eder.
(setq *hk-test-eps* 1e-3)

(defun hk-assert-true (label val)
  (if val
    (progn (setq *hk-test-pass* (1+ *hk-test-pass*))
           (princ (strcat "\n  PASS: " label)))
    (progn (setq *hk-test-fail* (1+ *hk-test-fail*))
           (princ (strcat "\n  FAIL: " label)))))

(defun hk-assert-equal (label expected actual)
  (hk-assert-true
    (strcat label " (beklenen=" (vl-princ-to-string expected)
            " gercek=" (vl-princ-to-string actual) ")")
    (equal expected actual)))

;; Float'a özel: tolerans dahilinde eşitlik.
(defun hk-assert-close (label expected actual)
  (hk-assert-true
    (strcat label " (beklenen=" (rtos expected 2 4)
            " gercek=" (rtos actual 2 4) ")")
    (< (abs (- expected actual)) *hk-test-eps*)))

(defun hk-test-summary ()
  (princ (strcat "\n\n=== SONUC: " (itoa *hk-test-pass*) " PASS, "
                 (itoa *hk-test-fail*) " FAIL ===\n"))
  (princ))
