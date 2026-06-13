;; Yangın sprinkler hesap çekirdeği — SAF, AutoCAD bağımsız.

;; Tavan-üst yuvarlama (LISP'te fix taban; ceil = -(fix (- x))).
(defun yng-ceil (x / f)
  (setq f (fix x))
  (if (> x f) (1+ f) f))

;; Sprinkler grid aralığı: max koruma alanı ve max aralık kısıtını birlikte sağla.
;; sinif -> S (m). Kare grid: min(Smax, sqrt(Amax)).
(defun yng-spacing (sinif / p amax smax)
  (setq p (yng-hazard-params sinif))
  (if (null p)
    nil
    (progn
      (setq amax (cadr p) smax (caddr p))
      (min smax (sqrt amax)))))

;; Bir W x L (m) alan için sprinkler sayısı (nx*ny).
;; Duvar payı S/2 her iki uçta -> her eksende ceil(boyut/S).
(defun yng-sprinkler-count (w l sinif / s nx ny)
  (setq s (yng-spacing sinif))
  (if (null s)
    nil
    (progn
      (setq nx (max 1 (yng-ceil (/ w s))))
      (setq ny (max 1 (yng-ceil (/ l s))))
      (* nx ny))))

;; Sprinkler debisi: Q = yogunluk * koruma_alani (L/dk). sinif params'tan.
(defun yng-sprinkler-debi (sinif / p)
  (setq p (yng-hazard-params sinif))
  (if (null p) nil (* (car p) (cadr p))))

;; Pipe schedule: tehlike sınıfı + beslediği sprinkler sayısı -> min DN.
;; Tablo dışıysa nil (hidrolik hesap gerekli).
(defun yng-pipe-dn (sinif n-sprinkler / result limit)
  (setq result nil)
  (foreach row *yng-pipe-schedule*
    (if (null result)
      (progn
        (setq limit (if (= sinif "LH") (cadr row) (caddr row)))
        (if (and limit (<= n-sprinkler limit))
          (setq result (car row))))))
  result)
