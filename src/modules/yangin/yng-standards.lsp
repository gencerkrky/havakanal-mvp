;; Yangın tesisatı (sprinkler) standartları/tabloları — SAF, AutoCAD bağımsız.
;; Kaynak: BYKHY 2007/12937 + TS EN 12845. MVP: LH + OH, pipe-schedule.

;; Tehlike sınıfı tablosu:
;; (sinif yogunluk_mm_dk koruma_alani_m2 max_aralik_S_m duvar_D_m)
(setq *yng-hazard-table*
  '(("LH" 2.25 21.0 4.6 2.3)
    ("OH" 5.0  12.0 4.0 2.0)
    ("HH" 12.5 9.0  3.7 1.85)))

;; Pipe schedule: (DN LH_max_sprinkler OH_max_sprinkler). OH'da bazıları < LH.
;; nil = o sınıf için tablo dışı (hidrolik hesap gerekli).
(setq *yng-pipe-schedule*
  '((25 2 2) (32 3 3) (40 5 5) (50 10 10) (65 30 20)
    (80 60 40) (90 100 65) (100 nil 100) (125 nil 160) (150 nil 275)))

;; Branşman hattı başına maksimum sprinkler (EN 12845).
(setq *yng-max-sprinkler-bransman* 8)

;; Bir tehlike sınıfının parametrelerini al: (yogunluk alan S D) veya nil.
(defun yng-hazard-params (sinif / row)
  (setq row (assoc sinif *yng-hazard-table*))
  (if row (cdr row) nil))
