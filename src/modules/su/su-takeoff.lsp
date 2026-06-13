;; Su tesisatı metraj çekirdeği — SAF, AutoCAD bağımsız.

;; Fitting (dirsek/te) götürü payı varsayılan yüzdesi.
(setq *su-fitting-pay-yuzde* 12.0)

;; Boru fitting payı uygula: uzunluğa oransal değil, ayrı bir tahmini adet/uzunluk
;; eklemek yerine MVP'de uzunluğa % fire ekler (basit, sahada kabul gören).
(defun su-apply-fitting-pay (uzunluk-m pay-yuzde)
  (* uzunluk-m (+ 1.0 (/ pay-yuzde 100.0))))

;; Tek hat metraj: sistem+malzeme+çap bazında bir satır verisi üret.
;; Dönüş assoc list: SISTEM MALZEME CAP UZUNLUK UZUNLUK-PAYLI
(defun su-takeoff-segment (sistem malzeme cap uzunluk-m pay-yuzde / payli)
  (setq payli (su-apply-fitting-pay uzunluk-m pay-yuzde))
  (list (cons 'SISTEM sistem)
        (cons 'MALZEME malzeme)
        (cons 'CAP cap)
        (cons 'UZUNLUK uzunluk-m)
        (cons 'UZUNLUK-PAYLI payli)
        (cons 'FITTING-PAY pay-yuzde)))
