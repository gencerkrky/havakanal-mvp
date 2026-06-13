;; Sprinkler grid nokta hesabı — SAF (geometri). AutoCAD bağımsız.
;; Çizime yerleştirme yng-commands'ta (mep-cad kullanır).

;; Bir eksende sprinkler merkez koordinatları (m cinsinden, origin'den).
;; boyut: toplam uzunluk (m), s: aralık (m). Duvar payı eşit dağıtılır.
;; Dönüş: koordinat listesi (m).
(defun yng-axis-coords (boyut s / n pay i out)
  (setq n (max 1 (yng-ceil (/ boyut s))))
  ;; ilk/son sprinkler ile duvar arası eşit boşluk:
  (setq pay (/ (- boyut (* (1- n) s)) 2.0))
  (setq out '() i 0)
  (while (< i n)
    (setq out (cons (+ pay (* i s)) out))
    (setq i (1+ i)))
  (reverse out))

;; W x L alan için grid noktaları. origin: '(x0 y0) alanın sol-alt köşesi (mm).
;; w,l: m. s: aralık (m). Dönüş: nokta listesi (mm cinsinden, '(x y 0.0)).
(defun yng-grid-points (origin w l s / xs ys out)
  (setq xs (yng-axis-coords w s))
  (setq ys (yng-axis-coords l s))
  (setq out '())
  (foreach yc ys
    (foreach xc xs
      (setq out (cons (list (+ (car origin) (* xc 1000.0))
                            (+ (cadr origin) (* yc 1000.0))
                            0.0)
                      out))))
  (reverse out))
