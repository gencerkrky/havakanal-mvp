;; Birim dönüşümleri — domain-bağımsız, tüm modüller kullanır.

;; Basınç: Pa -> mmSS (mm su sütunu).
(setq *mep-pa-per-mmss* 9.80665)
(defun mep-pa-to-mmss (pa)
  (/ pa *mep-pa-per-mmss*))
