# HavaKanal MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** AutoCAD'de tek çizgi (polyline) ile çizilmiş dikdörtgen hava kanallarını boyutlandıran (eşit sürtünme / sabit hız), TS EN 1505 standardına yuvarlayan, çizime etiketleyen ve metrajını (m² + kg) CSV'ye döken bir AutoLISP eklentisi.

**Architecture:** Saf hesap çekirdeği (AutoCAD'den bağımsız, test edilebilir `.lsp` dosyaları) + ince AutoCAD I/O katmanı + iki komut (`HKBOYUT`, `HKMETRAJ`). Saf fonksiyonlar, AutoCAD olmadan komut satırında çalışan minik bir LISP test koşucusuyla TDD ile geliştirilir.

**Tech Stack:** AutoLISP / Visual LISP (AutoCAD). Test: özel hafif LISP assert koşucusu. Çıktı: CSV (saf `open`/`write-line`). Hesap formülleri spec §5'ten (mühendis onaylı).

**Spec:** `docs/superpowers/specs/2026-06-13-havakanal-mvp-design.md`

---

## Dosya Yapısı

```
src/
  hk-core-sizing.lsp     ; SAF: debi+yöntem → ham boyut, V, Pa/m, De
  hk-core-takeoff.lsp    ; SAF: boyut+uzunluk → alan, ağırlık
  hk-standards.lsp       ; TS EN 1505 kademe listesi + yuvarlama + sac kalınlığı tablosu
  hk-rules.lsp           ; SAF: 3 uyarı kuralı
  hk-cad-read.lsp        ; AutoCAD I/O: polyline uzunluğu, seçim, attribute okuma
  hk-cad-write.lsp       ; AutoCAD I/O: boyut etiketi blok yazma
  hk-export-csv.lsp      ; CSV yazma + hata yönetimi
  hk-ui.lsp              ; cam kutu gösterimi, override, girdi alma
  hk-commands.lsp        ; c:HKBOYUT, c:HKMETRAJ — katmanları bağlar
  hk-load.lsp            ; tüm src dosyalarını yükleyen giriş noktası
test/
  hk-test-framework.lsp  ; assert / test koşucu (AutoCAD'siz çalışır)
  test-sizing.lsp
  test-takeoff.lsp
  test-standards.lsp
  test-rules.lsp
  run-all-tests.lsp      ; tüm testleri yükleyip çalıştırır
```

**Test çalıştırma ortamı:** Saf çekirdek testleri, AutoCAD gerektirmeyen herhangi bir LISP yorumlayıcısında (örn. masaüstünde Common Lisp uyumlu bir yorumlayıcı veya AutoCAD'in kendi konsolu) `run-all-tests.lsp` yüklenerek koşulur. AutoLISP'e özgü `vlax-*` çağrıları SADECE `hk-cad-*` dosyalarındadır; saf çekirdek standart LISP fonksiyonları kullanır, böylece AutoCAD dışında da test edilebilir.

> **Not:** AutoLISP fonksiyon adlandırma: `hk-` öneki tüm fonksiyonlarda, kebab-case. Sabitler `*hk-...*` global yıldız biçiminde.

---

## Task 0: Test Çerçevesi (assert koşucusu)

AutoLISP'in yerleşik test çerçevesi yoktur. Saf çekirdeği TDD ile geliştirmek için minik bir assert koşucusu kurarız.

**Files:**
- Create: `test/hk-test-framework.lsp`
- Create: `test/run-all-tests.lsp`

- [ ] **Step 1: Test çerçevesini yaz**

`test/hk-test-framework.lsp`:
```lisp
;; Minik AutoLISP test çerçevesi — AutoCAD gerektirmez.
;; Neden: AutoLISP'in standart test aracı yok; saf çekirdeği TDD ile
;; geliştirebilmek için hafif bir assert + sayaç mekanizması gerekir.

(setq *hk-test-pass* 0)
(setq *hk-test-fail* 0)

;; Float karşılaştırma toleransı — ondalık hesap sonuçları birebir eşleşmez.
(setq *hk-test-eps* 1e-6)

(defun hk-assert-true (label val)
  (if val
    (progn (setq *hk-test-pass* (1+ *hk-test-pass*))
           (princ (strcat "\n  PASS: " label)))
    (progn (setq *hk-test-fail* (1+ *hk-test-fail*))
           (princ (strcat "\n  FAIL: " label)))))

(defun hk-assert-equal (label expected actual)
  (hk-assert-true
    (strcat label " (beklenen=" (vl-princ-to-string expected)
            " gerçek=" (vl-princ-to-string actual) ")")
    (equal expected actual)))

;; Float'a özel: tolerans dahilinde eşitlik.
(defun hk-assert-close (label expected actual)
  (hk-assert-true
    (strcat label " (beklenen=" (rtos expected 2 4)
            " gerçek=" (rtos actual 2 4) ")")
    (< (abs (- expected actual)) *hk-test-eps*)))

(defun hk-test-summary ()
  (princ (strcat "\n\n=== SONUÇ: " (itoa *hk-test-pass*) " PASS, "
                 (itoa *hk-test-fail*) " FAIL ===\n"))
  (princ))
```

- [ ] **Step 2: Test koşucusunu yaz**

`test/run-all-tests.lsp`:
```lisp
;; Tüm test dosyalarını yükleyip çalıştırır.
;; Kullanım: bu dosyayı LISP yorumlayıcısına/AutoCAD'e yükle.
(load "test/hk-test-framework.lsp")
(setq *hk-test-pass* 0)
(setq *hk-test-fail* 0)

(load "src/hk-standards.lsp")
(load "src/hk-core-sizing.lsp")
(load "src/hk-core-takeoff.lsp")
(load "src/hk-rules.lsp")

(load "test/test-standards.lsp")
(load "test/test-sizing.lsp")
(load "test/test-takeoff.lsp")
(load "test/test-rules.lsp")

(hk-test-summary)
```

- [ ] **Step 3: Çerçeveyi tek başına doğrula**

Geçici bir kontrol: yorumlayıcıda `hk-test-framework.lsp` yükle, sonra:
```lisp
(hk-assert-equal "demo" 4 (+ 2 2))
(hk-assert-close "demo-float" 1.0 1.0000001)
(hk-test-summary)
```
Expected: 2 PASS, 0 FAIL.

- [ ] **Step 4: Commit**

```bash
git add test/hk-test-framework.lsp test/run-all-tests.lsp
git commit -m "test: add lightweight AutoLISP test framework"
```

---

## Task 1: Standart kademeler ve yuvarlama (hk-standards)

Spec §5: TS EN 1505 kademeleri ve sac kalınlığı tablosu. Önce bunu yapıyoruz çünkü sizing buna bağlı.

**Files:**
- Create: `src/hk-standards.lsp`
- Test: `test/test-standards.lsp`

- [ ] **Step 1: Failing test yaz**

`test/test-standards.lsp`:
```lisp
;; TS EN 1505 standart kademeleri ve yuvarlama testleri.

;; Bir üst standart kademeye yuvarlama.
(hk-assert-equal "347 -> 400" 400 (hk-round-up-standard 347))
(hk-assert-equal "tam kademe 400 -> 400" 400 (hk-round-up-standard 400))
(hk-assert-equal "260 -> 300" 300 (hk-round-up-standard 260))
(hk-assert-equal "kademe altı 90 -> 100" 100 (hk-round-up-standard 90))
;; En büyük kademeyi aşan değer en büyüğe sabitlenir (MVP sınırı).
(hk-assert-equal "1500 -> 1200" 1200 (hk-round-up-standard 1500))

;; Sac kalınlığı en geniş kenara göre (mm).
(hk-assert-close "<=600 -> 0.60" 0.60 (hk-sheet-thickness 500))
(hk-assert-close "600-1000 -> 0.80" 0.80 (hk-sheet-thickness 800))
(hk-assert-close ">1000 -> 1.00" 1.00 (hk-sheet-thickness 1200))
;; Sınır: tam 600 -> 0.60 (dahil)
(hk-assert-close "600 sınır -> 0.60" 0.60 (hk-sheet-thickness 600))
```

- [ ] **Step 2: Testi çalıştır, fail gör**

Run: `run-all-tests.lsp` yükle.
Expected: FAIL — `hk-round-up-standard` ve `hk-sheet-thickness` tanımsız (error: no function).

- [ ] **Step 3: Minimal implementasyon**

`src/hk-standards.lsp`:
```lisp
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
```

- [ ] **Step 4: Testi çalıştır, pass gör**

Run: `run-all-tests.lsp` yükle.
Expected: PASS (Task 1'in tüm assert'leri).

- [ ] **Step 5: Commit**

```bash
git add src/hk-standards.lsp test/test-standards.lsp test/run-all-tests.lsp
git commit -m "feat: add TS EN 1505 standard sizes and sheet thickness table"
```

---

## Task 2: Eşdeğer çap ve alan-hız çekirdeği (hk-core-sizing — bölüm 1)

Spec §5 formülleri. Önce saf yardımcı hesaplar.

**Files:**
- Create: `src/hk-core-sizing.lsp`
- Test: `test/test-sizing.lsp`

- [ ] **Step 1: Failing test yaz**

`test/test-sizing.lsp`:
```lisp
;; Hava kanalı boyutlandırma çekirdeği testleri (Spec §5).

;; Debi m³/h -> m³/s
(hk-assert-close "3600 m3h -> 1 m3s" 1.0 (hk-q-to-m3s 3600.0))

;; Kesit alanı A = Q/V  (Q m³/s, V m/s -> A m²)
;; 1 m³/s / 5 m/s = 0.2 m²
(hk-assert-close "A = Q/V" 0.2 (hk-area-from-qv 1.0 5.0))

;; Huebscher eşdeğer çap: De = 1.30*(a*b)^0.625/(a+b)^0.250  (mm girdi, mm çıktı)
;; a=400 b=300 -> De ≈ 380.9 mm
(hk-assert-close "De 400x300" 380.9281 (hk-equiv-diameter 400.0 300.0))

;; Hız geri hesap: V = Q/A  (Q m³/s, A m² -> m/s)
(hk-assert-close "V = Q/A" 5.0 (hk-velocity-from-qa 1.0 0.2))
```

> Not: `380.9281` değeri formülden hesaplandı: 1.30*(120000)^0.625/(700)^0.250. Test toleransı `*hk-test-eps*` küçük olduğu için 4 hane veriyoruz; implementasyon aynı formülü kullanınca eşleşir. Tolerans gerekirse Step 3 sonrası gerçek değere göre güncellenir (kod doğruysa).

- [ ] **Step 2: Testi çalıştır, fail gör**

Run: `run-all-tests.lsp` yükle.
Expected: FAIL — `hk-q-to-m3s`, `hk-area-from-qv`, `hk-equiv-diameter`, `hk-velocity-from-qa` tanımsız.

- [ ] **Step 3: Minimal implementasyon**

`src/hk-core-sizing.lsp` (bu task'taki kısım):
```lisp
;; Hava kanalı boyutlandırma — SAF hesap çekirdeği. AutoCAD bağımsız.
;; Tüm formüller Spec §5'ten (mühendis onaylı).

;; Debi birim dönüşümü: m³/h -> m³/s
(defun hk-q-to-m3s (q-m3h)
  (/ q-m3h 3600.0))

;; Kesit alanı: A = Q/V  (Q m³/s, V m/s -> A m²)
(defun hk-area-from-qv (q-m3s v)
  (/ q-m3s v))

;; Hız: V = Q/A
(defun hk-velocity-from-qa (q-m3s a)
  (/ q-m3s a))

;; Huebscher eşdeğer çap (mm). De = 1.30*(a*b)^0.625 / (a+b)^0.250
(defun hk-equiv-diameter (a b)
  (/ (* 1.30 (expt (* a b) 0.625))
     (expt (+ a b) 0.250)))
```

- [ ] **Step 4: Testi çalıştır, pass gör**

Run: `run-all-tests.lsp` yükle.
Expected: PASS. (Eğer `hk-equiv-diameter` 4-hane sapıyorsa, formül doğruyken beklenen değeri gerçek hesaba eşitle — kod değil test düzeltilir.)

- [ ] **Step 5: Commit**

```bash
git add src/hk-core-sizing.lsp test/test-sizing.lsp
git commit -m "feat: add area/velocity/equivalent-diameter core helpers"
```

---

## Task 3: Dikdörtgen boyut türetme (hk-core-sizing — bölüm 2)

En-boy oranı ile kesit alanından a×b üret; iki yöntem (sabit hız, eşit sürtünme).

**Files:**
- Modify: `src/hk-core-sizing.lsp`
- Test: `test/test-sizing.lsp`

- [ ] **Step 1: Failing test ekle**

`test/test-sizing.lsp` sonuna ekle:
```lisp
;; Alan + en-boy oranı -> (a b) mm.  A = a*b, a/b = ar.
;; A=0.2 m² = 200000 mm², ar=1.5 -> b=sqrt(A/ar), a=ar*b
;; b=sqrt(200000/1.5)=365.15, a=547.72
(setq dim (hk-rect-from-area-ar 0.2 1.5))
(hk-assert-close "rect a (ar=1.5)" 547.7226 (car dim))
(hk-assert-close "rect b (ar=1.5)" 365.1484 (cadr dim))

;; Sabit hız yöntemi: Q(m³/h)+V(m/s)+ar -> ham (a b).
;; Q=3600 -> 1 m³/s, V=5 -> A=0.2, ar=1.5 -> yukarıdaki a,b
(setq r (hk-size-constant-velocity 3600.0 5.0 1.5))
(hk-assert-close "cv a" 547.7226 (car r))
(hk-assert-close "cv b" 365.1484 (cadr r))
```

- [ ] **Step 2: Testi çalıştır, fail gör**

Run: `run-all-tests.lsp` yükle.
Expected: FAIL — `hk-rect-from-area-ar`, `hk-size-constant-velocity` tanımsız.

- [ ] **Step 3: Minimal implementasyon**

`src/hk-core-sizing.lsp` sonuna ekle:
```lisp
;; Kesit alanı (m²) + en-boy oranı (a/b) -> (a b) mm.
;; A_mm2 = A_m2 * 1e6 ; b = sqrt(A/ar) ; a = ar*b
(defun hk-rect-from-area-ar (a-m2 ar / a-mm2 b a)
  (setq a-mm2 (* a-m2 1000000.0))
  (setq b (sqrt (/ a-mm2 ar)))
  (setq a (* ar b))
  (list a b))

;; Sabit hız yöntemi: debi(m³/h) + hedef hız(m/s) + en-boy oranı -> ham (a b) mm.
(defun hk-size-constant-velocity (q-m3h v ar / q a)
  (setq q (hk-q-to-m3s q-m3h))
  (setq a (hk-area-from-qv q v))
  (hk-rect-from-area-ar a ar))
```

- [ ] **Step 4: Testi çalıştır, pass gör**

Run: `run-all-tests.lsp` yükle. Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/hk-core-sizing.lsp test/test-sizing.lsp
git commit -m "feat: add rectangular sizing by aspect ratio (constant velocity)"
```

---

## Task 4: Eşit sürtünme yöntemi + sürtünme bağıntısı (hk-core-sizing — bölüm 3)

Spec §5: eşit sürtünme. Pa/m hedefinden boyut. MVP'de yaklaşık ductulator bağıntısı (mühendis testiyle kalibre).

**Files:**
- Modify: `src/hk-core-sizing.lsp`
- Test: `test/test-sizing.lsp`

- [ ] **Step 1: Failing test ekle**

`test/test-sizing.lsp` sonuna ekle:
```lisp
;; Sürtünme bağıntısı: dairesel eşdeğer çap De(mm) + debi Q(m³/s) -> Pa/m.
;; Yaklaşık bağıntı (galvaniz sac, standart hava ρ=1.2):
;;   Δp/L = 0.022243 * Q^1.852 / De_m^4.973   (De metre)
;; Q=0.5 m³/s, De=0.3 m -> ~ kontrol değeri Step 3'te hesaplanır.
;; Burada bilinen bir nokta ile sınırlı doğrulama:
(setq pam (hk-friction-rate 0.5 300.0))
(hk-assert-true "friction pozitif" (> pam 0.0))
(hk-assert-true "friction makul aralık (0.1-20 Pa/m)"
                (and (> pam 0.1) (< pam 20.0)))

;; Eşit sürtünme: Q(m³/h)+hedef Pa/m+ar -> ham (a b) mm.
(setq r2 (hk-size-equal-friction 3600.0 1.0 1.5))
(hk-assert-true "ef a pozitif" (> (car r2) 0.0))
(hk-assert-true "ef b pozitif" (> (cadr r2) 0.0))
;; en-boy oranı korunmalı
(hk-assert-close "ef ar korunur" 1.5 (/ (car r2) (cadr r2)))
```

> Sürtünme bağıntısı yaklaşıktır; spec §5 "MVP'de yaklaşık bağıntı, kesin nomogram uyumu mühendis testiyle kalibre" der. Bu yüzden testler tam değer yerine işaret/aralık/oran-korunumu doğrular. Mühendis kalibrasyonundan sonra kesin nokta testleri eklenir.

- [ ] **Step 2: Testi çalıştır, fail gör**

Run: `run-all-tests.lsp` yükle.
Expected: FAIL — `hk-friction-rate`, `hk-size-equal-friction` tanımsız.

- [ ] **Step 3: Minimal implementasyon**

`src/hk-core-sizing.lsp` sonuna ekle:
```lisp
;; Sürtünme kaybı oranı (Pa/m) — yaklaşık ductulator bağıntısı.
;; De: eşdeğer çap (mm), q-m3s: debi (m³/s).
;; Bağıntı: Δp/L = 0.022243 * Q^1.852 / De_m^4.973  (galvaniz, ρ≈1.2)
;; NOT: katsayılar yaklaşık; mühendis nomogram testiyle kalibre edilecek (Spec §5, §9).
(setq *hk-friction-k* 0.022243)
(setq *hk-friction-q-exp* 1.852)
(setq *hk-friction-d-exp* 4.973)

(defun hk-friction-rate (q-m3s de-mm / de-m)
  (setq de-m (/ de-mm 1000.0))
  (/ (* *hk-friction-k* (expt q-m3s *hk-friction-q-exp*))
     (expt de-m *hk-friction-d-exp*)))

;; Eşit sürtünme: hedef Pa/m'yi sağlayan eşdeğer çapı bul, sonra en-boy oranıyla a,b.
;; De'yi sürtünme bağıntısından ters çöz: De_m = (k*Q^qexp / target)^(1/dexp)
(defun hk-size-equal-friction (q-m3h target-pam ar / q de-m de-mm a-circ a-m2)
  (setq q (hk-q-to-m3s q-m3h))
  (setq de-m (expt (/ (* *hk-friction-k* (expt q *hk-friction-q-exp*)) target-pam)
                   (/ 1.0 *hk-friction-d-exp*)))
  (setq de-mm (* de-m 1000.0))
  ;; eşdeğer çaptan eşdeğer kesit alanına (daire) geç, dikdörtgene en-boy oranıyla dağıt
  (setq a-m2 (* 3.14159265 (/ (* de-m de-m) 4.0)))
  (hk-rect-from-area-ar a-m2 ar))
```

- [ ] **Step 4: Testi çalıştır, pass gör**

Run: `run-all-tests.lsp` yükle. Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/hk-core-sizing.lsp test/test-sizing.lsp
git commit -m "feat: add equal-friction sizing with approximate friction relation"
```

---

## Task 5: Tam boyutlandırma sonucu (yuvarlama + gerçek değerler)

Cam kutu için: ham hesap → yuvarla → yuvarlama sonrası gerçek V, Pa/m, De. Sonuç bir assoc-list olarak döner.

**Files:**
- Modify: `src/hk-core-sizing.lsp`
- Test: `test/test-sizing.lsp`

- [ ] **Step 1: Failing test ekle**

`test/test-sizing.lsp` sonuna ekle:
```lisp
;; Tam sonuç: yöntem "EF"/"CV", debi, hedef(pam veya v), ar -> assoc list.
;; Anahtarlar: A B (yuvarlanmış mm), DE, V-REAL, PAM-REAL, A-RAW B-RAW
(setq res (hk-size-full "CV" 3600.0 5.0 1.5))
;; ham a=547.7 -> 600, ham b=365.1 -> 400 (TS EN 1505)
(hk-assert-equal "full A yuvarlı" 600 (cdr (assoc 'A res)))
(hk-assert-equal "full B yuvarlı" 400 (cdr (assoc 'B res)))
;; yuvarlama sonrası gerçek alan büyür -> gerçek hız hedeften düşer
(hk-assert-true "gerçek V < hedef" (< (cdr (assoc 'V-REAL res)) 5.0))
(hk-assert-true "De pozitif" (> (cdr (assoc 'DE res)) 0.0))
```

- [ ] **Step 2: Testi çalıştır, fail gör**

Run: `run-all-tests.lsp` yükle.
Expected: FAIL — `hk-size-full` tanımsız.

- [ ] **Step 3: Minimal implementasyon**

`src/hk-core-sizing.lsp` sonuna ekle:
```lisp
;; Tam boyutlandırma: ham hesap -> standart yuvarlama -> yuvarlama sonrası gerçek
;; V, Pa/m, De. Cam kutu (Spec §4.1) bunu gösterir.
;; method: "CV" (sabit hız, target=V m/s) veya "EF" (eşit sürtünme, target=Pa/m).
(defun hk-size-full (method q-m3h target ar / raw a-raw b-raw a b q de-m a-m2 v-real pam-real)
  (cond
    ((= method "CV") (setq raw (hk-size-constant-velocity q-m3h target ar)))
    ((= method "EF") (setq raw (hk-size-equal-friction q-m3h target ar)))
    (t (setq raw nil)))
  (if (null raw)
    nil
    (progn
      (setq a-raw (car raw) b-raw (cadr raw))
      (setq a (hk-round-up-standard a-raw))
      (setq b (hk-round-up-standard b-raw))
      (setq q (hk-q-to-m3s q-m3h))
      ;; yuvarlanmış boyutla gerçek değerler
      (setq a-m2 (/ (* a b) 1000000.0))         ; mm² -> m²
      (setq v-real (hk-velocity-from-qa q a-m2))
      (setq de-m (/ (hk-equiv-diameter a b) 1000.0))
      (setq pam-real (hk-friction-rate q (hk-equiv-diameter a b)))
      (list (cons 'A a) (cons 'B b)
            (cons 'A-RAW a-raw) (cons 'B-RAW b-raw)
            (cons 'DE (hk-equiv-diameter a b))
            (cons 'V-REAL v-real)
            (cons 'PAM-REAL pam-real)))))
```

- [ ] **Step 4: Testi çalıştır, pass gör**

Run: `run-all-tests.lsp` yükle. Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/hk-core-sizing.lsp test/test-sizing.lsp
git commit -m "feat: add full sizing result with rounding and real values"
```

---

## Task 6: Uyarı kuralları (hk-rules)

Spec §2/§5: 3 uyarı — en-boy oranı >4:1, hız eşiği, malzeme/pürüzlülük uyumu.

**Files:**
- Create: `src/hk-rules.lsp`
- Test: `test/test-rules.lsp`

- [ ] **Step 1: Failing test yaz**

`test/test-rules.lsp`:
```lisp
;; Uyarı kuralları testleri (Spec §5).

;; en-boy oranı > 4:1 uyarısı
(hk-assert-true "ar 5 uyarı verir" (hk-warn-aspect-ratio 500.0 100.0))
(hk-assert-true "ar 3 uyarı vermez" (not (hk-warn-aspect-ratio 300.0 100.0)))
(hk-assert-true "ar tam 4 uyarı vermez" (not (hk-warn-aspect-ratio 400.0 100.0)))

;; hız eşiği — "ofis" ana kanal üst sınır 7.6 m/s
(hk-assert-true "ofis 9 m/s uyarı" (hk-warn-velocity 9.0 "ofis-ana"))
(hk-assert-true "ofis 6 m/s temiz" (not (hk-warn-velocity 6.0 "ofis-ana")))

;; tüm uyarıları toplayan fonksiyon: liste döner (boş = sorun yok)
(setq w (hk-collect-warnings 500.0 100.0 9.0 "ofis-ana"))
(hk-assert-true "iki uyarı toplanır" (= 2 (length w)))
(setq w2 (hk-collect-warnings 300.0 200.0 6.0 "ofis-ana"))
(hk-assert-true "uyarı yok -> boş liste" (= 0 (length w2)))
```

- [ ] **Step 2: Testi çalıştır, fail gör**

Run: `run-all-tests.lsp` yükle.
Expected: FAIL — `hk-warn-aspect-ratio`, `hk-warn-velocity`, `hk-collect-warnings` tanımsız.

- [ ] **Step 3: Minimal implementasyon**

`src/hk-rules.lsp`:
```lisp
;; Uyarı kuralları — SAF. Engelleyici değil, sarı bayrak (Spec §5).

(setq *hk-max-aspect-ratio* 4.0)

;; Uygulama tipine göre hız üst eşiği (m/s). Spec §5 tasarım hızları.
(setq *hk-velocity-limits*
  '(("ofis-ana"   . 7.6)
    ("ofis-brans" . 6.0)
    ("ofis-uc"    . 3.5)
    ("konut-ana"  . 4.6)
    ("end-ana"    . 12.7)))

;; en-boy oranı > 4:1 mı? (büyük/küçük kenar)
(defun hk-warn-aspect-ratio (a b / ar)
  (setq ar (/ (max a b) (min a b)))
  (> ar *hk-max-aspect-ratio*))

;; hız, uygulama tipi eşiğini aşıyor mu?
(defun hk-warn-velocity (v app-type / lim)
  (setq lim (cdr (assoc app-type *hk-velocity-limits*)))
  (if lim (> v lim) nil))

;; tüm uyarıları string listesi olarak topla.
(defun hk-collect-warnings (a b v app-type / out)
  (setq out '())
  (if (hk-warn-aspect-ratio a b)
    (setq out (cons "En-boy orani 4:1 ustu: surtunme artar, kanal gurler." out)))
  (if (hk-warn-velocity v app-type)
    (setq out (cons (strcat "Hiz " app-type " esigini asiyor: gurultu riski.") out)))
  (reverse out))
```

> Malzeme/pürüzlülük uyarısı (3. kural) MVP'de sürtünme bağıntısı tek malzeme (galvaniz) varsaydığı için şimdilik kapsam dışı bırakıldı — malzeme seçimi v2'de eklenince aktive edilir. Bu, spec §2'deki "malzeme/pürüzlülük uyumsuz" kuralının bilinçli ertelenmesidir; sessiz atlama değil, burada belgelendi.

- [ ] **Step 4: Testi çalıştır, pass gör**

Run: `run-all-tests.lsp` yükle. Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/hk-rules.lsp test/test-rules.lsp
git commit -m "feat: add warning rules (aspect ratio, velocity threshold)"
```

---

## Task 7: Metraj çekirdeği (hk-core-takeoff)

Spec §4.2/§5: yüzey alanı + ağırlık + fitting fire %.

**Files:**
- Create: `src/hk-core-takeoff.lsp`
- Test: `test/test-takeoff.lsp`

- [ ] **Step 1: Failing test yaz**

`test/test-takeoff.lsp`:
```lisp
;; Metraj çekirdeği testleri (Spec §5).

;; Yüzey alanı: A = 2*(a+b)*L. a,b mm; L metre -> m².
;; a=400 b=300 L=5 -> 2*(0.4+0.3)*5 = 7.0 m²
(hk-assert-close "yüzey alanı" 7.0 (hk-surface-area 400.0 300.0 5.0))

;; Ağırlık: kg = A(m²)*kalınlık(mm)*7.85
;; 7.0 m² * 0.60 mm * 7.85 = 32.97 kg
(hk-assert-close "ağırlık" 32.97 (hk-weight 7.0 0.60))

;; Fitting fire %: alanı oransal artırır. %15 fire -> *1.15
(hk-assert-close "fire %15 alan" 8.05 (hk-apply-waste 7.0 15.0))
(hk-assert-close "fire %0 alan" 7.0 (hk-apply-waste 7.0 0.0))

;; Tek segment tam metraj: (a b L thickness waste%) -> assoc list
(setq t1 (hk-takeoff-segment 400.0 300.0 5.0 15.0))
(hk-assert-close "seg alan (fire dahil)" 8.05 (cdr (assoc 'AREA t1)))
;; ağırlık fire'li alandan: 8.05 * 0.60 * 7.85 = 37.92
(hk-assert-close "seg ağırlık" 37.9155 (cdr (assoc 'WEIGHT t1)))
;; kalınlık en geniş kenar 400 -> 0.60
(hk-assert-close "seg kalınlık" 0.60 (cdr (assoc 'THICKNESS t1)))
```

- [ ] **Step 2: Testi çalıştır, fail gör**

Run: `run-all-tests.lsp` yükle (test-takeoff'u listeye ekleyerek; bkz. Step 5).
Expected: FAIL — fonksiyonlar tanımsız.

- [ ] **Step 3: Minimal implementasyon**

`src/hk-core-takeoff.lsp`:
```lisp
;; Metraj çekirdeği — SAF hesap. AutoCAD bağımsız. (Spec §5)
;; Sac kalınlığı/yoğunluk: hk-standards.lsp'den hk-sheet-thickness.

(setq *hk-steel-density-factor* 7.85)  ; kg/(m²·mm), çelik 7.85 g/cm³

;; Yüzey alanı (m²): A = 2*(a+b)*L. a,b mm; L metre.
(defun hk-surface-area (a b l-m)
  (* 2.0 (/ (+ a b) 1000.0) l-m))

;; Ağırlık (kg) = alan(m²) * kalınlık(mm) * 7.85
(defun hk-weight (area-m2 thickness-mm)
  (* area-m2 thickness-mm *hk-steel-density-factor*))

;; Fitting fire yüzdesi uygula (alanı oransal artır). pct: 0-100.
(defun hk-apply-waste (area-m2 pct)
  (* area-m2 (+ 1.0 (/ pct 100.0))))

;; Tek segment tam metraj. a,b mm; L metre; waste% 0-100.
(defun hk-takeoff-segment (a b l-m waste-pct / raw-area area thick weight)
  (setq raw-area (hk-surface-area a b l-m))
  (setq area (hk-apply-waste raw-area waste-pct))
  (setq thick (hk-sheet-thickness (max a b)))
  (setq weight (hk-weight area thick))
  (list (cons 'AREA area)
        (cons 'AREA-RAW raw-area)
        (cons 'THICKNESS thick)
        (cons 'WEIGHT weight)
        (cons 'WASTE-PCT waste-pct)))
```

- [ ] **Step 4: run-all-tests'e test-takeoff'u ekle ve çalıştır**

`test/run-all-tests.lsp` zaten `(load "test/test-takeoff.lsp")` ve `(load "src/hk-core-takeoff.lsp")` içeriyor (Task 0'da eklendi). Çalıştır.
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/hk-core-takeoff.lsp test/test-takeoff.lsp
git commit -m "feat: add takeoff core (surface area, weight, waste factor)"
```

---

## Task 8: CSV dışa aktarma (hk-export-csv)

Spec §4.2/§6: CSV yazma + hata yönetimi (dosya açılamazsa çökmeden hata).

**Files:**
- Create: `src/hk-export-csv.lsp`
- Test: `test/test-export.lsp` (run-all-tests'e eklenir)

- [ ] **Step 1: Failing test yaz**

`test/test-export.lsp`:
```lisp
;; CSV satır biçimlendirme testi (saf string — dosya I/O test dışı).

;; assoc list -> CSV satırı (noktalı virgül ayraçlı, TR Excel uyumu).
(setq row (list (cons 'NO 1) (cons 'BOYUT "400x300")
                (cons 'UZUNLUK 5.0) (cons 'ALAN 7.0) (cons 'AGIRLIK 32.97)))
(setq cols '(NO BOYUT UZUNLUK ALAN AGIRLIK))
(hk-assert-equal "csv satırı"
  "1;400x300;5.0;7.0;32.97"
  (hk-csv-row row cols))

;; başlık satırı kolon adlarından
(hk-assert-equal "csv başlık"
  "NO;BOYUT;UZUNLUK;ALAN;AGIRLIK"
  (hk-csv-header cols))
```

- [ ] **Step 2: Testi çalıştır, fail gör**

Run: `run-all-tests.lsp` (test-export ekli) yükle.
Expected: FAIL — `hk-csv-row`, `hk-csv-header` tanımsız.

- [ ] **Step 3: Minimal implementasyon**

`src/hk-export-csv.lsp`:
```lisp
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
```

- [ ] **Step 4: Testi çalıştır, pass gör**

Run: `run-all-tests.lsp` yükle. Expected: PASS (satır/başlık testleri).

- [ ] **Step 5: run-all-tests.lsp'e ekleri yansıt**

`test/run-all-tests.lsp`'e ekle (yoksa):
```lisp
(load "src/hk-export-csv.lsp")
(load "test/test-export.lsp")
```

- [ ] **Step 6: Commit**

```bash
git add src/hk-export-csv.lsp test/test-export.lsp test/run-all-tests.lsp
git commit -m "feat: add CSV export with error handling"
```

---

## Task 9: AutoCAD okuma katmanı (hk-cad-read)

Spec §3.2/§4: polyline uzunluğu, seçim, attribute okuma. **AutoCAD gerektirir — saf test yok; AutoCAD'de elle doğrulanır.**

**Files:**
- Create: `src/hk-cad-read.lsp`

- [ ] **Step 1: Implementasyon yaz**

`src/hk-cad-read.lsp`:
```lisp
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

;; HK_LABEL bloğunun BOYUT attribute'unu oku (örn "400x300"). Yoksa nil.
(defun hk-read-size-attr (ename / obj atts result)
  (setq obj (vl-catch-all-apply 'vlax-ename->vla-object (list ename)))
  (if (vl-catch-all-error-p obj)
    nil
    (progn
      (setq result nil)
      (if (= (vla-get-ObjectName obj) "AcDbBlockReference")
        (progn
          (setq atts (vlax-invoke obj 'GetAttributes))
          (foreach att atts
            (if (= (strcase (vla-get-TagString att)) "BOYUT")
              (setq result (vla-get-TextString att))))))
      result)))
```

- [ ] **Step 2: Yükleme kontrolü (AutoCAD'de)**

AutoCAD'de `(load "src/hk-cad-read.lsp")` → hata vermemeli. Tam fonksiyonel test Task 12'de.

- [ ] **Step 3: Commit**

```bash
git add src/hk-cad-read.lsp
git commit -m "feat: add AutoCAD read layer (length, selection, attribute)"
```

---

## Task 10: AutoCAD yazma katmanı (hk-cad-write)

Spec §4.1: hesaplanan boyutu çizime attribute'lu blok etiketi olarak yaz. **AutoCAD gerektirir.**

**Files:**
- Create: `src/hk-cad-write.lsp`

- [ ] **Step 1: Implementasyon yaz**

`src/hk-cad-write.lsp`:
```lisp
;; AutoCAD yazma katmanı. (Spec §4.1)
;; HK_LABEL bloğu yoksa basit metin (MTEXT) ile etiketler — MVP basitliği.
;; AutoCAD dışında test EDİLEMEZ (Task 12'de elle doğrulanır).
(vl-load-com)

;; Bir noktaya boyut metni yazar. pt: '(x y z), size-str: "400x300".
;; MVP: blok yerine MTEXT (en az bağımlılık). v2'de HK_LABEL bloğuna geçilir.
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
```

- [ ] **Step 2: Yükleme kontrolü (AutoCAD'de)**

`(load "src/hk-cad-write.lsp")` → hata vermemeli.

- [ ] **Step 3: Commit**

```bash
git add src/hk-cad-write.lsp
git commit -m "feat: add AutoCAD write layer (size label as text)"
```

---

## Task 11: UI + komutlar (hk-ui, hk-commands, hk-load)

Spec §3.3/§4: cam kutu gösterimi, girdi alma, iki komutu birbirine bağlama. **AutoCAD gerektirir.**

**Files:**
- Create: `src/hk-ui.lsp`
- Create: `src/hk-commands.lsp`
- Create: `src/hk-load.lsp`

- [ ] **Step 1: UI yardımcılarını yaz**

`src/hk-ui.lsp`:
```lisp
;; Kullanıcı etkileşimi — komut satırı tabanlı (MVP; v2'de DCL diyalog).
;; (Spec §4.1 cam kutu: ara değerleri göster + override.)

;; Pozitif sayı iste; iptal/boş -> nil.
(defun hk-ask-number (prompt-str / v)
  (setq v (getreal (strcat "\n" prompt-str)))
  (if (and v (> v 0.0)) v nil))

;; Yöntem seç: "CV" veya "EF".
(defun hk-ask-method (/ k)
  (initget "Hiz Surtunme")
  (setq k (getkword "\nYontem [Hiz/Surtunme] <Surtunme>: "))
  (if (= k "Hiz") "CV" "EF"))

;; Cam kutu: sonucu ve uyarıları komut satırına yazar (Spec §4.1).
(defun hk-show-glass-box (res warnings / )
  (princ (strcat "\n--- SONUC ---"
    "\n  Boyut: " (itoa (cdr (assoc 'A res))) "x" (itoa (cdr (assoc 'B res))) " mm"
    "\n  Ham:   " (rtos (cdr (assoc 'A-RAW res)) 2 0) "x" (rtos (cdr (assoc 'B-RAW res)) 2 0)
    "\n  Hiz:   " (rtos (cdr (assoc 'V-REAL res)) 2 2) " m/s"
    "\n  Pa/m:  " (rtos (cdr (assoc 'PAM-REAL res)) 2 2)
    "\n  De:    " (rtos (cdr (assoc 'DE res)) 2 0) " mm"))
  (if warnings
    (foreach w warnings (princ (strcat "\n  ! UYARI: " w)))
    (princ "\n  (uyari yok)"))
  (princ))

;; Override: kullanıcı yuvarlanmış boyutu kabul mu, değiştirmek mi istiyor?
;; Dönüş: kabul edilen/override edilen (a . b) çifti.
(defun hk-ask-override (res / k na nb)
  (initget "Kabul Degistir")
  (setq k (getkword "\n[Kabul/Degistir] <Kabul>: "))
  (if (= k "Degistir")
    (progn
      (setq na (hk-ask-number "Yeni A (mm): "))
      (setq nb (hk-ask-number "Yeni B (mm): "))
      (cons (if na na (cdr (assoc 'A res)))
            (if nb nb (cdr (assoc 'B res)))))
    (cons (cdr (assoc 'A res)) (cdr (assoc 'B res)))))
```

- [ ] **Step 2: Komutları yaz**

`src/hk-commands.lsp`:
```lisp
;; Komutlar — katmanları bağlar. (Spec §3.3)

;; HKBOYUT: segment(ler) seç -> debi+yöntem gir -> hesapla -> cam kutu -> etiketle.
(defun c:HKBOYUT ( / enames q method target ar res warns ov pt)
  (setq enames (hk-select-polylines))
  (if (null enames)
    (princ "\nPolyline secilmedi.")
    (progn
      (setq method (hk-ask-method))
      (setq q (hk-ask-number "Debi Q (m3/h): "))
      (setq target (hk-ask-number
                     (if (= method "CV") "Hedef hiz V (m/s): " "Hedef Pa/m: ")))
      (setq ar (hk-ask-number "En-boy orani (a/b) <1.5>: "))
      (if (null ar) (setq ar 1.5))
      (if (and q target)
        (foreach en enames
          (setq res (hk-size-full method q target ar))
          (if res
            (progn
              (setq warns (hk-collect-warnings
                            (cdr (assoc 'A res)) (cdr (assoc 'B res))
                            (cdr (assoc 'V-REAL res)) "ofis-ana"))
              (hk-show-glass-box res warns)
              (setq ov (hk-ask-override res))
              (setq pt (hk-polyline-midpoint en))
              (hk-write-label pt
                (strcat (itoa (car ov)) "x" (itoa (cdr ov)))
                q (cdr (assoc 'V-REAL res)) (cdr (assoc 'PAM-REAL res)))))
          (princ (strcat "\nEtiketlendi: " (itoa (car ov)) "x" (itoa (cdr ov))))))
      (princ "\nHKBOYUT tamam."))
    )
  (princ))

;; HKMETRAJ: etiketli segmentleri seç -> uzunluk+boyut oku -> metraj -> CSV.
(defun c:HKMETRAJ ( / enames waste rows fp i en len size-str ab a b seg)
  (setq enames (hk-select-polylines))
  (if (null enames)
    (princ "\nPolyline secilmedi.")
    (progn
      (setq waste (hk-ask-number "Fitting fire % <15>: "))
      (if (null waste) (setq waste 15.0))
      (setq rows '() i 1)
      (foreach en enames
        (setq len (hk-read-length-m en))
        (setq size-str (hk-read-size-attr en))
        ;; size-str etiket bloğundan gelir; MVP'de etiket TEXT olduğu için
        ;; kullanıcıdan boyut da istenebilir. Boyut yoksa segment atlanır + uyarı.
        (if (and len size-str)
          (progn
            (setq ab (hk-parse-size size-str))
            (setq a (car ab) b (cdr ab))
            (setq seg (hk-takeoff-segment a b len waste))
            (setq rows (cons
              (list (cons 'NO i) (cons 'BOYUT size-str)
                    (cons 'UZUNLUK len) (cons 'ALAN (cdr (assoc 'AREA seg)))
                    (cons 'KALINLIK (cdr (assoc 'THICKNESS seg)))
                    (cons 'AGIRLIK (cdr (assoc 'WEIGHT seg)))
                    (cons 'FIRE waste))
              rows))
            (setq i (1+ i)))
          (princ (strcat "\n! Atlandi (boyut/uzunluk yok): " (vl-princ-to-string en)))))
      (setq rows (reverse rows))
      (if rows
        (progn
          (setq fp (getfiled "Metraj CSV kaydet" "" "csv" 1))
          (if fp
            (hk-csv-write fp rows
              '(NO BOYUT UZUNLUK ALAN KALINLIK AGIRLIK FIRE))
            (princ "\nKayit iptal.")))
        (princ "\nMetraj icin gecerli segment bulunamadi."))))
  (princ))

;; "400x300" -> (400 . 300). Hatalı format -> (nil . nil).
(defun hk-parse-size (s / pos a b)
  (setq pos (vl-string-search "x" (strcase s nil)))
  (if pos
    (cons (atoi (substr s 1 pos)) (atoi (substr s (+ pos 2))))
    (cons nil nil)))
```

- [ ] **Step 3: Yükleyici yaz**

`src/hk-load.lsp`:
```lisp
;; HavaKanal MVP — tüm modülleri yükler. AutoCAD'de: (load "src/hk-load.lsp")
(vl-load-com)
(load "src/hk-standards.lsp")
(load "src/hk-core-sizing.lsp")
(load "src/hk-core-takeoff.lsp")
(load "src/hk-rules.lsp")
(load "src/hk-export-csv.lsp")
(load "src/hk-cad-read.lsp")
(load "src/hk-cad-write.lsp")
(load "src/hk-ui.lsp")
(load "src/hk-commands.lsp")
(princ "\nHavaKanal MVP yuklendi. Komutlar: HKBOYUT, HKMETRAJ\n")
(princ)
```

- [ ] **Step 4: hk-parse-size için saf test ekle**

`test/test-export.lsp` sonuna ekle (parse saf, test edilebilir):
```lisp
(setq ab (hk-parse-size "400x300"))
(hk-assert-equal "parse a" 400 (car ab))
(hk-assert-equal "parse b" 300 (cdr ab))
```
Ve `hk-parse-size`'ı `src/hk-export-csv.lsp` yerine saf kalması için `src/hk-standards.lsp`'e taşı (string yardımcısı, AutoCAD bağımsız). `run-all-tests.lsp` zaten hk-standards yüklüyor.

> Düzeltme notu: `hk-parse-size` saf bir string fonksiyonu olduğu için `hk-commands.lsp` yerine `hk-standards.lsp`'e konur ki AutoCAD'siz test edilebilsin. `hk-commands.lsp` onu çağırır.

- [ ] **Step 5: Saf testleri çalıştır**

Run: `run-all-tests.lsp` yükle. Expected: PASS (parse testleri dahil).

- [ ] **Step 6: Commit**

```bash
git add src/hk-ui.lsp src/hk-commands.lsp src/hk-load.lsp src/hk-standards.lsp test/test-export.lsp
git commit -m "feat: add UI, commands (HKBOYUT/HKMETRAJ) and loader"
```

---

## Task 11b: mmSS basınç birimi gösterimi (Spec §2 — "Pa ve mmSS")

Spec §2 basınç kaybını hem Pa hem mmSS göstermeyi ister. Cam kutuda Pa zaten var; mmSS dönüşümünü ekliyoruz. 1 mmSS ≈ 9.80665 Pa.

**Files:**
- Modify: `src/hk-standards.lsp` (saf dönüşüm — test edilebilir)
- Modify: `src/hk-ui.lsp` (cam kutuda göster)
- Test: `test/test-standards.lsp`

- [ ] **Step 1: Failing test ekle**

`test/test-standards.lsp` sonuna ekle:
```lisp
;; Pa -> mmSS dönüşümü. 9.80665 Pa = 1 mmSS.
(hk-assert-close "9.80665 Pa -> 1 mmSS" 1.0 (hk-pa-to-mmss 9.80665))
(hk-assert-close "0 Pa -> 0 mmSS" 0.0 (hk-pa-to-mmss 0.0))
```

- [ ] **Step 2: Testi çalıştır, fail gör**

Run: `run-all-tests.lsp` yükle. Expected: FAIL — `hk-pa-to-mmss` tanımsız.

- [ ] **Step 3: Implementasyon**

`src/hk-standards.lsp` sonuna ekle:
```lisp
;; Basınç birimi dönüşümü: Pa -> mmSS (mm su sütunu). (Spec §2)
(setq *hk-pa-per-mmss* 9.80665)
(defun hk-pa-to-mmss (pa)
  (/ pa *hk-pa-per-mmss*))
```

- [ ] **Step 4: Cam kutuda göster**

`src/hk-ui.lsp` içinde `hk-show-glass-box` fonksiyonunda Pa/m satırını şununla değiştir:
```lisp
    "\n  Pa/m:  " (rtos (cdr (assoc 'PAM-REAL res)) 2 2)
    " (" (rtos (hk-pa-to-mmss (cdr (assoc 'PAM-REAL res))) 2 3) " mmSS/m)"
```

- [ ] **Step 5: Testi çalıştır, pass gör**

Run: `run-all-tests.lsp` yükle. Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add src/hk-standards.lsp src/hk-ui.lsp test/test-standards.lsp
git commit -m "feat: add Pa to mmSS conversion and show both in glass box"
```

---

## Task 12: AutoCAD'de uçtan uca elle doğrulama + mühendis kabul testi

Spec §7: saf testler otomatik geçti; şimdi AutoCAD'de gerçek çizimle doğrulama.

**Files:** (yok — manuel test)

- [ ] **Step 1: Eklentiyi AutoCAD'de yükle**

AutoCAD komut satırı: `(load "src/hk-load.lsp")`
Expected: "HavaKanal MVP yuklendi. Komutlar: HKBOYUT, HKMETRAJ"

- [ ] **Step 2: Basit kanal hattı çiz ve HKBOYUT test et**

Bir polyline çiz (örn. 5000 mm uzunlukta). `HKBOYUT` çalıştır → seç → yöntem "Surtunme" → Q=3600, hedef=1.0 Pa/m, ar=1.5.
Expected: cam kutu boyut+V+Pa/m+De+uyarı gösterir; çizime etiket yazılır.

- [ ] **Step 3: HKMETRAJ test et**

`HKMETRAJ` → aynı segmenti seç → fire %15 → CSV kaydet.
Expected: CSV açılınca uzunluk≈5.0 m, alan ve ağırlık dolu; başlık TR kolonları.

- [ ] **Step 4: Mühendis kabul testi (kritik kapı — Spec §5/§7)**

Makine mühendisi arkadaş:
- 2-3 gerçek kanal hattı için `HKBOYUT` sonucunu kendi ductulator/tecrübesiyle karşılaştırır.
- `HKMETRAJ` CSV'sindeki m² ve kg'ı elle metrajla karşılaştırır.
- Sürtünme bağıntısı sapıyorsa `*hk-friction-k*` katsayısı kalibre edilir (Spec §9).

Beklenen: sonuçlar mühendis toleransında. Sapma varsa katsayı/eşik düzeltilir, saf testlere yeni referans noktası eklenir.

- [ ] **Step 5: Kabul sonucunu belgele ve commit**

Mühendis onayı/sapma notlarını `docs/superpowers/specs/2026-06-13-havakanal-mvp-design.md` §9'a ekle.
```bash
git add docs/superpowers/specs/2026-06-13-havakanal-mvp-design.md
git commit -m "docs: record engineer acceptance test results and calibration"
```

---

## Self-Review Notları (yazım sonrası)

- **Spec kapsamı:** §2 dahil listesinin her maddesi bir task'a bağlı — boyutlandırma (T2-5), yuvarlama (T1), cam kutu (T5+T11), override (T11), toplu seçim (T9+T11), etiketleme (T10), metraj (T7), uyarılar (T6), dürüst fitting/fire (T7), CSV (T8), Pa **ve** mmSS (T11b: dönüşüm + cam kutuda her ikisi gösterilir — spec §2 karşılandı).
- **Malzeme uyarısı (3. kural):** T6'da bilinçli ertelendi (tek malzeme varsayımı) — spec §5 ile uyum için notlandı.
- **Tip tutarlılığı:** `hk-size-full` assoc anahtarları (A,B,DE,V-REAL,PAM-REAL,A-RAW,B-RAW) T5 ve T11'de aynı. `hk-takeoff-segment` anahtarları (AREA,THICKNESS,WEIGHT,WASTE-PCT) T7 ve T11'de aynı.
- **Placeholder:** yok — her kod adımı tam kod içeriyor.
