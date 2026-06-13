;; Hava kanalı metraj çekirdeği testleri (Spec §5).

(hk-assert-close "yuzey alani" 7.0 (hva-surface-area 400.0 300.0 5.0))
(hk-assert-close "agirlik" 32.97 (hva-weight 7.0 0.60))
(hk-assert-close "fire %15 alan" 8.05 (hva-apply-waste 7.0 15.0))
(hk-assert-close "fire %0 alan" 7.0 (hva-apply-waste 7.0 0.0))

(setq t1 (hva-takeoff-segment 400.0 300.0 5.0 15.0))
(hk-assert-close "seg alan (fire dahil)" 8.05 (cdr (assoc 'AREA t1)))
(hk-assert-close "seg agirlik" 37.9155 (cdr (assoc 'WEIGHT t1)))
(hk-assert-close "seg kalinlik" 0.60 (cdr (assoc 'THICKNESS t1)))
