;; Hava kanalı boyutlandırma çekirdeği testleri (Spec §5).

;; Debi m³/h -> m³/s
(hk-assert-close "3600 m3h -> 1 m3s" 1.0 (hk-q-to-m3s 3600.0))

;; Kesit alanı A = Q/V  (1 m³/s / 5 m/s = 0.2 m²)
(hk-assert-close "A = Q/V" 0.2 (hk-area-from-qv 1.0 5.0))

;; Huebscher eşdeğer çap: a=400 b=300 -> De ≈ 377.709 mm
(hk-assert-close "De 400x300" 377.709 (hk-equiv-diameter 400.0 300.0))

;; Hız geri hesap: V = Q/A
(hk-assert-close "V = Q/A" 5.0 (hk-velocity-from-qa 1.0 0.2))

;; Alan + en-boy oranı -> (a b) mm. A=0.2 m², ar=1.5
;; b=sqrt(200000/1.5)=365.148, a=547.723
(setq dim (hk-rect-from-area-ar 0.2 1.5))
(hk-assert-close "rect a (ar=1.5)" 547.7226 (car dim))
(hk-assert-close "rect b (ar=1.5)" 365.1484 (cadr dim))

;; Sabit hız yöntemi
(setq r (hk-size-constant-velocity 3600.0 5.0 1.5))
(hk-assert-close "cv a" 547.7226 (car r))
(hk-assert-close "cv b" 365.1484 (cadr r))

;; Sürtünme bağıntısı pozitif ve makul aralıkta
(setq pam (hk-friction-rate 0.5 300.0))
(hk-assert-true "friction pozitif" (> pam 0.0))
(hk-assert-true "friction makul aralik (0.1-20 Pa/m)"
                (and (> pam 0.1) (< pam 20.0)))

;; Eşit sürtünme: pozitif boyut + en-boy oranı korunur
(setq r2 (hk-size-equal-friction 3600.0 1.0 1.5))
(hk-assert-true "ef a pozitif" (> (car r2) 0.0))
(hk-assert-true "ef b pozitif" (> (cadr r2) 0.0))
(hk-assert-close "ef ar korunur" 1.5 (/ (car r2) (cadr r2)))

;; Tam sonuç: yuvarlama + gerçek değerler
(setq res (hk-size-full "CV" 3600.0 5.0 1.5))
(hk-assert-equal "full A yuvarli" 600 (cdr (assoc 'A res)))
(hk-assert-equal "full B yuvarli" 400 (cdr (assoc 'B res)))
(hk-assert-true "gercek V < hedef" (< (cdr (assoc 'V-REAL res)) 5.0))
(hk-assert-true "De pozitif" (> (cdr (assoc 'DE res)) 0.0))
