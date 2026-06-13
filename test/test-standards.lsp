;; TS EN 1505 standart kademeleri, yuvarlama, kalınlık, birim dönüşümü testleri.

;; Bir üst standart kademeye yuvarlama.
(hk-assert-equal "347 -> 400" 400 (hk-round-up-standard 347))
(hk-assert-equal "tam kademe 400 -> 400" 400 (hk-round-up-standard 400))
(hk-assert-equal "260 -> 300" 300 (hk-round-up-standard 260))
(hk-assert-equal "kademe alti 90 -> 100" 100 (hk-round-up-standard 90))
(hk-assert-equal "1500 -> 1200" 1200 (hk-round-up-standard 1500))

;; Sac kalınlığı en geniş kenara göre (mm).
(hk-assert-close "<=600 -> 0.60" 0.60 (hk-sheet-thickness 500))
(hk-assert-close "600-1000 -> 0.80" 0.80 (hk-sheet-thickness 800))
(hk-assert-close ">1000 -> 1.00" 1.00 (hk-sheet-thickness 1200))
(hk-assert-close "600 sinir -> 0.60" 0.60 (hk-sheet-thickness 600))

;; Pa -> mmSS dönüşümü.
(hk-assert-close "9.80665 Pa -> 1 mmSS" 1.0 (hk-pa-to-mmss 9.80665))
(hk-assert-close "0 Pa -> 0 mmSS" 0.0 (hk-pa-to-mmss 0.0))

;; Boyut parse.
(setq ab (hk-parse-size "400x300"))
(hk-assert-equal "parse a" 400 (car ab))
(hk-assert-equal "parse b" 300 (cdr ab))
