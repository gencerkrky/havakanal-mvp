;; Havalandırma komutları + modüle özel UI. core (mep-*) araçlarını kullanır.

;; --- Modüle özel UI ---

;; Yöntem seç: "CV" (sabit hız) veya "EF" (eşit sürtünme).
(defun hva-ask-method (/ k)
  (initget "Hiz Surtunme")
  (setq k (getkword "\nYontem [Hiz/Surtunme] <Surtunme>: "))
  (if (= k "Hiz") "CV" "EF"))

;; Uygulama tipi seç (hız uyarısı için). Dönüş: hva-rules eşik anahtarı.
(defun hva-ask-apptype (/ k)
  (initget "Ofis Konut Endustri")
  (setq k (getkword "\nUygulama [Ofis/Konut/Endustri] <Ofis>: "))
  (cond
    ((= k "Konut") "konut-ana")
    ((= k "Endustri") "end-ana")
    (t "ofis-ana")))

;; Cam kutu: sonucu, hem Pa/m hem mmSS/m, ve uyarıları gösterir (Spec §4.1, §2).
(defun hva-show-glass-box (res warnings)
  (princ (strcat "\n--- SONUC ---"
    "\n  Boyut: " (itoa (cdr (assoc 'A res))) "x" (itoa (cdr (assoc 'B res))) " mm"
    "\n  Ham:   " (rtos (cdr (assoc 'A-RAW res)) 2 0) "x" (rtos (cdr (assoc 'B-RAW res)) 2 0)
    "\n  Hiz:   " (rtos (cdr (assoc 'V-REAL res)) 2 2) " m/s"
    "\n  Pa/m:  " (rtos (cdr (assoc 'PAM-REAL res)) 2 2)
    " (" (rtos (mep-pa-to-mmss (cdr (assoc 'PAM-REAL res))) 2 3) " mmSS/m)"
    "\n  De:    " (rtos (cdr (assoc 'DE res)) 2 0) " mm"))
  (if warnings
    (foreach w warnings (princ (strcat "\n  ! UYARI: " w)))
    (princ "\n  (uyari yok)"))
  (princ))

;; Override: yuvarlanmış boyutu kabul mu, değiştir mi? Dönüş: (a . b) tamsayı mm.
(defun hva-ask-override (res / k na nb)
  (initget "Kabul Degistir")
  (setq k (getkword "\n[Kabul/Degistir] <Kabul>: "))
  (if (= k "Degistir")
    (progn
      (setq na (mep-ask-number "Yeni A (mm): "))
      (setq nb (mep-ask-number "Yeni B (mm): "))
      (cons (if na (fix na) (cdr (assoc 'A res)))
            (if nb (fix nb) (cdr (assoc 'B res)))))
    (cons (cdr (assoc 'A res)) (cdr (assoc 'B res)))))

;; Bir segment için boyut string'i: kullanıcıdan ister (sessiz atlama yerine).
(defun hva-resolve-size (/ s)
  (setq s (mep-ask-string "  Bu segmentin boyutu (orn 400x300, bos=atla): "))
  (if (and s (/= s "") (car (hva-parse-size s)))
    s
    nil))

;; --- Komutlar (Spec §3.3) ---

;; HKBOYUT: segment(ler) seç -> debi+yöntem gir -> hesapla -> cam kutu -> etiketle.
(defun c:HKBOYUT ( / enames q method target ar app res warns ov pt)
  (setq enames (mep-select-polylines))
  (if (null enames)
    (princ "\nPolyline secilmedi.")
    (progn
      (setq method (hva-ask-method))
      (setq app (hva-ask-apptype))
      (setq q (mep-ask-number "Debi Q (m3/h): "))
      (setq target (mep-ask-number
                     (if (= method "CV") "Hedef hiz V (m/s): " "Hedef Pa/m <1.0>: ")))
      (if (and (null target) (= method "EF")) (setq target 1.0))
      (setq ar (mep-ask-number "En-boy orani (a/b) <1.5>: "))
      (if (null ar) (setq ar 1.5))
      (if (and q target)
        (foreach en enames
          (setq res (hva-size-full method q target ar))
          (if res
            (progn
              (setq warns (hva-collect-warnings
                            (cdr (assoc 'A res)) (cdr (assoc 'B res))
                            (cdr (assoc 'V-REAL res)) app))
              (hva-show-glass-box res warns)
              (setq ov (hva-ask-override res))
              (setq pt (mep-polyline-midpoint en))
              (mep-write-text pt
                (strcat (itoa (car ov)) "x" (itoa (cdr ov))
                        "  Q=" (rtos q 2 0)
                        " V=" (rtos (cdr (assoc 'V-REAL res)) 2 1)
                        " Pa/m=" (rtos (cdr (assoc 'PAM-REAL res)) 2 2))
                "HK_ETIKET")
              (princ (strcat "\nEtiketlendi: " (itoa (car ov)) "x" (itoa (cdr ov)))))
            (princ "\n! Hesaplanamadi (gecersiz yontem/girdi).")))
        (princ "\n! Debi veya hedef girilmedi, iptal."))
      (princ "\nHKBOYUT tamam.")))
  (princ))

;; HKMETRAJ: segmentleri seç -> uzunluk oku + boyut sor -> metraj -> CSV.
(defun c:HKMETRAJ ( / enames waste rows fp i len size-str ab a b seg)
  (setq enames (mep-select-polylines))
  (if (null enames)
    (princ "\nPolyline secilmedi.")
    (progn
      (setq waste (mep-ask-number "Fitting fire % <15>: "))
      (if (null waste) (setq waste 15.0))
      (setq rows '() i 1)
      (foreach en enames
        (setq len (mep-read-length-m en))
        (setq size-str (hva-resolve-size))
        (if (and len size-str)
          (progn
            (setq ab (hva-parse-size size-str))
            (setq a (car ab) b (cdr ab))
            (setq seg (hva-takeoff-segment a b len waste))
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
            (mep-csv-write fp rows '(NO BOYUT UZUNLUK ALAN KALINLIK AGIRLIK FIRE))
            (princ "\nKayit iptal.")))
        (princ "\nMetraj icin gecerli segment bulunamadi."))))
  (princ))
