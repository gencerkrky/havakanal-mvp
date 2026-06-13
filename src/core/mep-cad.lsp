;; Genel CAD I/O — vlax-* gerektirir. Tüm modüller paylaşır.
;; AutoCAD dışında test EDİLEMEZ; AutoCAD'de elle doğrulanır.
(vl-load-com)

;; Bir polyline entity'sinin uzunluğu (metre). DWG birimi mm varsayılır -> /1000.
;; Hata yönetimi: curve değilse nil.
(defun mep-read-length-m (ename / obj len)
  (setq obj (vl-catch-all-apply 'vlax-ename->vla-object (list ename)))
  (if (vl-catch-all-error-p obj)
    nil
    (progn
      (setq len (vl-catch-all-apply 'vlax-curve-getDistAtParam
                  (list obj (vlax-curve-getEndParam obj))))
      (if (vl-catch-all-error-p len) nil (/ len 1000.0)))))

;; Sadece polyline'ları seçtiren seçim. Dönüş: ename listesi (boş olabilir).
(defun mep-select-polylines (/ ss i out)
  (princ "\nPolyline'lari sec: ")
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))
  (setq out '())
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq out (cons (ssname ss i) out))
        (setq i (1+ i)))))
  (reverse out))

;; Bir entity'nin metin içeriğini oku (TEXT/MTEXT için DXF 1). Yoksa nil.
(defun mep-read-text (ename / ed)
  (setq ed (vl-catch-all-apply 'entget (list ename)))
  (if (vl-catch-all-error-p ed)
    nil
    (cdr (assoc 1 ed))))

;; Bir noktaya, verilen layer'a metin yazar.
(defun mep-write-text (pt txt layer)
  (entmake
    (list (cons 0 "TEXT")
          (cons 10 pt)
          (cons 40 50.0)          ; metin yüksekliği (mm) — ayarlanabilir
          (cons 1 txt)
          (cons 8 layer))))

;; Bir polyline'ın orta noktasını döndürür.
(defun mep-polyline-midpoint (ename / obj)
  (setq obj (vlax-ename->vla-object ename))
  (vlax-curve-getPointAtDist obj
    (/ (vlax-curve-getDistAtParam obj (vlax-curve-getEndParam obj)) 2.0)))
