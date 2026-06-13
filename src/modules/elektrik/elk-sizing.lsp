;; Elektrik güç/akım/kesit hesabı — SAF, AutoCAD bağımsız.

(defun elk-ceil (x / f) (setq f (fix x)) (if (> x f) (1+ f) f))

;; Talep gücü: kurulu güç (W) * eş zamanlılık faktörü (tesis tipi).
(defun elk-talep-gucu (p-kurulu tesis-tipi / k)
  (setq k (cdr (assoc tesis-tipi *elk-kes*)))
  (if (null k) (setq k 0.7))
  (* p-kurulu k))

;; Akım (A). faz: "1F" veya "3F". cosfi güç faktörü.
(defun elk-akim (p-w faz cosfi)
  (if (= faz "3F")
    (/ p-w (* *elk-sqrt3* *elk-v-3faz* cosfi))
    (/ p-w (* *elk-v-1faz* cosfi))))

;; Akıma göre en küçük uygun standart sigorta (A).
(defun elk-sec-sigorta (i-amper / result)
  (setq result nil)
  (foreach s *elk-sigorta-list*
    (if (and (null result) (>= s i-amper))
      (setq result s)))
  (if (null result) (last *elk-sigorta-list*) result))

;; Sigorta akımını taşıyabilecek en küçük standart kesit (mm²).
(defun elk-sec-kesit-akim (i-sigorta / result cap)
  (setq result nil)
  (foreach kesit *elk-kesit-list*
    (setq cap (cdr (assoc kesit *elk-kesit-akim*)))
    (if (and (null result) cap (>= cap i-sigorta))
      (setq result kesit)))
  (if (null result) (last *elk-kesit-list*) result))

;; Gerilim düşümü kontrolü. Dönüş: (dusum_volt dusum_yuzde uygun-mu).
;; faz "1F"/"3F", L tek yön (m), kesit mm², I (A).
(defun elk-vdrop (i l-m kesit faz cosfi limit-yuzde / dv v-ref dyuzde)
  (setq v-ref (if (= faz "3F") *elk-v-3faz* *elk-v-1faz*))
  (if (= faz "3F")
    (setq dv (/ (* *elk-sqrt3* *elk-rho-bakir* l-m i cosfi) kesit))
    (setq dv (/ (* 2.0 *elk-rho-bakir* l-m i) kesit)))
  (setq dyuzde (* 100.0 (/ dv v-ref)))
  (list dv dyuzde (<= dyuzde limit-yuzde)))

;; Ana kablo seçim zinciri: akım + sigorta + kesit + gerilim düşümü kontrolü.
;; Gerilim düşümü aşılırsa kesiti bir üst standarda büyüt.
;; Dönüş: (I sigorta kesit dusum_yuzde).
(defun elk-sec-kablo (p-w faz cosfi l-m devre-tipi
                      / i sig kesit limit vd idx)
  (setq i (elk-akim p-w faz cosfi))
  (setq sig (elk-sec-sigorta i))
  (setq kesit (elk-sec-kesit-akim sig))
  (setq limit (cdr (assoc devre-tipi *elk-vdrop-limit*)))
  (if (null limit) (setq limit 3.0))
  ;; gerilim düşümü uygun olana dek kesiti büyüt
  (setq vd (elk-vdrop i l-m kesit faz cosfi limit))
  (while (and (not (caddr vd))
              (< (vl-position kesit *elk-kesit-list*)
                 (1- (length *elk-kesit-list*))))
    (setq idx (1+ (vl-position kesit *elk-kesit-list*)))
    (setq kesit (nth idx *elk-kesit-list*))
    (setq vd (elk-vdrop i l-m kesit faz cosfi limit)))
  (list i sig kesit (cadr vd)))

;; Aydınlatma armatür sayısı: alan(m²) * W/m² / armatür_watt -> adet (yukarı).
(defun elk-armatur-sayisi (alan-m2 mahal-tipi armatur-watt / wm2 toplam)
  (setq wm2 (cdr (assoc mahal-tipi *elk-wm2*)))
  (if (null wm2) (setq wm2 12.0))
  (setq toplam (* wm2 alan-m2))
  (elk-ceil (/ toplam armatur-watt)))

;; Devre sayısı: priz/aydınlatma sorti adedinden (sorti kuralı).
;; Dönüş: (priz_devre ayd_devre).
(defun elk-devre-sayisi (priz-sorti ayd-sorti)
  (list (elk-ceil (/ priz-sorti (float *elk-max-priz-sorti*)))
        (elk-ceil (/ ayd-sorti (float *elk-max-ayd-sorti*)))))
