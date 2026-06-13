;; Havalandırmaya özel standartlar — TS EN 1505 kademe, sac kalınlığı, boyut parse.
;; SAF — AutoCAD bağımsız, test edilebilir. (Spec §5)

;; TS EN 1505 dikdörtgen kanal standart kenar kademeleri (mm).
(setq *hva-standard-sizes*
  '(100 150 200 250 300 400 500 600 800 1000 1200))

;; Ham kenar ölçüsünü bir üst standart kademeye yuvarlar.
;; En büyük kademeyi aşarsa en büyüğe sabitler (MVP sınırı; v2'de >1200 eklenir).
(defun hva-round-up-standard (raw / lst result)
  (setq lst *hva-standard-sizes*)
  (setq result nil)
  (foreach s lst
    (if (and (null result) (>= s raw))
      (setq result s)))
  (if (null result)
    (setq result (last *hva-standard-sizes*)))
  result)

;; Sac kalınlığı (mm), kanalın en geniş kenarına göre.
;; Spec §5 — SMACNA/DW144 mantığı, mühendis onaylı tablo.
(defun hva-sheet-thickness (max-edge)
  (cond
    ((<= max-edge 600) 0.60)
    ((<= max-edge 1000) 0.80)
    (t 1.00)))

;; "400x300" -> (400 . 300). Hatalı format -> (nil . nil).
(defun hva-parse-size (s / pos)
  (setq pos (vl-string-search "x" (strcase s nil)))
  (if pos
    (cons (atoi (substr s 1 pos)) (atoi (substr s (+ pos 2))))
    (cons nil nil)))
