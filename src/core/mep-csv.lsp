;; CSV dışa aktarma — domain-bağımsız. TR Excel ayraç = noktalı virgül.
;; Hata yönetimi: dosya açılamazsa nil kontrolü, sessiz yutma yok.

(setq *mep-csv-sep* ";")

;; bir değeri string'e çevir (sayı/str/sembol).
(defun mep-csv-cell (v)
  (cond
    ((numberp v) (vl-princ-to-string v))
    ((null v) "")
    (t (vl-princ-to-string v))))

;; assoc list + kolon sırası -> CSV satırı string.
(defun mep-csv-row (row cols / out first)
  (setq out "" first t)
  (foreach c cols
    (setq out (strcat out (if first "" *mep-csv-sep*)
                      (mep-csv-cell (cdr (assoc c row)))))
    (setq first nil))
  out)

;; kolon sembollerinden başlık satırı.
(defun mep-csv-header (cols / out first)
  (setq out "" first t)
  (foreach c cols
    (setq out (strcat out (if first "" *mep-csv-sep*) (vl-princ-to-string c)))
    (setq first nil))
  out)

;; rows: assoc list listesi. cols: sembol listesi.
;; UTF-8 BOM (EF BB BF) — Türkçe karakterlerin Excel'de bozulmaması için
;; dosya başına yazılır. AutoLISP'te byte değerlerini chr ile üretiyoruz.
(defun mep-csv-bom ()
  (strcat (chr 239) (chr 187) (chr 191)))

;; Dönüş: T başarılı, nil hata. Hata mesajı komut satırına yazılır.
(defun mep-csv-write (filepath rows cols / f)
  (setq f (open filepath "w"))
  (if (null f)
    (progn
      (princ (strcat "\nHATA: CSV dosyasi acilamadi: " filepath))
      nil)
    (progn
      (write-line (strcat (mep-csv-bom) (mep-csv-header cols)) f)
      (foreach r rows (write-line (mep-csv-row r cols) f))
      (close f)
      (princ (strcat "\nCSV yazildi: " filepath))
      T)))
