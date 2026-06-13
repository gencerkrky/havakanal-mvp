;; Su tesisatı boru çapı hesabı — SAF, AutoCAD bağımsız.

;; Varsayılan temiz su tasarım hızı (m/s). İdare/proje farkı için override edilebilir.
(setq *su-temiz-hiz* 2.0)

;; Temiz su iç çap (mm): Q=V*A -> d = sqrt(4Q/(piV)). Q L/s, V m/s.
(defun su-cap-temiz-ic (q-ls v / q-m3s)
  (setq q-m3s (/ q-ls 1000.0))
  (* (sqrt (/ (* 4.0 q-m3s) (* 3.14159265 v))) 1000.0))

;; Temiz su: debi+hız -> önerilen DN (iç çapı bir üst standarda yuvarla).
(defun su-cap-temiz (q-ls v / d)
  (setq d (su-cap-temiz-ic q-ls v))
  (su-round-up-dn d))

;; Temiz su cihaz listesi -> toplam yük birimi (YB).
;; cihaz-listesi: (("lavabo" 3) ("wc-rezervuar" 2) ...)  (tip . adet)
(defun su-yb-topla (cihaz-listesi / toplam yb)
  (setq toplam 0.0)
  (foreach c cihaz-listesi
    (setq yb (cdr (assoc (car c) *su-temiz-cihaz-yb*)))
    (if yb (setq toplam (+ toplam (* yb (cadr c))))))
  toplam)

;; Toplam YB -> temiz su çapı (DN).
(defun su-cap-temiz-yb (toplam-yb)
  (su-lookup-up toplam-yb *su-temiz-yb-cap*))

;; Pis su cihaz listesi -> toplam DU.
(defun su-du-topla (cihaz-listesi / toplam du)
  (setq toplam 0.0)
  (foreach c cihaz-listesi
    (setq du (cdr (assoc (car c) *su-pis-cihaz-du*)))
    (if du (setq toplam (+ toplam (* du (cadr c))))))
  toplam)

;; Toplam DU -> pis su çapı (mm). yatay-mi: T yatay, nil kolon.
(defun su-cap-pis (toplam-du yatay-mi)
  (if yatay-mi
    (su-lookup-up toplam-du *su-pis-yatay-cap*)
    (su-lookup-up toplam-du *su-pis-kolon-cap*)))

;; Pis su eğim kontrolü: T uygun, nil değil. cap mm, egim %.
(defun su-egim-uygun (cap-mm egim-yuzde / min-egim)
  (setq min-egim (if (<= cap-mm 100) *su-min-egim-kucuk* *su-min-egim-buyuk*))
  (>= egim-yuzde min-egim))
