;; Su tesisatı testleri.

;; Temiz su iç çap: Q=1 L/s, V=2 m/s -> d = sqrt(4*0.001/(pi*2))*1000 ≈ 25.23 mm
(hk-assert-close "ic cap 1Ls 2ms" 25.231 (su-cap-temiz-ic 1.0 2.0))
;; -> bir üst DN: 32 (25 < 25.23)
(hk-assert-equal "DN 1Ls 2ms" 32 (su-cap-temiz 1.0 2.0))

;; DN yuvarlama
(hk-assert-equal "20.5 -> DN25" 25 (su-round-up-dn 20.5))
(hk-assert-equal "tam 25 -> DN25" 25 (su-round-up-dn 25))

;; Yük birimi toplama
(setq yb (su-yb-topla '(("lavabo" 2) ("wc-rezervuar" 2) ("dus" 1))))
;; 2*0.5 + 2*0.25 + 1*1.5 = 1.0+0.5+1.5 = 3.0
(hk-assert-close "YB topla" 3.0 yb)
;; toplam YB 3 -> 3-7 araligi -> DN20
(hk-assert-equal "YB 3 -> DN20" 20 (su-cap-temiz-yb 3.0))

;; Pis su DU toplama
(setq du (su-du-topla '(("wc" 1) ("lavabo" 1) ("dus" 1))))
;; 10 + 2 + 6 = 18
(hk-assert-close "DU topla" 18.0 du)
;; yatay 18 DU -> <=25 -> 70 mm
(hk-assert-equal "DU 18 yatay -> 70" 70 (su-cap-pis 18.0 t))
;; kolon 18 DU -> <=40 -> 70 mm
(hk-assert-equal "DU 18 kolon -> 70" 70 (su-cap-pis 18.0 nil))

;; Eğim kontrolü
(hk-assert-true "70mm %2 uygun" (su-egim-uygun 70 2.0))
(hk-assert-true "70mm %1 uygun degil" (not (su-egim-uygun 70 1.0)))
(hk-assert-true "150mm %0.5 uygun" (su-egim-uygun 150 0.5))

;; Metraj fitting payı: 100 m %12 -> 112
(hk-assert-close "fitting pay" 112.0 (su-apply-fitting-pay 100.0 12.0))
