;; Isı kaybı standartları/tabloları — SAF, AutoCAD bağımsız.
;; Kaynak: TS 825:2024 (6 bölge). Değerler maksimum U sınırları; override edilebilir.

;; Bölge -> eleman -> maksimum U (W/m²K). ((bolge (duvar cati doseme pencere)) ...)
;; Pencere tüm bölgelerde 1.8.
(setq *isi-u-table*
  '((1 (0.45 0.35 0.40 1.8))
    (2 (0.40 0.30 0.35 1.8))
    (3 (0.30 0.25 0.30 1.8))
    (4 (0.25 0.25 0.30 1.8))
    (5 (0.25 0.20 0.25 1.8))
    (6 (0.22 0.18 0.22 1.8))))

;; İç tasarım sıcaklığı (°C) — mahal tipine göre.
(setq *isi-tic*
  '(("salon" . 22.0) ("yatak" . 20.0) ("mutfak" . 20.0)
    ("banyo" . 24.0) ("wc" . 20.0) ("koridor" . 18.0) ("merdiven" . 15.0)))

;; Dış tasarım sıcaklığı (°C) — il/derece-gün. Override edilebilir.
(setq *isi-tdis*
  '(("antalya" . 0.0) ("izmir" . 0.0) ("istanbul" . -3.0) ("bursa" . -6.0)
    ("ankara" . -12.0) ("eskisehir" . -12.0) ("konya" . -12.0)
    ("sivas" . -18.0) ("erzurum" . -18.0) ("kars" . -24.0)))

;; İnfiltrasyon hava değişim sayısı n (1/h) — mahal tipine göre.
;; DİKKAT: mekanik havalandırma debisi DEĞİL (o 6-30); ısı kaybı infiltrasyonu.
(setq *isi-infiltr-n*
  '(("sizdirmaz" . 0.5) ("normal" . 1.0) ("kose" . 1.5) ("mutfak" . 2.0)))

;; İletim kaybı emniyet/zam katsayısı (yön+kuşak zammı yerine basit).
(setq *isi-zam* 1.2)

;; Havanın hacimsel özgül ısısı (Wh/m³K).
(setq *isi-hava-cp* 0.34)

;; Birim dönüşümleri.
(defun isi-kcal-to-watt (kcal) (* kcal 1.163))
(defun isi-watt-to-kcal (w) (* w 0.86))

;; Bölge+eleman U değeri al. eleman: 'duvar 'cati 'doseme 'pencere.
(defun isi-u-deger (bolge eleman / row vals)
  (setq row (assoc bolge *isi-u-table*))
  (if (null row)
    nil
    (progn
      (setq vals (cadr row))
      (cond ((= eleman 'duvar) (nth 0 vals))
            ((= eleman 'cati) (nth 1 vals))
            ((= eleman 'doseme) (nth 2 vals))
            ((= eleman 'pencere) (nth 3 vals))
            (t nil)))))

;; İç sıcaklık al (yoksa salon=22).
(defun isi-get-tic (mahal-tipi / v)
  (setq v (cdr (assoc mahal-tipi *isi-tic*)))
  (if v v 22.0))

;; Dış sıcaklık al (yoksa -12).
(defun isi-get-tdis (il / v)
  (setq v (cdr (assoc il *isi-tdis*)))
  (if v v -12.0))

;; İnfiltrasyon n al (yoksa normal=1.0).
(defun isi-get-n (durum / v)
  (setq v (cdr (assoc durum *isi-infiltr-n*)))
  (if v v 1.0))
