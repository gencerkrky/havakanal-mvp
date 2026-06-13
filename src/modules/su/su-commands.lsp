;; Su tesisatı komutları. core (mep-*) araçlarını kullanır.

;; Sistem seç: "Temiz" veya "Pis".
(defun su-ask-sistem (/ k)
  (initget "Temiz Pis")
  (setq k (getkword "\nSistem [Temiz/Pis] <Temiz>: "))
  (if (= k "Pis") "Pis" "Temiz"))

;; SUCAP: temiz su çapı hesabı (debi veya yük birimiyle).
(defun c:SUCAP ( / mode q v dn yb)
  (initget "Debi YukBirimi")
  (setq mode (getkword "\nGirdi [Debi/YukBirimi] <Debi>: "))
  (if (= mode "YukBirimi")
    (progn
      (setq yb (mep-ask-number "Toplam yuk birimi (YB): "))
      (if yb
        (princ (strcat "\n  Onerilen cap: DN" (itoa (su-cap-temiz-yb yb))))))
    (progn
      (setq q (mep-ask-number "Debi Q (L/s): "))
      (setq v (mep-ask-number (strcat "Hiz V (m/s) <" (rtos *su-temiz-hiz* 2 1) ">: ")))
      (if (null v) (setq v *su-temiz-hiz*))
      (if q
        (progn
          (setq dn (su-cap-temiz q v))
          (princ (strcat "\n  Ic cap: " (rtos (su-cap-temiz-ic q v) 2 1)
                         " mm -> Onerilen: DN" (itoa dn)))))))
  (princ))

;; SUMETRAJ: polyline seç -> sistem/malzeme/çap sor -> uzunluk -> CSV.
(defun c:SUMETRAJ ( / enames sistem malzeme cap pay rows i len seg fp)
  (setq enames (mep-select-polylines))
  (if (null enames)
    (princ "\nPolyline secilmedi.")
    (progn
      (setq sistem (su-ask-sistem))
      (setq malzeme (mep-ask-string "Malzeme (PPR/PVC/Pik): "))
      (setq pay (mep-ask-number
                  (strcat "Fitting payi % <" (rtos *su-fitting-pay-yuzde* 2 0) ">: ")))
      (if (null pay) (setq pay *su-fitting-pay-yuzde*))
      (setq rows '() i 1)
      (foreach en enames
        (setq len (mep-read-length-m en))
        (setq cap (mep-ask-string "  Bu hattin capi (orn DN25 veya 110): "))
        (if (and len cap (/= cap ""))
          (progn
            (setq seg (su-takeoff-segment sistem malzeme cap len pay))
            (setq rows (cons
              (list (cons 'NO i) (cons 'SISTEM sistem) (cons 'MALZEME malzeme)
                    (cons 'CAP cap) (cons 'UZUNLUK len)
                    (cons 'UZUNLUK-PAYLI (cdr (assoc 'UZUNLUK-PAYLI seg)))
                    (cons 'FITTING-PAY pay))
              rows))
            (setq i (1+ i)))
          (princ "\n! Atlandi (cap/uzunluk yok).")))
      (setq rows (reverse rows))
      (if rows
        (progn
          (setq fp (getfiled "Su metraj CSV kaydet" "" "csv" 1))
          (if fp
            (mep-csv-write fp rows
              '(NO SISTEM MALZEME CAP UZUNLUK UZUNLUK-PAYLI FITTING-PAY))
            (princ "\nKayit iptal.")))
        (princ "\nGecerli segment yok."))))
  (princ))
