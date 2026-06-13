;; Metraj çekirdeği — SAF hesap. AutoCAD bağımsız. (Spec §5)
;; Sac kalınlığı: hk-standards.lsp'den hk-sheet-thickness.

(setq *hk-steel-density-factor* 7.85)  ; kg/(m²·mm), çelik 7.85 g/cm³

;; Yüzey alanı (m²): A = 2*(a+b)*L. a,b mm; L metre.
(defun hk-surface-area (a b l-m)
  (* 2.0 (/ (+ a b) 1000.0) l-m))

;; Ağırlık (kg) = alan(m²) * kalınlık(mm) * 7.85
(defun hk-weight (area-m2 thickness-mm)
  (* area-m2 thickness-mm *hk-steel-density-factor*))

;; Fitting fire yüzdesi uygula (alanı oransal artır). pct: 0-100.
(defun hk-apply-waste (area-m2 pct)
  (* area-m2 (+ 1.0 (/ pct 100.0))))

;; Tek segment tam metraj. a,b mm; L metre; waste% 0-100.
;; Fire %, yüzey alanına uygulanır; ağırlık fire'li alandan türer (Spec §4.2).
(defun hk-takeoff-segment (a b l-m waste-pct / raw-area area thick weight)
  (setq raw-area (hk-surface-area a b l-m))
  (setq area (hk-apply-waste raw-area waste-pct))
  (setq thick (hk-sheet-thickness (max a b)))
  (setq weight (hk-weight area thick))
  (list (cons 'AREA area)
        (cons 'AREA-RAW raw-area)
        (cons 'THICKNESS thick)
        (cons 'WEIGHT weight)
        (cons 'WASTE-PCT waste-pct)))
