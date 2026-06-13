;; AutoCAD okuma katmanı — vlax-* gerektirir. (Spec §3.2)
;; Bu dosya AutoCAD dışında test EDİLEMEZ; AutoCAD'de elle doğrulanır (Task 12).
(vl-load-com)

;; Bir polyline entity'sinin uzunluğu (metre). DWG birimi mm varsayılır -> /1000.
;; Hata yönetimi: curve değilse nil.
(defun hk-read-length-m (ename / obj len)
  (setq obj (vl-catch-all-apply 'vlax-ename->vla-object (list ename)))
  (if (vl-catch-all-error-p obj)
    nil
    (progn
      (setq len (vl-catch-all-apply 'vlax-curve-getDistAtParam
                  (list obj (vlax-curve-getEndParam obj))))
      (if (vl-catch-all-error-p len) nil (/ len 1000.0)))))

;; Sadece polyline'ları seçtiren seçim. Dönüş: ename listesi (boş olabilir).
(defun hk-select-polylines (/ ss i out)
  (princ "\nKanal polyline'larini sec: ")
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))
  (setq out '())
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq out (cons (ssname ss i) out))
        (setq i (1+ i)))))
  (reverse out))

;; HK_ETIKET metninden boyut string'i oku (örn "400x300"). Yoksa nil.
;; MVP'de etiket TEXT entity'si (blok değil); metnin başındaki "AxB" okunur.
(defun hk-read-size-attr (ename / ed txt)
  (setq ed (vl-catch-all-apply 'entget (list ename)))
  (if (vl-catch-all-error-p ed)
    nil
    (progn
      (setq txt (cdr (assoc 1 ed)))   ; DXF 1 = metin içeriği
      txt)))
