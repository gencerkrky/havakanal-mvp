;; Kullanıcı etkileşimi — komut satırı tabanlı (MVP; v2'de DCL diyalog).
;; (Spec §4.1 cam kutu: ara değerleri göster + override.)

;; Pozitif sayı iste; iptal/boş veya <=0 -> nil.
(defun hk-ask-number (prompt-str / v)
  (setq v (getreal (strcat "\n" prompt-str)))
  (if (and v (> v 0.0)) v nil))

;; Yöntem seç: "CV" (sabit hız) veya "EF" (eşit sürtünme).
(defun hk-ask-method (/ k)
  (initget "Hiz Surtunme")
  (setq k (getkword "\nYontem [Hiz/Surtunme] <Surtunme>: "))
  (if (= k "Hiz") "CV" "EF"))

;; Uygulama tipi seç (hız uyarısı için). Dönüş: hk-rules eşik anahtarı.
(defun hk-ask-apptype (/ k)
  (initget "Ofis Konut Endustri")
  (setq k (getkword "\nUygulama [Ofis/Konut/Endustri] <Ofis>: "))
  (cond
    ((= k "Konut") "konut-ana")
    ((= k "Endustri") "end-ana")
    (t "ofis-ana")))

;; Cam kutu: sonucu, hem Pa/m hem mmSS/m, ve uyarıları komut satırına yazar (Spec §4.1, §2).
(defun hk-show-glass-box (res warnings)
  (princ (strcat "\n--- SONUC ---"
    "\n  Boyut: " (itoa (cdr (assoc 'A res))) "x" (itoa (cdr (assoc 'B res))) " mm"
    "\n  Ham:   " (rtos (cdr (assoc 'A-RAW res)) 2 0) "x" (rtos (cdr (assoc 'B-RAW res)) 2 0)
    "\n  Hiz:   " (rtos (cdr (assoc 'V-REAL res)) 2 2) " m/s"
    "\n  Pa/m:  " (rtos (cdr (assoc 'PAM-REAL res)) 2 2)
    " (" (rtos (hk-pa-to-mmss (cdr (assoc 'PAM-REAL res))) 2 3) " mmSS/m)"
    "\n  De:    " (rtos (cdr (assoc 'DE res)) 2 0) " mm"))
  (if warnings
    (foreach w warnings (princ (strcat "\n  ! UYARI: " w)))
    (princ "\n  (uyari yok)"))
  (princ))

;; Override: kullanıcı yuvarlanmış boyutu kabul mu, değiştirmek mi istiyor?
;; Dönüş: kabul edilen/override edilen (a . b) çifti (tamsayı mm).
(defun hk-ask-override (res / k na nb)
  (initget "Kabul Degistir")
  (setq k (getkword "\n[Kabul/Degistir] <Kabul>: "))
  (if (= k "Degistir")
    (progn
      (setq na (hk-ask-number "Yeni A (mm): "))
      (setq nb (hk-ask-number "Yeni B (mm): "))
      (cons (if na (fix na) (cdr (assoc 'A res)))
            (if nb (fix nb) (cdr (assoc 'B res)))))
    (cons (cdr (assoc 'A res)) (cdr (assoc 'B res)))))
