;; Hava kanalı uyarı kuralları testleri (Spec §5).

(hk-assert-true "ar 5 uyari verir" (hva-warn-aspect-ratio 500.0 100.0))
(hk-assert-true "ar 3 uyari vermez" (not (hva-warn-aspect-ratio 300.0 100.0)))
(hk-assert-true "ar tam 4 uyari vermez" (not (hva-warn-aspect-ratio 400.0 100.0)))

(hk-assert-true "ofis 9 m/s uyari" (hva-warn-velocity 9.0 "ofis-ana"))
(hk-assert-true "ofis 6 m/s temiz" (not (hva-warn-velocity 6.0 "ofis-ana")))

(setq w (hva-collect-warnings 500.0 100.0 9.0 "ofis-ana"))
(hk-assert-true "iki uyari toplanir" (= 2 (length w)))
(setq w2 (hva-collect-warnings 300.0 200.0 6.0 "ofis-ana"))
(hk-assert-true "uyari yok -> bos liste" (= 0 (length w2)))
