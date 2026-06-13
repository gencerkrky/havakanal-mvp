;; Metraj çekirdeği testleri (Spec §5).

;; Yüzey alanı: a=400 b=300 L=5 -> 2*(0.4+0.3)*5 = 7.0 m²
(hk-assert-close "yuzey alani" 7.0 (hk-surface-area 400.0 300.0 5.0))

;; Ağırlık: 7.0 m² * 0.60 mm * 7.85 = 32.97 kg
(hk-assert-close "agirlik" 32.97 (hk-weight 7.0 0.60))

;; Fire %: %15 -> *1.15
(hk-assert-close "fire %15 alan" 8.05 (hk-apply-waste 7.0 15.0))
(hk-assert-close "fire %0 alan" 7.0 (hk-apply-waste 7.0 0.0))

;; Tek segment tam metraj
(setq t1 (hk-takeoff-segment 400.0 300.0 5.0 15.0))
(hk-assert-close "seg alan (fire dahil)" 8.05 (cdr (assoc 'AREA t1)))
;; ağırlık fire'li alandan: 8.05 * 0.60 * 7.85 = 37.9155
(hk-assert-close "seg agirlik" 37.9155 (cdr (assoc 'WEIGHT t1)))
(hk-assert-close "seg kalinlik" 0.60 (cdr (assoc 'THICKNESS t1)))
