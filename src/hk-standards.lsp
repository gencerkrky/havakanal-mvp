;; TS EN 1505 standartları, yuvarlama, sac kalınlığı, birim dönüşümü.
;; SAF — AutoCAD bağımsız, test edilebilir. (Spec §5, §2)

;; TS EN 1505 dikdörtgen kanal standart kenar kademeleri (mm).
(setq *hk-standard-sizes*
  '(100 150 200 250 300 400 500 600 800 1000 1200))

;; Ham kenar ölçüsünü bir üst standart kademeye yuvarlar.
;; En büyük kademeyi aşarsa en büyüğe sabitler (MVP sınırı; v2'de >1200 eklenir).
(defun hk-round-up-standard (raw / lst result)
  (setq lst *hk-standard-sizes*)
  (setq result nil)
  (foreach s lst
    (if (and (null result) (>= s raw))
      (setq result s)))
  (if (null result)
    (setq result (last *hk-standard-sizes*)))
  result)

;; Sac kalınlığı (mm), kanalın en geniş kenarına göre.
;; Spec §5 — SMACNA/DW144 mantığı, mühendis onaylı tablo.
(defun hk-sheet-thickness (max-edge)
  (cond
    ((<= max-edge 600) 0.60)
    ((<= max-edge 1000) 0.80)
    (t 1.00)))

;; Basınç birimi dönüşümü: Pa -> mmSS (mm su sütunu). (Spec §2)
(setq *hk-pa-per-mmss* 9.80665)
(defun hk-pa-to-mmss (pa)
  (/ pa *hk-pa-per-mmss*))

;; "400x300" -> (400 . 300). Hatalı format -> (nil . nil).
;; SAF string yardımcısı — AutoCAD'siz test edilebilsin diye burada (Spec planı T11 notu).
(defun hk-parse-size (s / pos)
  (setq pos (vl-string-search "x" (strcase s nil)))
  (if pos
    (cons (atoi (substr s 1 pos)) (atoi (substr s (+ pos 2))))
    (cons nil nil)))
