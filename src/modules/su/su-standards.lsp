;; Su tesisatı standartları/tabloları — SAF, AutoCAD bağımsız.
;; Yöntem: TS 826 yük birimi geleneği + güncel TS EN 806 / TS EN 12056.
;; Değerler proje pratiğinden; idare (İSKİ/ASKİ) farkları için hız parametre.

;; Standart anma çapları (DN) — yukarı yuvarlama için.
(setq *su-dn-list* '(10 15 20 25 32 40 50 65 80 100 125 150 200))

;; Temiz su: toplam yük birimi (YB) -> DN. ((max_YB . DN) ...) küçükten büyüğe.
(setq *su-temiz-yb-cap*
  '((2 . 15) (7 . 20) (20 . 25) (50 . 32) (99 . 40)
    (250 . 50) (510 . 65) (1199 . 80) (999999 . 100)))

;; Temiz su cihaz -> yük birimi (YB).
(setq *su-temiz-cihaz-yb*
  '(("lavabo" . 0.5) ("eviye" . 1.0) ("dus" . 1.5) ("kuvet" . 1.5)
    ("pisuar" . 0.25) ("wc-rezervuar" . 0.25) ("wc-basincli" . 6.0)
    ("camasir" . 2.5) ("bulasik" . 2.5)))

;; Pis su: cihaz -> atık su yük birimi (DU).
(setq *su-pis-cihaz-du*
  '(("lavabo" . 2) ("eviye" . 4) ("dus" . 6) ("kuvet" . 7)
    ("bide" . 2) ("pisuar" . 2) ("wc" . 10) ("suzgec" . 2)
    ("camasir" . 4) ("bulasik" . 4)))

;; Pis su yatay boru: toplam DU -> çap (mm). ((max_DU . cap) ...)
(setq *su-pis-yatay-cap*
  '((25 . 70) (100 . 100) (270 . 125) (600 . 150) (999999 . 200)))

;; Pis su kolon: toplam DU -> çap (mm).
(setq *su-pis-kolon-cap*
  '((40 . 70) (150 . 100) (400 . 125) (900 . 150) (999999 . 200)))

;; Pis su minimum eğim (%) — büyük çapta düşebilir; varsayılan %2.
(setq *su-min-egim-kucuk* 2.0)   ; <= 100 mm
(setq *su-min-egim-buyuk* 0.5)   ; > 100 mm

;; Bir değeri ((esik . sonuc)...) tablosundan yukarı arama: ilk esik>=deger.
(defun su-lookup-up (val tbl / result)
  (setq result nil)
  (foreach pair tbl
    (if (and (null result) (<= val (car pair)))
      (setq result (cdr pair))))
  (if (null result) (cdr (last tbl)) result))

;; DN listesinden ham mm değerini bir üst standarda yuvarla.
(defun su-round-up-dn (raw-mm / result)
  (setq result nil)
  (foreach dn *su-dn-list*
    (if (and (null result) (>= dn raw-mm))
      (setq result dn)))
  (if (null result) (last *su-dn-list*) result))
