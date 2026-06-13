# MEP Eklenti Paketi

AutoCAD için **MEP (Mekanik–Elektrik–Tesisat)** eklenti paketi (AutoLISP).
Düz AutoCAD'de çizen mühendislerin tekrarlayan işini (boyutlandırma, hesap, metraj, Excel raporu) otomatikleştirir — pahalı MagiCAD/AutoCAD MEP gerekmez.

> Durum: MVP. 5 modülün tamamı çalışıyor. Hesap formülleri **mühendis kabul testi** bekliyor (bkz. [Doğrulama](#doğrulama)).

## Modüller ve Komutlar

| Modül | Komutlar | Ne yapar |
|-------|----------|----------|
| **Havalandırma** | `HKBOYUT`, `HKMETRAJ` | Hava kanalı boyutlandırma (eşit sürtünme/sabit hız) + metraj (m²/kg) |
| **Su tesisatı** | `SUCAP`, `SUMETRAJ` | Temiz/pis su boru çapı (debi veya yük birimi) + boru metrajı |
| **Yangın** | `YSPRINKLER`, `YBORUCAP`, `YMETRAJ` | Sprinkler grid yerleşimi + boru çapı (pipe schedule) + metraj |
| **Elektrik** | `ELKGUC`, `ELKKABLO`, `ELKMETRAJ` | Güç/akım/kablo kesiti + sigorta + aydınlatma + metraj |
| **Isı kaybı** | `ISIKAYBI` | Mahal ısı kaybı (TS 825) + radyatör boyutlandırma |

## Kurulum (AutoCAD)

1. Depoyu indirin (**Code → Download ZIP** veya `git clone`).
2. Bir klasöre açın (örn. `C:\MEP\`).
3. AutoCAD komut satırına (yolu kendinize göre düzeltin):
   ```
   (load "C:/MEP/src/mep-load.lsp")
   ```
   > Windows yollarında `\` yerine `/` kullanın.
4. `=== MEP Paketi yuklendi. ===` görünce **tüm modüllerin** komutları hazırdır.

**Tek modül** yüklemek isterseniz (örn. sadece yangın):
```
(load "C:/MEP/src/modules/yangin/yng-load.lsp")
```
Modül çekirdeği (core) otomatik bulur.

**Her açılışta otomatik:** `APPLOAD` → **Startup Suite** → `src/mep-load.lsp`.

## Modül Kullanımı

### Havalandırma — `HKBOYUT` / `HKMETRAJ`
- `HKBOYUT`: kanal polyline'ı seç → yöntem (Surtunme/Hiz) + uygulama (Ofis/Konut/Endustri) + debi + hedef → cam kutu (boyut, V, Pa/m, mmSS, De, uyarılar) → Kabul/Degistir → çizime etiketler.
- `HKMETRAJ`: polyline seç → fire % + her segmentin boyutu → yüzey alanı (m²) + ağırlık (kg) → CSV.

### Su tesisatı — `SUCAP` / `SUMETRAJ`
- `SUCAP`: Debi (L/s) **veya** yük birimi (YB) ile temiz su boru çapı (DN) önerir. Q=V·A + TS EN 806 yük birimi cetveli.
- `SUMETRAJ`: polyline seç → sistem (Temiz/Pis) + malzeme + çap → uzunluk + fitting payı → CSV.

### Yangın — `YSPRINKLER` / `YBORUCAP` / `YMETRAJ`
- `YSPRINKLER`: iki köşe ile dikdörtgen alan + tehlike sınıfı (LH/OH) → otomatik **grid sprinkler yerleşimi** (BYKHY/EN 12845 max aralık) + sprinkler debisi.
- `YBORUCAP`: borunun beslediği sprinkler sayısı → boru DN (pipe schedule). Tablo dışıysa "hidrolik hesap gerekli" uyarısı.
- `YMETRAJ`: boru polyline + sprinkler adedi → CSV.

### Elektrik — `ELKGUC` / `ELKKABLO` / `ELKMETRAJ`
- `ELKGUC`: kurulu güç + tesis tipi → eş zamanlılık ile talep gücü + akım.
- `ELKKABLO`: yük gücü + faz + uzunluk + devre tipi → akım, sigorta, **kablo kesiti** (gerilim düşümü kontrolü dahil — gerekirse kesiti büyütür).
- `ELKMETRAJ`: kablo polyline (kesit bazında) + priz/anahtar/armatür/buat adedi → CSV.

### Isı kaybı — `ISIKAYBI`
- Bölge (TS 825, 1–6) + il + mahal + alan/duvar/pencere/çatı/döşeme alanları → iletim + havalandırma kaybı (W) → toplam + **panel radyatör boyu**. U değerleri TS 825:2024'ten, iç/dış sıcaklıklar tablodan.

## Mimari

```
src/
  core/                  Tüm modüllerin paylaştığı domain-bağımsız araçlar
    mep-units.lsp        birim dönüşümü (Pa<->mmSS)
    mep-csv.lsp          CSV yazma (UTF-8 BOM, TR Excel uyumlu)
    mep-ui.lsp           genel kullanıcı sorgusu
    mep-cad.lsp          genel CAD I/O (uzunluk, seçim, metin)   [AutoCAD]
    mep-core-load.lsp    core yükleyici
  modules/
    havalandirma/  (hva-*)   TS EN 1505, eşit sürtünme/sabit hız
    su/            (su-*)    TS EN 806/12056, yük birimi/DU
    yangin/        (yng-*)   BYKHY/EN 12845, pipe schedule, grid
    elektrik/      (elk-*)   EİTY/IEC 60364, kesit/sigorta
    isi/           (isi-*)   TS 825:2024, ısı kaybı/radyatör
  mep-load.lsp         ANA yükleyici (core + tüm modüller)
test/                  Saf çekirdek testleri (her modül)
docs/superpowers/      Tasarım (spec) ve uygulama planları
```

Her modül: kendi standart tablosu + hesap çekirdeği + komutları + yükleyicisi. Core'u (CSV/UI/birim/CAD) paylaşır. Yeni modül = yeni klasör + `<önek>-load.lsp` + `mep-load.lsp`'ye bir satır.

## Doğrulama

Saf çekirdek (tüm modüllerin hesapları) AutoCAD'siz test edilebilir:
```
(load "test/run-all-tests.lsp")
```
Sonuç: `=== SONUC: N PASS, 0 FAIL ===`

> ⚠️ **Mühendis kabul testi gerekli — ÖNEMLİ:** Tüm modüllerin hesap tabloları ve katsayıları kaynaklı ama **yaklaşık/varsayılan** değerlerdir; gerçek proje sonuçlarıyla karşılaştırılıp kalibre edilmelidir:
> - **Havalandırma:** sürtünme katsayısı `*hva-friction-k*`
> - **Su:** tasarım hızı `*su-temiz-hiz*`, yük birimi cetvelleri
> - **Yangın:** pipe-schedule tablosu (EN 12845 LH/OH çizelgesiyle teyit)
> - **Elektrik:** kablo akım tablosu (döşeme koşuluna göre değişir), `*elk-kes*`, cosφ
> - **Isı:** TS 825 U değerleri, il dış sıcaklıkları, radyatör katalog ΔT (50K/60K!)
>
> Her modülde bu değerler **assoc-list / named constant** olarak tek yerde — mühendis kolayca düzeltir.

## Önemli notlar (domain)

- **TS 826 iptal:** Su modülü TS EN 806/12056 esaslı; YB/DU geleneği pratik için korundu.
- **Yangın MVP:** Sadece LH+OH, pipe-schedule (hidrolik hesap değil), dikdörtgen grid. HH ve hidrolik hesap v2.
- **Isı infiltrasyon:** `n` = sızma (0.5–2.0), mekanik havalandırma debisi (6–30) DEĞİL — karıştırılmamalı.
- **CSV:** UTF-8 BOM + noktalı virgül → Türkçe karakter Excel'de bozulmaz.

## Yol Haritası

- Her modülde fitting/detay hesapları, yuvarlak kanal, hidrolik hesap, lümen yöntemi
- Çizimden otomatik okuma (alan, blok sayımı) — şu an bazı girdiler elle
- .xlsx çıktı (COM), lisanslama, AutoCAD menü/ribbon

## Lisans

Henüz belirlenmedi (ticarileşme aşamasında eklenecek).
