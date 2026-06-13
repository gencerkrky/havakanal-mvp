;; Birim dönüşümü testleri (core).

;; Pa -> mmSS dönüşümü.
(hk-assert-close "9.80665 Pa -> 1 mmSS" 1.0 (mep-pa-to-mmss 9.80665))
(hk-assert-close "0 Pa -> 0 mmSS" 0.0 (mep-pa-to-mmss 0.0))
