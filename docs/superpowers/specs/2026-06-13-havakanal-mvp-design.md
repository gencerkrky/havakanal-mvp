# HavaKanal MVP — Tasarım Dokümanı (Spec)

> Tarih: 13 Haziran 2026
> Durum: Tasarım onayı bekliyor
> Ürün: AutoCAD AutoLISP eklentisi — havalandırma (hava kanalı) hesabı + metrajı
> Bu spec, `autolisp-cad-eklenti-pazari-arastirma.md` pazar araştırmasının ilk somut ürününü tanımlar.

---

## 1. Amaç ve Değer Önerisi

Düz AutoCAD'de (MagiCAD / AutoCAD MEP gibi pahalı araçlar **olmadan**) tek çizgi polyline + blok ile çizen Türk makine mühendisinin **hava kanalı boyutlandırma + metraj** işini otomatikleştirmek.

**Değer önerisi:** Mühendisin elle ductulator + elle Excel metrajı ile saatler harcadığı işi, çizim üzerinden tek komutla yapmak. Araştırma net gösterdi: en büyük değer "hesap doğruluğu" değil (ductulator zaten yapıyor) — **çizimle entegrasyon (toplu boyutlandırma + otomatik etiketleme) ve güvenilir, tek-tık metraj**.

**Tasarım felsefesi — "cam kutu":** Mühendisler otomatik hesabı körü körüne kabul etmez; bir "sağlama aracı" olarak kullanır. Bu yüzden tüm ara değerler (hız V, sürtünme Pa/m, eşdeğer çap De, en-boy oranı) her zaman görünür ve mühendis sonucu override edebilir. Kara kutu = güvensizlik = satılmaz.

---

## 2. Kapsam (MVP)

### 2.1 Dahil

| Özellik | Açıklama |
|---------|----------|
| Düz dikdörtgen kanal segmenti | Tek çizgi (polyline) olarak çizilmiş düz kanal |
| Boyutlandırma yöntemi | Eşit sürtünme (equal friction) **veya** sabit hız (constant velocity) — mühendis seçer |
| Standart boyuta yuvarlama | Ham hesap → TS EN 1505 (dikdörtgen) bir üst standart kademeye |
| Cam kutu gösterimi | V (m/s), Pa/m, eşdeğer çap De, en-boy oranı her zaman görünür |
| Override + kilit | Önerilen boyut düzenlenebilir; bir kenarı sabitleyip diğerini hesaplat (tavan/şaft kısıtı) |
| Toplu segment seçimi | Birden çok polyline seç → tek komutla boyutlandır |
| Otomatik etiketleme | Hesaplanan boyut (örn. `400x300`) çizime attribute'lu blok olarak yazılır |
| Metraj | Uzunluk (m) + yüzey alanı (m²) + sac kalınlığı + ağırlık (kg) → CSV |
| Uyarı motoru (3 kural) | (a) en-boy oranı > 4:1, (b) hız uygulama tipi eşiğini aşıyor, (c) malzeme/pürüzlülük yöntemle uyumsuz |
| Fitting'i dürüst ele alma | MVP fitting hesabı yapmaz; metrajda ya kullanıcı-ayarlı fire % eklenir ya da "fitting hariç" açıkça not düşülür (sessizce atlamaz) |
| Çıktı formatı | CSV (Excel'de açılır), çapraz platform |
| Birim desteği | Basınç kaybı hem Pa hem mmSS gösterimi |

### 2.2 Hariç (v2 ve sonrası — "tab tab ekle")

- Dirsek / T / redüksiyon fitting **hesabı** ve lokal kayıp katsayıları
- Statik geri kazanım, hız azaltma yöntemleri
- Bağlı ağ (network) otomatik takibi + tüm-hat toplam basınç kaybı
- Yuvarlak/spiral kanal boyutlandırma (sadece dikdörtgen MVP'de)
- Detaylı akustik (dB(A)) hesabı
- Gerçek .xlsx çıktı (COM, yalnızca Windows)
- Lisanslama / lisans anahtarı (ticarileşme aşaması — .NET ile)

### 2.3 Kapsam dışı bırakma gerekçesi

Fitting hesabı ve tüm-ağ basınç toplama, en yüksek domain-bilgisi riski taşıyan kısım. Geliştirici (ben/sen) sektörü bilmiyor; test eden mühendis arkadaş **sadece test edecek**, formül kaynağı vermeyecek. Bu yüzden önce **düz segment zincirini** doğru kurup mühendise doğrulattıktan sonra büyütmek en düşük riskli yol (ince dikey dilim).

---

## 3. Mimari (AutoLISP, modüler)

### 3.1 Genel ilke

AutoLISP ile yazılır (pazar araştırmasındaki "önce AutoLISP, sonra .NET" kararı). Kod **tek dev dosya değil**, sorumluluğa göre ayrılmış küçük `.lsp` dosyalarına bölünür. Her dosya tek iş yapar, saf hesap fonksiyonları AutoCAD'den bağımsız test edilebilir.

### 3.2 Katmanlar / dosyalar

```
src/
  hk-core-sizing.lsp     ; SAF hesap: debi+yöntem → ham boyut, V, Pa/m, De. AutoCAD bağımsız.
  hk-core-takeoff.lsp    ; SAF hesap: boyut+uzunluk → alan, ağırlık. AutoCAD bağımsız.
  hk-standards.lsp       ; TS EN 1505 standart kademe listesi + yuvarlama + sac kalınlığı tablosu
  hk-rules.lsp           ; SAF: 3 uyarı kuralı (aspect>4:1, hız eşiği, malzeme uyumu)
  hk-cad-read.lsp        ; AutoCAD I/O: polyline uzunluğu (vlax-curve), seçim (ssget), attribute okuma
  hk-cad-write.lsp       ; AutoCAD I/O: boyut etiketini blok olarak çizime yazma
  hk-export-csv.lsp      ; CSV yazma (open/write-line/close) + hata yönetimi
  hk-ui.lsp              ; Diyalog/komut satırı etkileşimi (cam kutu gösterimi, override)
  hk-commands.lsp        ; Komut tanımları (defun c:HKBOYUT, c:HKMETRAJ) — katmanları birbirine bağlar
test/
  test-sizing.lsp        ; hk-core-sizing saf fonksiyon testleri
  test-takeoff.lsp       ; hk-core-takeoff saf fonksiyon testleri
  test-standards.lsp     ; yuvarlama + kalınlık tablosu testleri
  test-rules.lsp         ; uyarı kuralı testleri
```

**Neden bu ayrım:** Saf hesap çekirdeği (`hk-core-*`, `hk-standards`, `hk-rules`) AutoCAD olmadan, doğrudan komut satırında test edilebilir. Mühendis arkadaşın doğrulaması da en çok bu çekirdeğe odaklanır. AutoCAD I/O katmanı (`hk-cad-*`) ince tutulur.

### 3.3 İki ana komut

| Komut | İş akışı |
|-------|----------|
| `HKBOYUT` (boyutlandır) | Segment(ler) seç → debi + yöntem + en-boy oranı gir → hesapla → cam kutu göster → override/onayla → çizime etiketle |
| `HKMETRAJ` (metraj çıkar) | Etiketlenmiş segmentleri seç → uzunluk+boyut oku → alan+ağırlık hesapla → fire % sor → CSV'ye yaz |

Zincir akış: önce `HKBOYUT` ile boyutlar çizime yazılır, sonra `HKMETRAJ` aynı veriyi okuyup metraj üretir. (Kullanıcı isterse boyutlar zaten çizimdeyse doğrudan `HKMETRAJ` da çalıştırabilir.)

---

## 4. Veri Akışı

### 4.1 Boyutlandırma (HKBOYUT)

```
[Mühendis] polyline(ler) seçer
   │
   ▼
[hk-cad-read] her segmentin uzunluğunu okur (vlax-curve-getDistAtParam)
   │
   ▼
[Mühendis] girer: debi Q (m³/h), yöntem (eşit sürtünme Pa/m | sabit hız m/s),
            en-boy oranı veya sabit kenar
   │
   ▼
[hk-core-sizing] ham dikdörtgen boyut (a×b) + V + Pa/m + De hesaplar
   │   eşit sürtünme: hedef Pa/m'den A bulunur → en-boy oranıyla a,b
   │   sabit hız:     A = Q/V → en-boy oranıyla a,b
   │   eşdeğer çap:   De = 1,30·(a·b)^0,625 / (a+b)^0,250  (Huebscher)
   ▼
[hk-standards] a,b'yi TS EN 1505 bir üst kademeye yuvarlar
   │   yuvarlama SONRASI gerçek V, Pa/m yeniden hesaplanır
   ▼
[hk-rules] 3 uyarıyı değerlendirir (sarı bayrak, engelleyici değil)
   │
   ▼
[hk-ui] CAM KUTU: yuvarlanmış boyut + gerçek V + Pa/m + De + en-boy oranı + uyarılar gösterir
   │
   ▼
[Mühendis] onaylar VEYA override eder (boyutu elle değiştir / kenar kilitle → yeniden hesapla)
   │
   ▼
[hk-cad-write] onaylanan boyutu segmente attribute'lu blok etiketi olarak yazar
```

### 4.2 Metraj (HKMETRAJ)

```
[Mühendis] etiketli segmentleri seçer
   │
   ▼
[hk-cad-read] her segment: uzunluk (geometriden) + boyut (attribute'tan) okur
   │
   ▼
[hk-core-takeoff] yüzey alanı A = 2·(a+b)·L ; ağırlık = A · kalınlık_mm · 7,85
   │   sac kalınlığı en geniş kenara göre tablodan seçilir (hk-standards)
   ▼
[Mühendis] fitting fire yüzdesi girer (varsayılan örn. %15) VEYA "fitting hariç" seçer
   │   fire %, yüzey alanına (m²) uygulanır → ağırlık (kg) bundan türediği için ikisi de artar
   ▼
[hk-export-csv] satır başına: parça no, sistem, boyut, uzunluk, alan, kalınlık, ağırlık, debi, V, Pa/m
   │   + toplam satırı; fire % uygulanmışsa hangi orandan olduğu açıkça ayrı kolonda gösterilir
   ▼
[CSV dosyası] kullanıcının seçtiği yola yazılır
```

### 4.3 Veri modeli — boyut çizimde nasıl tutulur

**Karar: attribute'lu blok etiketi.** Her kanal segmentine, boyut bilgisini attribute olarak taşıyan küçük bir blok (`HK_LABEL`) yerleştirilir. Attribute'lar: `BOYUT` (örn. `400x300`), `DEBI`, `HIZ`, `PAM`.

**Neden layer-adı parse değil:** Layer adından boyut okumak kırılgan — mühendis layer adını farklı yazınca (büyük/küçük harf, ayraç) parse patlar. Attribute'lu blok hem insan-okunur hem makine-okunur, hatasız ve standart AutoLISP ile güvenle okunur (`vla-GetAttributes`).

---

## 5. Hesap Formülleri (kaynaklı — mühendis onayı gerekli)

> ⚠️ Bu formüller araştırmadan derlendi. **Kodlama öncesi makine mühendisi arkadaşın bir kez onaylamalı** — özellikle tasarım hızı eşikleri ve hedef Pa/m değerleri. 1 saatlik teyit, haftalarca yanlış yön önler.

| Büyüklük | Formül / değer |
|----------|----------------|
| Debi-hız-alan | `Q = V · A` → `A = Q/V` (Q[m³/s] = Q[m³/h]/3600) |
| Eşdeğer çap (Huebscher) | `De = 1,30 · (a·b)^0,625 / (a+b)^0,250` |
| Yüzey alanı (dikdörtgen) | `A_yüzey = 2 · (a+b) · L` |
| Ağırlık | `kg = A_yüzey(m²) · kalınlık(mm) · 7,85` |
| Hedef sürtünme (eşit sürtünme) | tipik 0,8–1,2 Pa/m; varsayılan 1,0 Pa/m (ayarlanabilir) |
| Standart kademeler (TS EN 1505) | 100,150,200,250,300,400,500,600,800,1000,1200 mm |

**Tasarım hızı eşikleri (uyarı için, m/s) — ofis varsayılanı:**
ana kanal 6,0–7,6 · branşman 4,6–6,0 · uç ~3,5. (Uygulama tipi seçilebilir: konut/ofis/endüstriyel.)

**Sac kalınlığı (kanal en geniş kenarına göre, SMACNA/DW144 mantığı — mühendis teyidi gerekli):**
≤600 mm → 0,60 mm · 600–1000 mm → 0,80 mm · >1000 mm → 1,00 mm (tablo `hk-standards`'ta, kolayca düzeltilebilir).

**Sürtünme/basınç kaybı:** Eşit sürtünme yönteminde Pa/m, standart hava (ρ≈1,2 kg/m³) ve galvaniz sac pürüzlülüğü için Darcy–Colebrook'tan türetilmiş ductulator bağıntısıyla hesaplanır. MVP'de yardımcı tablo/yaklaşık bağıntı kullanılır; kesin nomogram uyumu mühendis testiyle kalibre edilir.

---

## 6. Hata Yönetimi

| Durum | Davranış |
|-------|----------|
| Seçilen nesne polyline değil | Atla + komut satırında uyar; geçerli olanlarla devam |
| Polyline uzunluğu 0 / dejenere | O segmenti atla, raporda işaretle |
| Debi/girdi geçersiz (≤0, sayı değil) | Tekrar sor; iptal edilebilir |
| Etiket bloğu yok (metrajda) | O segment için "boyut bulunamadı" uyarısı; toplam dışı bırak |
| CSV dosyası açılamıyor (yol/yetki) | `open` dönüşü nil kontrolü → kullanıcıya net hata, çökme yok |
| COM/dosya I/O istisnası | `vl-catch-all-apply` ile sarmalanır; sessiz yutma yok |

**İlke (global kalite kuralı):** Hiçbir hata sessizce yutulmaz. Her dosya/CAD işlemi hata yönetimine sahip. Atlanan her segment kullanıcıya bildirilir — sessiz eksik metraj, "her şey sayıldı" yanılgısı yaratır.

---

## 7. Test Stratejisi

**Saf çekirdek (AutoCAD'siz, en kritik):**
- `test-sizing`: bilinen debi+yöntem girdisi → beklenen boyut/V/Pa/m/De (mühendisin elle ductulator sonucuyla karşılaştırılır)
- `test-takeoff`: bilinen boyut+uzunluk → beklenen alan+ağırlık (elle hesapla doğrulanır)
- `test-standards`: ham boyut → doğru üst kademeye yuvarlanıyor mu; sınır değerler (tam kademe, kademe altı/üstü)
- `test-rules`: aspect 4:1 sınırı, hız eşiği, malzeme uyumu — her kural ayrı

**Kabul testi (mühendis arkadaş):**
- Gerçek bir kanal hattı çizimi → `HKBOYUT` → çıkan boyutları kendi ductulator/tecrübesiyle karşılaştırır
- `HKMETRAJ` → CSV'deki m² ve kg'ı elle metrajla karşılaştırır
- Her hesap formülü, kodlanmadan önce mühendise gösterilip onaylanır (bkz. §5 uyarısı)

**Test verisi:** Mühendis arkadaştan 2-3 gerçek (basit) kanal hattı örneği + beklenen sonuçları alınır; regresyon referansı olur.

---

## 8. Dağıtım (özet — ayrıntı pazar araştırmasında)

MVP doğrulandıktan sonra: kendi sitesi + lisans anahtarı (.NET katmanı) ana kanal; Autodesk App Store ücretsiz vitrin. Ödeme TR için iyzico/PayTR (yerel), yurtdışı için Lemon Squeezy. Lisanslama MVP kapsamı dışında (v2).

---

## 9. Açık Riskler

- **AutoCAD sürüm uyumu:** Her yıl yeni sürüm → bakım yükü. AutoLISP görece stabil, riski düşürür.
- **Pürüzlülük/Pa-m kalibrasyonu:** Ductulator nomogramına birebir uymak yaklaşım gerektirir; mühendis testiyle kalibre edilmeli.
- **Mac vs Windows:** CSV çapraz platform; xlsx (COM) sadece Windows — bu yüzden MVP CSV. Test eden mühendisin platformu doğrulanmalı.
- **Domain doğruluğu:** Geliştirici sektörü bilmiyor → §5 formül onayı kritik yol.
