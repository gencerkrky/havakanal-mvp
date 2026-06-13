;; Uyarı kuralları — SAF. Engelleyici değil, sarı bayrak (Spec §5).

(setq *hk-max-aspect-ratio* 4.0)

;; Uygulama tipine göre hız üst eşiği (m/s). Spec §5 tasarım hızları.
(setq *hk-velocity-limits*
  '(("ofis-ana"   . 7.6)
    ("ofis-brans" . 6.0)
    ("ofis-uc"    . 3.5)
    ("konut-ana"  . 4.6)
    ("end-ana"    . 12.7)))

;; en-boy oranı > 4:1 mı? (büyük/küçük kenar)
(defun hk-warn-aspect-ratio (a b / ar)
  (setq ar (/ (max a b) (min a b)))
  (> ar *hk-max-aspect-ratio*))

;; hız, uygulama tipi eşiğini aşıyor mu?
(defun hk-warn-velocity (v app-type / lim)
  (setq lim (cdr (assoc app-type *hk-velocity-limits*)))
  (if lim (> v lim) nil))

;; tüm uyarıları string listesi olarak topla.
(defun hk-collect-warnings (a b v app-type / out)
  (setq out '())
  (if (hk-warn-aspect-ratio a b)
    (setq out (cons "En-boy orani 4:1 ustu: surtunme artar, kanal gurler." out)))
  (if (hk-warn-velocity v app-type)
    (setq out (cons (strcat "Hiz " app-type " esigini asiyor: gurultu riski.") out)))
  (reverse out))
