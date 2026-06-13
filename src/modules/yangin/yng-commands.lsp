;; Yangın tesisatı komutları. core (mep-*) araçlarını kullanır.

;; Tehlike sınıfı seç (MVP: LH / OH).
(defun yng-ask-hazard (/ k)
  (initget "LH OH")
  (setq k (getkword "\nTehlike sinifi [LH/OH] <OH>: "))
  (if (= k "LH") "LH" "OH"))

;; YSPRINKLER: iki köşe noktası ile dikdörtgen alan + sınıf -> grid sprinkler nokta
;; çizimi (daire ile işaretle). Blok yoksa daire kullanır (MVP bağımsızlık).
(defun c:YSPRINKLER ( / p1 p2 sinif w l s pts r cnt)
  (setq p1 (getpoint "\nAlan sol-alt kose: "))
  (setq p2 (getcorner p1 "\nAlan sag-ust kose: "))
  (if (and p1 p2)
    (progn
      (setq sinif (yng-ask-hazard))
      (setq w (/ (abs (- (car p2) (car p1))) 1000.0))   ; mm -> m
      (setq l (/ (abs (- (cadr p2) (cadr p1))) 1000.0))
      (setq s (yng-spacing sinif))
      (setq pts (yng-grid-points
                  (list (min (car p1) (car p2)) (min (cadr p1) (cadr p2)))
                  w l s))
      (setq r 75.0)  ; işaret dairesi yarıçapı (mm)
      (foreach pt pts
        (entmake (list (cons 0 "CIRCLE") (cons 10 pt) (cons 40 r)
                       (cons 8 "YANGIN_SPRINKLER"))))
      (setq cnt (length pts))
      (princ (strcat "\n" (itoa cnt) " sprinkler yerlestirildi (sinif " sinif
                     ", aralik " (rtos s 2 2) " m)."))
      (princ (strcat "\n  Sprinkler debisi: " (rtos (yng-sprinkler-debi sinif) 2 1) " L/dk")))
    (princ "\nAlan secilmedi."))
  (princ))

;; YBORUCAP: beslediği sprinkler sayısına göre boru DN önerir.
(defun c:YBORUCAP ( / sinif n dn)
  (setq sinif (yng-ask-hazard))
  (setq n (mep-ask-number "Borunun besledigi sprinkler sayisi: "))
  (if n
    (progn
      (setq dn (yng-pipe-dn sinif (fix n)))
      (if dn
        (princ (strcat "\n  Onerilen boru capi: DN" (itoa dn)))
        (princ "\n  Tablo disi -> HIDROLIK HESAP GEREKLI (v2).")))
    (princ "\nGirdi yok."))
  (princ))

;; YMETRAJ: boru polyline'larini çap bazinda metraj + sprinkler adedi -> CSV.
(defun c:YMETRAJ ( / enames cap rows i len sp fp)
  (setq enames (mep-select-polylines))
  (if (null enames)
    (princ "\nBoru polyline secilmedi.")
    (progn
      (setq rows '() i 1)
      (foreach en enames
        (setq len (mep-read-length-m en))
        (setq cap (mep-ask-string "  Bu borunun capi (orn DN50): "))
        (if (and len cap (/= cap ""))
          (progn
            (setq rows (cons
              (list (cons 'NO i) (cons 'KALEM "Boru") (cons 'CAP cap)
                    (cons 'BIRIM "m") (cons 'MIKTAR len))
              rows))
            (setq i (1+ i)))
          (princ "\n! Atlandi.")))
      ;; sprinkler adedi (kullanıcıdan)
      (setq sp (mep-ask-number "Toplam sprinkler adedi (0=atla): "))
      (if (and sp (> sp 0))
        (setq rows (cons
          (list (cons 'NO i) (cons 'KALEM "Sprinkler") (cons 'CAP "-")
                (cons 'BIRIM "adet") (cons 'MIKTAR (fix sp)))
          rows)))
      (setq rows (reverse rows))
      (if rows
        (progn
          (setq fp (getfiled "Yangin metraj CSV kaydet" "" "csv" 1))
          (if fp
            (mep-csv-write fp rows '(NO KALEM CAP BIRIM MIKTAR))
            (princ "\nKayit iptal.")))
        (princ "\nGecerli kalem yok."))))
  (princ))
