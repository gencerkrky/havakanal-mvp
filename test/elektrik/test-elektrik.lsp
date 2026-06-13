;; Elektrik tesisatı testleri.

;; Talep gücü: 10000 W konut (k=0.5) -> 5000 W
(hk-assert-close "talep konut" 5000.0 (elk-talep-gucu 10000.0 "konut"))
;; ofis k=0.7 -> 7000
(hk-assert-close "talep ofis" 7000.0 (elk-talep-gucu 10000.0 "ofis"))

;; Akım tek faz: 2300 W / (230*0.85) = 11.76 A
(hk-assert-close "akim 1F" 11.7647 (elk-akim 2300.0 "1F" 0.85))
;; üç faz: 10000 / (1.732*400*0.85) = 16.98 A
(hk-assert-close "akim 3F" 16.9854 (elk-akim 10000.0 "3F" 0.85))

;; Sigorta seçimi: 11.76 A -> 16 A
(hk-assert-equal "sigorta 11.76 -> 16" 16 (elk-sec-sigorta 11.7647))
;; 17 A -> 20 A
(hk-assert-equal "sigorta 17 -> 20" 20 (elk-sec-sigorta 17.0))

;; Kesit (akıma göre): 16 A sigorta -> 1.5 mm² taşır mı? 17.5>=16 evet -> 1.5
(hk-assert-close "kesit 16A -> 1.5" 1.5 (elk-sec-kesit-akim 16))
;; 25 A -> 2.5 taşımaz (24<25) -> 4 mm² (32>=25)
(hk-assert-close "kesit 25A -> 4" 4.0 (elk-sec-kesit-akim 25))

;; Gerilim düşümü: I=10A, L=20m, kesit=2.5, 1F
;; dv = 2*0.0175*20*10/2.5 = 2.8 V -> %1.217
(setq vd (elk-vdrop 10.0 20.0 2.5 "1F" 0.85 3.0))
(hk-assert-close "vdrop volt" 2.8 (car vd))
(hk-assert-close "vdrop yuzde" 1.2174 (cadr vd))
(hk-assert-true "vdrop uygun" (caddr vd))

;; Armatür sayısı: 50 m² ofis (18 W/m²) / 36 W armatür = 900/36=25 adet
(hk-assert-equal "armatur ofis" 25 (elk-armatur-sayisi 50.0 "ofis" 36.0))

;; Devre sayısı: 14 priz sorti / 7 = 2, 18 ayd / 9 = 2
(setq dv2 (elk-devre-sayisi 14 18))
(hk-assert-equal "priz devre" 2 (car dv2))
(hk-assert-equal "ayd devre" 2 (cadr dv2))
