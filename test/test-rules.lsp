;; Uyarı kuralları testleri (Spec §5).

;; en-boy oranı > 4:1 uyarısı
(hk-assert-true "ar 5 uyari verir" (hk-warn-aspect-ratio 500.0 100.0))
(hk-assert-true "ar 3 uyari vermez" (not (hk-warn-aspect-ratio 300.0 100.0)))
(hk-assert-true "ar tam 4 uyari vermez" (not (hk-warn-aspect-ratio 400.0 100.0)))

;; hız eşiği — "ofis-ana" üst sınır 7.6 m/s
(hk-assert-true "ofis 9 m/s uyari" (hk-warn-velocity 9.0 "ofis-ana"))
(hk-assert-true "ofis 6 m/s temiz" (not (hk-warn-velocity 6.0 "ofis-ana")))

;; tüm uyarıları toplayan fonksiyon
(setq w (hk-collect-warnings 500.0 100.0 9.0 "ofis-ana"))
(hk-assert-true "iki uyari toplanir" (= 2 (length w)))
(setq w2 (hk-collect-warnings 300.0 200.0 6.0 "ofis-ana"))
(hk-assert-true "uyari yok -> bos liste" (= 0 (length w2)))
