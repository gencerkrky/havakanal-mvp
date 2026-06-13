;; CSV dışa aktarma. TR Excel ayraç = noktalı virgül.
;; Hata yönetimi: dosya açılamazsa nil kontrolü, sessiz yutma yok (Spec §6).

(setq *hk-csv-sep* ";")

;; bir değeri string'e çevir (sayı/str/sembol).
(defun hk-csv-cell (v)
  (cond
    ((numberp v) (vl-princ-to-string v))
    ((null v) "")
    (t (vl-princ-to-string v))))

;; assoc list + kolon sırası -> CSV satırı string.
(defun hk-csv-row (row cols / out first)
  (setq out "" first t)
  (foreach c cols
    (setq out (strcat out (if first "" *hk-csv-sep*)
                      (hk-csv-cell (cdr (assoc c row)))))
    (setq first nil))
  out)

;; kolon sembollerinden başlık satırı.
(defun hk-csv-header (cols / out first)
  (setq out "" first t)
  (foreach c cols
    (setq out (strcat out (if first "" *hk-csv-sep*) (vl-princ-to-string c)))
    (setq first nil))
  out)

;; Tüm metrajı dosyaya yaz. rows: assoc list listesi. cols: sembol listesi.
;; Dönüş: T başarılı, nil hata. Hata mesajı komut satırına yazılır.
(defun hk-csv-write (filepath rows cols / f)
  (setq f (open filepath "w"))
  (if (null f)
    (progn
      (princ (strcat "\nHATA: CSV dosyasi acilamadi: " filepath))
      nil)
    (progn
      (write-line (hk-csv-header cols) f)
      (foreach r rows (write-line (hk-csv-row r cols) f))
      (close f)
      (princ (strcat "\nCSV yazildi: " filepath))
      T)))
