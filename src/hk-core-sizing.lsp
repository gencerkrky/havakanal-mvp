;; Hava kanalı boyutlandırma — SAF hesap çekirdeği. AutoCAD bağımsız.
;; Tüm formüller Spec §5'ten (mühendis onaylı).

;; --- Temel yardımcılar ---

;; Debi birim dönüşümü: m³/h -> m³/s
(defun hk-q-to-m3s (q-m3h)
  (/ q-m3h 3600.0))

;; Kesit alanı: A = Q/V  (Q m³/s, V m/s -> A m²)
(defun hk-area-from-qv (q-m3s v)
  (/ q-m3s v))

;; Hız: V = Q/A
(defun hk-velocity-from-qa (q-m3s a)
  (/ q-m3s a))

;; Huebscher eşdeğer çap (mm). De = 1.30*(a*b)^0.625 / (a+b)^0.250
(defun hk-equiv-diameter (a b)
  (/ (* 1.30 (expt (* a b) 0.625))
     (expt (+ a b) 0.250)))

;; --- Dikdörtgen boyut türetme ---

;; Kesit alanı (m²) + en-boy oranı (a/b) -> (a b) mm.
;; A_mm2 = A_m2 * 1e6 ; b = sqrt(A/ar) ; a = ar*b
(defun hk-rect-from-area-ar (a-m2 ar / a-mm2 b a)
  (setq a-mm2 (* a-m2 1000000.0))
  (setq b (sqrt (/ a-mm2 ar)))
  (setq a (* ar b))
  (list a b))

;; Sabit hız yöntemi: debi(m³/h) + hedef hız(m/s) + en-boy oranı -> ham (a b) mm.
(defun hk-size-constant-velocity (q-m3h v ar / q a)
  (setq q (hk-q-to-m3s q-m3h))
  (setq a (hk-area-from-qv q v))
  (hk-rect-from-area-ar a ar))

;; --- Eşit sürtünme yöntemi ---

;; Sürtünme kaybı oranı (Pa/m) — yaklaşık ductulator bağıntısı.
;; De: eşdeğer çap (mm), q-m3s: debi (m³/s).
;; Bağıntı: Δp/L = 0.022243 * Q^1.852 / De_m^4.973  (galvaniz, ρ≈1.2)
;; NOT: katsayılar yaklaşık; mühendis nomogram testiyle kalibre edilecek (Spec §5, §9).
(setq *hk-friction-k* 0.022243)
(setq *hk-friction-q-exp* 1.852)
(setq *hk-friction-d-exp* 4.973)

(defun hk-friction-rate (q-m3s de-mm / de-m)
  (setq de-m (/ de-mm 1000.0))
  (/ (* *hk-friction-k* (expt q-m3s *hk-friction-q-exp*))
     (expt de-m *hk-friction-d-exp*)))

;; Eşit sürtünme: hedef Pa/m'yi sağlayan eşdeğer çapı bul, sonra en-boy oranıyla a,b.
;; De'yi sürtünme bağıntısından ters çöz: De_m = (k*Q^qexp / target)^(1/dexp)
(defun hk-size-equal-friction (q-m3h target-pam ar / q de-m a-m2)
  (setq q (hk-q-to-m3s q-m3h))
  (setq de-m (expt (/ (* *hk-friction-k* (expt q *hk-friction-q-exp*)) target-pam)
                   (/ 1.0 *hk-friction-d-exp*)))
  ;; eşdeğer çaptan eşdeğer kesit alanına (daire) geç, dikdörtgene en-boy oranıyla dağıt
  (setq a-m2 (* 3.14159265 (/ (* de-m de-m) 4.0)))
  (hk-rect-from-area-ar a-m2 ar))

;; --- Tam boyutlandırma sonucu ---

;; Tam boyutlandırma: ham hesap -> standart yuvarlama -> yuvarlama sonrası gerçek
;; V, Pa/m, De. Cam kutu (Spec §4.1) bunu gösterir.
;; method: "CV" (sabit hız, target=V m/s) veya "EF" (eşit sürtünme, target=Pa/m).
(defun hk-size-full (method q-m3h target ar
                     / raw a-raw b-raw a b q a-m2 v-real pam-real de)
  (cond
    ((= method "CV") (setq raw (hk-size-constant-velocity q-m3h target ar)))
    ((= method "EF") (setq raw (hk-size-equal-friction q-m3h target ar)))
    (t (setq raw nil)))
  (if (null raw)
    nil
    (progn
      (setq a-raw (car raw) b-raw (cadr raw))
      (setq a (hk-round-up-standard a-raw))
      (setq b (hk-round-up-standard b-raw))
      (setq q (hk-q-to-m3s q-m3h))
      ;; yuvarlanmış boyutla gerçek değerler
      (setq a-m2 (/ (* a b) 1000000.0))         ; mm² -> m²
      (setq v-real (hk-velocity-from-qa q a-m2))
      (setq de (hk-equiv-diameter a b))
      (setq pam-real (hk-friction-rate q de))
      (list (cons 'A a) (cons 'B b)
            (cons 'A-RAW a-raw) (cons 'B-RAW b-raw)
            (cons 'DE de)
            (cons 'V-REAL v-real)
            (cons 'PAM-REAL pam-real)))))
