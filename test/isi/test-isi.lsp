;; Isı kaybı testleri.

;; U değeri: bölge 4 duvar -> 0.25
(hk-assert-close "bolge4 duvar U" 0.25 (isi-u-deger 4 'duvar))
(hk-assert-close "bolge4 pencere U" 1.8 (isi-u-deger 4 'pencere))
(hk-assert-close "bolge1 cati U" 0.35 (isi-u-deger 1 'cati))

;; Sıcaklıklar
(hk-assert-close "salon Tic" 22.0 (isi-get-tic "salon"))
(hk-assert-close "banyo Tic" 24.0 (isi-get-tic "banyo"))
(hk-assert-close "ankara Tdis" -12.0 (isi-get-tdis "ankara"))

;; Birim dönüşümü
(hk-assert-close "1000 kcal -> W" 1163.0 (isi-kcal-to-watt 1000.0))
(hk-assert-close "1163 W -> kcal" 1000.18 (isi-watt-to-kcal 1163.0))

;; İletim kaybı: elemanlar ((0.25 20)(1.8 4)) dt=34
;; (0.25*20 + 1.8*4)*34 = (5+7.2)*34 = 12.2*34 = 414.8 W
(hk-assert-close "iletim" 414.8 (isi-iletim '((0.25 20.0)(1.8 4.0)) 34.0))
;; zamlı *1.2 = 497.76
(hk-assert-close "iletim zamli" 497.76 (isi-iletim-zamli 414.8))

;; Havalandırma: 0.34 * 1.0 * 50 * 34 = 578 W
(hk-assert-close "havalandirma" 578.0 (isi-havalandirma 1.0 50.0 34.0))

;; Mahal toplam: iletim_zamli + hav
(setq res (isi-mahal-kayip '((0.25 20.0)(1.8 4.0)) 34.0 1.0 50.0))
(hk-assert-close "toplam" 1075.76 (caddr res))

;; ΔT düzeltme: Q0=1000 @60, sistem 30 -> 1000*(30/60)^1.3 = 406.126
(hk-assert-close "dt duzelt" 406.126 (isi-duzelt-dt 1000.0 30.0 60.0))

;; Dilim sayısı: 2200 W / 120 W = 18.3 -> 19
(hk-assert-equal "dilim sayisi" 19 (isi-dilim-sayisi 2200.0 120.0))

;; Panel boyu: 2000 W / 2226 W/m = 0.898 m -> 898 mm -> 1000 mm üst kademe
(hk-assert-equal "panel boy" 1000 (isi-panel-boy 2000.0 2226.0))
