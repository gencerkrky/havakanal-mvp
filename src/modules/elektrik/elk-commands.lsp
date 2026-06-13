;; Elektrik tesisatı komutları. core (mep-*) araçlarını kullanır.

;; Faz seç.
(defun elk-ask-faz (/ k)
  (initget "Tek Uc")
  (setq k (getkword "\nFaz [Tek/Uc] <Tek>: "))
  (if (= k "Uc") "3F" "1F"))

;; ELKKABLO: güç+faz+uzunluk -> akım, sigorta, kesit (gerilim düşümü dahil).
(defun c:ELKKABLO ( / p faz l devre cosfi res)
  (setq p (mep-ask-number "Yuk gucu P (W): "))
  (setq faz (elk-ask-faz))
  (setq l (mep-ask-number "Hat uzunlugu L (m, tek yon): "))
  (initget "Aydinlatma Priz Kuvvet")
  (setq devre (getkword "\nDevre tipi [Aydinlatma/Priz/Kuvvet] <Priz>: "))
  (setq devre (cond ((= devre "Aydinlatma") "aydinlatma")
                    ((= devre "Kuvvet") "kuvvet") (t "priz")))
  (setq cosfi *elk-cosfi*)
  (if (and p l)
    (progn
      (setq res (elk-sec-kablo p faz cosfi l devre))
      (princ (strcat "\n--- SONUC ---"
        "\n  Akim:   " (rtos (car res) 2 2) " A"
        "\n  Sigorta: " (rtos (cadr res) 2 0) " A"
        "\n  Kesit:  " (rtos (caddr res) 2 1) " mm2"
        "\n  Ger.dusumu: " (rtos (cadddr res) 2 2) " %")))
    (princ "\nGirdi eksik."))
  (princ))

;; ELKGUC: kurulu güç + tesis tipi -> talep gücü + akım.
(defun c:ELKGUC ( / p tesis faz cosfi talep)
  (setq p (mep-ask-number "Kurulu guc P (W): "))
  (initget "Konut Ofis Magaza Kuvvet")
  (setq tesis (getkword "\nTesis [Konut/Ofis/Magaza/Kuvvet] <Konut>: "))
  (setq tesis (cond ((= tesis "Ofis") "ofis") ((= tesis "Magaza") "magaza")
                    ((= tesis "Kuvvet") "kuvvet") (t "konut")))
  (setq faz (elk-ask-faz))
  (setq cosfi *elk-cosfi*)
  (if p
    (progn
      (setq talep (elk-talep-gucu p tesis))
      (princ (strcat "\n  Talep gucu: " (rtos talep 2 0) " W"
                     "\n  Akim: " (rtos (elk-akim talep faz cosfi) 2 2) " A")))
    (princ "\nGirdi yok."))
  (princ))

;; ELKMETRAJ: kablo polyline (kesit bazinda) + blok sayimi -> CSV.
(defun c:ELKMETRAJ ( / enames kesit rows i len fp adet tip)
  (setq enames (mep-select-polylines))
  (setq rows '() i 1)
  (if enames
    (foreach en enames
      (setq len (mep-read-length-m en))
      (setq kesit (mep-ask-string "  Bu kablonun kesiti (orn 3x2.5): "))
      (if (and len kesit (/= kesit ""))
        (progn
          (setq rows (cons
            (list (cons 'NO i) (cons 'KALEM "Kablo") (cons 'TIP kesit)
                  (cons 'BIRIM "m") (cons 'MIKTAR len))
            rows))
          (setq i (1+ i))))))
  ;; blok sayımı (priz/anahtar/armatür) — kullanıcıdan adet
  (foreach tip '("Priz" "Anahtar" "Armatur" "Buat")
    (setq adet (mep-ask-number (strcat tip " adedi (0=atla): ")))
    (if (and adet (> adet 0))
      (progn
        (setq rows (cons
          (list (cons 'NO i) (cons 'KALEM tip) (cons 'TIP "-")
                (cons 'BIRIM "adet") (cons 'MIKTAR (fix adet)))
          rows))
        (setq i (1+ i)))))
  (setq rows (reverse rows))
  (if rows
    (progn
      (setq fp (getfiled "Elektrik metraj CSV kaydet" "" "csv" 1))
      (if fp
        (mep-csv-write fp rows '(NO KALEM TIP BIRIM MIKTAR))
        (princ "\nKayit iptal.")))
    (princ "\nGecerli kalem yok."))
  (princ))
