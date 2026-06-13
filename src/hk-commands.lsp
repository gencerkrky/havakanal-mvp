;; Komutlar — katmanları bağlar. (Spec §3.3)

;; HKBOYUT: segment(ler) seç -> debi+yöntem gir -> hesapla -> cam kutu -> etiketle.
(defun c:HKBOYUT ( / enames q method target ar app res warns ov pt)
  (setq enames (hk-select-polylines))
  (if (null enames)
    (princ "\nPolyline secilmedi.")
    (progn
      (setq method (hk-ask-method))
      (setq app (hk-ask-apptype))
      (setq q (hk-ask-number "Debi Q (m3/h): "))
      (setq target (hk-ask-number
                     (if (= method "CV") "Hedef hiz V (m/s): " "Hedef Pa/m <1.0>: ")))
      (if (and (null target) (= method "EF")) (setq target 1.0))
      (setq ar (hk-ask-number "En-boy orani (a/b) <1.5>: "))
      (if (null ar) (setq ar 1.5))
      (if (and q target)
        (foreach en enames
          (setq res (hk-size-full method q target ar))
          (if res
            (progn
              (setq warns (hk-collect-warnings
                            (cdr (assoc 'A res)) (cdr (assoc 'B res))
                            (cdr (assoc 'V-REAL res)) app))
              (hk-show-glass-box res warns)
              (setq ov (hk-ask-override res))
              (setq pt (hk-polyline-midpoint en))
              (hk-write-label pt
                (strcat (itoa (car ov)) "x" (itoa (cdr ov)))
                q (cdr (assoc 'V-REAL res)) (cdr (assoc 'PAM-REAL res)))
              (princ (strcat "\nEtiketlendi: " (itoa (car ov)) "x" (itoa (cdr ov)))))
            (princ "\n! Hesaplanamadi (gecersiz yontem/girdi).")))
        (princ "\n! Debi veya hedef girilmedi, iptal."))
      (princ "\nHKBOYUT tamam.")))
  (princ))

;; Bir segment için boyut string'i bulur: yakın etiket yoksa kullanıcıdan ister.
;; MVP'de otomatik etiket eşleme yok; kullanıcı boyutu girer (sessiz atlama yerine).
(defun hk-resolve-size (en / s)
  (setq s (getstring t "\n  Bu segmentin boyutu (orn 400x300, bos=atla): "))
  (if (and s (/= s "") (car (hk-parse-size s)))
    s
    nil))

;; HKMETRAJ: segmentleri seç -> uzunluk oku + boyut sor -> metraj -> CSV.
(defun c:HKMETRAJ ( / enames waste rows fp i len size-str ab a b seg)
  (setq enames (hk-select-polylines))
  (if (null enames)
    (princ "\nPolyline secilmedi.")
    (progn
      (setq waste (hk-ask-number "Fitting fire % <15>: "))
      (if (null waste) (setq waste 15.0))
      (setq rows '() i 1)
      (foreach en enames
        (setq len (hk-read-length-m en))
        (setq size-str (hk-resolve-size en))
        (if (and len size-str)
          (progn
            (setq ab (hk-parse-size size-str))
            (setq a (car ab) b (cdr ab))
            (setq seg (hk-takeoff-segment a b len waste))
            (setq rows (cons
              (list (cons 'NO i) (cons 'BOYUT size-str)
                    (cons 'UZUNLUK len) (cons 'ALAN (cdr (assoc 'AREA seg)))
                    (cons 'KALINLIK (cdr (assoc 'THICKNESS seg)))
                    (cons 'AGIRLIK (cdr (assoc 'WEIGHT seg)))
                    (cons 'FIRE waste))
              rows))
            (setq i (1+ i)))
          (princ "\n! Atlandi (boyut/uzunluk yok).")))
      (setq rows (reverse rows))
      (if rows
        (progn
          (setq fp (getfiled "Metraj CSV kaydet" "" "csv" 1))
          (if fp
            (hk-csv-write fp rows '(NO BOYUT UZUNLUK ALAN KALINLIK AGIRLIK FIRE))
            (princ "\nKayit iptal.")))
        (princ "\nMetraj icin gecerli segment bulunamadi."))))
  (princ))
