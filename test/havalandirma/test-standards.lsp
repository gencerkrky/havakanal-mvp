;; TS EN 1505 kademe, yuvarlama, kalınlık, boyut parse testleri (havalandırma).

(hk-assert-equal "347 -> 400" 400 (hva-round-up-standard 347))
(hk-assert-equal "tam kademe 400 -> 400" 400 (hva-round-up-standard 400))
(hk-assert-equal "260 -> 300" 300 (hva-round-up-standard 260))
(hk-assert-equal "kademe alti 90 -> 100" 100 (hva-round-up-standard 90))
(hk-assert-equal "1500 -> 1200" 1200 (hva-round-up-standard 1500))

(hk-assert-close "<=600 -> 0.60" 0.60 (hva-sheet-thickness 500))
(hk-assert-close "600-1000 -> 0.80" 0.80 (hva-sheet-thickness 800))
(hk-assert-close ">1000 -> 1.00" 1.00 (hva-sheet-thickness 1200))
(hk-assert-close "600 sinir -> 0.60" 0.60 (hva-sheet-thickness 600))

(setq ab (hva-parse-size "400x300"))
(hk-assert-equal "parse a" 400 (car ab))
(hk-assert-equal "parse b" 300 (cdr ab))
