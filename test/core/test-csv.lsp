;; CSV satır biçimlendirme testi (core, saf string).

(setq row (list (cons 'NO 1) (cons 'BOYUT "400x300")
                (cons 'UZUNLUK 5.0) (cons 'ALAN 7.0) (cons 'AGIRLIK 32.97)))
(setq cols '(NO BOYUT UZUNLUK ALAN AGIRLIK))
(hk-assert-equal "csv satiri"
  "1;400x300;5.0;7.0;32.97"
  (mep-csv-row row cols))

(hk-assert-equal "csv baslik"
  "NO;BOYUT;UZUNLUK;ALAN;AGIRLIK"
  (mep-csv-header cols))
