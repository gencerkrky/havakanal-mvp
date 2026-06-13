# MEP Eklenti Paketi Mimarisi — Tasarım Dokümanı (Spec)

> Tarih: 13 Haziran 2026
> Durum: Tasarım onaylandı (kullanıcı tam yetki verdi)
> Konu: Tek-modüllü HavaKanal eklentisini, MTYCAD tarzı çok-modüllü bir MEP paketine dönüştürmek (iskelet)

---

## 1. Amaç

Mevcut tek modüllü `hk-` (HavaKanal) eklentisini, birden çok mühendislik disiplinini (havalandırma, su, elektrik, yangın, ısı) barındırabilen modüler bir pakete dönüştürmek. Bu spec **yalnızca iskeleti** kurar: ortak çekirdek ayrımı + çok-modüllü yükleyici + mevcut havalandırma modülünün yeni yapıya taşınması. Yeni domain (su/elektrik/...) eklenmez — onlar ayrı spec/plan ile gelecek.

**Kısıt:** Mevcut çalışan kod bozulmayacak. Komut adları (`HKBOYUT`, `HKMETRAJ`) korunacak (test eden mühendis akışını kırmamak için).

## 2. Tasarım İlkeleri

- **Ortak çekirdek (core):** Domain-bağımsız araçlar (CSV, kullanıcı sorgusu, birim dönüşümü, genel CAD I/O) tek yerde; tüm modüller paylaşır (DRY).
- **Modül bağımsızlığı:** Her disiplin kendi klasöründe, kendi öneki ve kendi yükleyicisiyle. Tek başına yüklenebilir; core yüklü değilse kendi core'unu çeker.
- **Tek yükleyici, seçmeli yükleme:** `mep-load.lsp` hepsini getirir (basit kurulum); ama tek modül de ayrı yüklenebilir.
- **Önek şeması:** Paket geneli `mep-`, modüller `hva-` (havalandırma), `su-`, `elk-`, `yng-`, `isi-`.

## 3. Dosya Yapısı

```
src/
  core/
    mep-units.lsp        ; birim dönüşümleri (Pa<->mmSS; gelecek birimler)
    mep-csv.lsp          ; CSV yazma (domain-bağımsız)
    mep-ui.lsp           ; genel kullanıcı sorgusu (sayı, kelime, evet/hayır)
    mep-cad.lsp          ; genel CAD I/O (polyline uzunluğu, seçim, metin yazma)
    mep-core-load.lsp    ; core modüllerini yükler + *mep-core-loaded* bayrağı
  modules/
    havalandirma/
      hva-standards.lsp  ; TS EN 1505 kademe, sac kalınlığı, boyut parse (havalandırmaya özel)
      hva-sizing.lsp     ; boyutlandırma (alan, eşdeğer çap, sabit hız, eşit sürtünme)
      hva-takeoff.lsp    ; metraj (yüzey alanı, ağırlık, fire %)
      hva-rules.lsp      ; uyarı kuralları
      hva-commands.lsp   ; HKBOYUT, HKMETRAJ
      hva-load.lsp       ; core'u sağlar + havalandırma dosyalarını yükler
  mep-load.lsp           ; ANA yükleyici: core + tüm mevcut modüller
test/
  core/
    test-units.lsp
    test-csv.lsp
  havalandirma/
    test-standards.lsp
    test-sizing.lsp
    test-takeoff.lsp
    test-rules.lsp
  hk-test-framework.lsp
  run-all-tests.lsp
```

## 4. Fonksiyon Eşlemesi (eski -> yeni)

Gövdeler aynı kalır; sadece dosya konumu ve önek değişir. Çekirdek araçlar `mep-`, havalandırma `hva-`.

| Eski (hk-) | Yeni | Dosya |
|-----------|------|-------|
| hk-csv-* | mep-csv-* | core/mep-csv.lsp |
| hk-ask-number, hk-ask-method?, hk-ask-apptype? | mep-ask-number (genel); hva-ask-method/apptype (modüle özel) | core/mep-ui.lsp + hva-commands |
| hk-pa-to-mmss | mep-pa-to-mmss | core/mep-units.lsp |
| hk-read-length-m, hk-select-polylines, hk-write-label, hk-polyline-midpoint | mep-read-length-m, mep-select-polylines, mep-write-text, mep-polyline-midpoint | core/mep-cad.lsp |
| hk-round-up-standard, hk-sheet-thickness, hk-parse-size | hva-round-up-standard, hva-sheet-thickness, hva-parse-size | modules/havalandirma/hva-standards.lsp |
| hk-q-to-m3s ... hk-size-full | hva-q-to-m3s ... hva-size-full | hva-sizing.lsp |
| hk-surface-area ... hk-takeoff-segment | hva-surface-area ... hva-takeoff-segment | hva-takeoff.lsp |
| hk-warn-* , hk-collect-warnings | hva-warn-*, hva-collect-warnings | hva-rules.lsp |
| c:HKBOYUT, c:HKMETRAJ | c:HKBOYUT, c:HKMETRAJ (DEĞİŞMEZ) | hva-commands.lsp |

> Karar: `hk-parse-size` ve standartlar core'a değil **havalandırma modülüne** taşınır — TS EN 1505 kademeleri ve sac kalınlığı havalandırmaya özeldir (su borusu çapı/elektrik kablo kesiti farklı standartlardır). `mep-write-label` genel metin yazma olur (`mep-write-text`), havalandırma etiketinin biçimini modül kurar.

## 5. Yükleyici Sistemi

### 5.1 Core yükleyici (mep-core-load.lsp)
```lisp
(vl-load-com)
(setq *mep-core-dir* (vl-filename-directory (findfile "mep-core-load.lsp")))
(defun mep-core-load-file (n) (load (strcat *mep-core-dir* "/" n)))
(mep-core-load-file "mep-units.lsp")
(mep-core-load-file "mep-csv.lsp")
(mep-core-load-file "mep-ui.lsp")
(mep-core-load-file "mep-cad.lsp")
(setq *mep-core-loaded* T)   ; modüller bunu kontrol eder
```

### 5.2 Modül yükleyici (hva-load.lsp) — core'u garanti eder
```lisp
;; Core yüklü değilse yükle (modül tek başına çalışabilsin).
(if (not (and (boundp '*mep-core-loaded*) *mep-core-loaded*))
  (load (findfile "mep-core-load.lsp")))
(setq *hva-dir* (vl-filename-directory (findfile "hva-load.lsp")))
(defun hva-load-file (n) (load (strcat *hva-dir* "/" n)))
(hva-load-file "hva-standards.lsp")
(hva-load-file "hva-sizing.lsp")
(hva-load-file "hva-takeoff.lsp")
(hva-load-file "hva-rules.lsp")
(hva-load-file "hva-commands.lsp")
(princ "\nHavalandirma modulu yuklendi. Komutlar: HKBOYUT, HKMETRAJ")
```

### 5.3 Ana yükleyici (mep-load.lsp) — hepsini getirir
```lisp
(setq *mep-dir* (vl-filename-directory (findfile "mep-load.lsp")))
(load (strcat *mep-dir* "/core/mep-core-load.lsp"))
(load (strcat *mep-dir* "/modules/havalandirma/hva-load.lsp"))
;; gelecek: su, elektrik, yangin, isi modulleri buraya eklenir
(princ "\nMEP Paketi yuklendi.")
```

**Yol çözümü:** `findfile` AutoCAD'in destek yollarında arar; modül klasörleri AutoCAD support path'ine eklenmeli VEYA `mep-load.lsp` mutlak yolla yüklenir (README'de belirtilir). Güvence için ana yükleyici `*mep-dir*`'i baz alıp alt klasörleri mutlak yolla yükler — böylece `findfile`'a sadece giriş dosyası için bağımlılık kalır.

## 6. Migration Stratejisi (mevcut kodu bozmadan)

1. `core/` ve `modules/havalandirma/` klasörlerini oluştur.
2. Genel araçları (csv, ui-genel, units, cad) `core/`'a taşı, `mep-` öneki ver.
3. Havalandırmaya özel dosyaları `modules/havalandirma/`'ya taşı, `hva-` öneki ver.
4. Fonksiyon çağrılarını yeni adlara güncelle (gövdeler aynı).
5. Yükleyicileri yaz (5. bölüm).
6. Eski `src/hk-*.lsp` ve `src/hk-load.lsp` dosyalarını sil (artık taşındı).
7. Testleri yeni adlara/klasörlere taşı.
8. README'yi yeni yükleme yoluna göre güncelle.

## 7. Test Stratejisi

- Saf çekirdek (mep-units, mep-csv) + havalandırma saf hesabı (sizing, takeoff, rules, standards) testleri korunur, yeni adlarla.
- `run-all-tests.lsp` core + havalandırma saf testlerini yükler.
- Parantez/söz dizimi kontrolü (Python script) tüm yeni dosyalara koşulur.
- Formül doğruluğu Python-ayna ile teyit (havalandırma değerleri değişmedi → aynı referanslar geçer).
- CAD katmanı (mep-cad, hva-commands) AutoCAD'de elle doğrulanır.

## 8. Kapsam Dışı (sonraki spec'ler)

- Su / elektrik / yangın / ısı modüllerinin domain araştırması, formülleri, hesapları (her biri ayrı spec/plan).
- Lisanslama / modül-bazlı kilit.
- AutoCAD menü/ribbon (CUIX).
- Komut adlarının yeniden adlandırılması (HKBOYUT korunur; modüller eklendikçe tutarlı adlandırma v2'de değerlendirilir).

## 9. Riskler

- **findfile yol bağımlılığı:** AutoCAD support path'i ayarlı değilse `findfile` modül dosyalarını bulamaz. Azaltma: ana yükleyici mutlak yol türetir; README net kurulum verir.
- **Tek başına modül yükleme:** `hva-load.lsp` core'u `findfile` ile arar; bulamazsa hata. Azaltma: README'de "tek modül yüklerken core klasörü support path'te olmalı" notu, veya tam yol.
- **Regresyon:** Yeniden adlandırma sırasında bir çağrı kaçarsa kırılır. Azaltma: parantez + python-ayna + (mümkünse) AutoCAD'de HKBOYUT/HKMETRAJ smoke testi.
