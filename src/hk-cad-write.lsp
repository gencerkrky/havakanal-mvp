;; AutoCAD yazma katmanı. (Spec §4.1)
;; MVP: boyut etiketini TEXT olarak yazar (en az bağımlılık).
;; v2'de HK_LABEL bloğuna (attribute'lu) geçilir.
;; AutoCAD dışında test EDİLEMEZ (Task 12'de elle doğrulanır).
(vl-load-com)

;; Bir noktaya boyut + hesap özeti metni yazar.
;; pt: '(x y z), size-str: "400x300", q/v/pam sayısal.
(defun hk-write-label (pt size-str q v pam / txt)
  (setq txt (strcat size-str "  Q=" (rtos q 2 0)
                    " V=" (rtos v 2 1) " Pa/m=" (rtos pam 2 2)))
  (entmake
    (list (cons 0 "TEXT")
          (cons 10 pt)
          (cons 40 50.0)          ; metin yüksekliği (mm) — ayarlanabilir
          (cons 1 txt)
          (cons 8 "HK_ETIKET"))))  ; ayrı layer'a yazılır

;; Bir polyline'ın orta noktasını döndürür (etiket konumu için).
(defun hk-polyline-midpoint (ename / obj p)
  (setq obj (vlax-ename->vla-object ename))
  (setq p (vlax-curve-getPointAtDist obj
            (/ (vlax-curve-getDistAtParam obj (vlax-curve-getEndParam obj)) 2.0)))
  p)
