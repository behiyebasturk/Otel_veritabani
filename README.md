# Otel_veritabani

# Otel Rezervasyon ve Konaklama Yönetim Sistemi

Veritabanı Yönetim Sistemleri dersi (2026-2027) dönem projesi.

Sistem; bir otelin oda, oda tipi, sezon fiyatı, misafir, rezervasyon, konaklama, ek hizmet, ödeme, temizlik ve personel süreçlerini yönetir. En kritik iş kuralı olan **aynı odanın çakışan tarihlerde iki kez rezerve edilememesi** veritabanı seviyesinde (TRIGGER) uygulanır.

## Grup Üyeleri

| Ad Soyad | Öğrenci No |
|----------|------------|
| Behiye Basturk |455129 |
| Hayrunnisa Sancar | 455137 |

## Teknoloji Seçimi

| Katman | Seçim |
|--------|-------|
| Veritabanı | **MySQL 8.0** |
| Backend |Spring Boot |
| Frontend | HTML, CSS, JavaScript |
| Kimlik doğrulama | JWT, rol bazlı yetkilendirme (misafir, resepsiyon, yönetici) |
| API testi | Postman veya Swagger |

## Depo Yapısı

```
.
├── README.md
├── docs/
│   └── er-diagram.md        # ER diyagramı (Mermaid) ve normalizasyon notları
├── database/
│   ├── otel_db.sql          # Tablolar, trigger, prosedür, view, transaction, indeks, örnek veri
│   └── test_senaryolari.sql # Çakışma, check-in/out, ROLLBACK, rapor ve indeks performans testleri
├── backend/                 # REST API (katmanlı mimari: Entity, Repository, Service, Controller)
├── frontend/                # Misafir, resepsiyon ve yönetici ekranları
└── postman/                 # API koleksiyonu
```

## Veritabanı Kurulumu

MySQL 8.0 veya üzeri gerekir.

```bash
mysql -u root -p < database/otel_db.sql
```

Betik `otel_db` adlı veritabanını oluşturur (varsa siler); tabloları, tetikleyicileri, saklı prosedürleri, görünümleri ve örnek veriyi (20 oda, 50 misafir, 200 rezervasyon) yükler. Sonunda her tablodaki satır sayısını listeler.

Örnek verinin tarihleri `CURDATE()`'e göre göreli üretilir; betiği hangi gün çalıştırırsanız çalıştırın "bugün giriş/çıkış" görünümünde kayıt görürsünüz. Sezon fiyatları 2026-2028 için tanımlıdır.

Testler ve video senaryoları için:

```bash
mysql -u root -p < database/test_senaryolari.sql --force
```

`--force`, bilinçli olarak hata üreten satırlardan (çakışma, ROLLBACK) sonra devam eder. Videoda satırları MySQL Workbench veya terminalde tek tek çalıştırmak daha anlaşılırdır.

**Örnek kullanıcılar:** `yonetici`, `resepsiyon1`, `resepsiyon2`, `resepsiyon3` ve ilk 10 misafirin e-postası. `Kullanici.sifre_hash` alanı yer tutucudur; backend seçildikten sonra seçilen algoritmayla (ör. bcrypt) üretilen hash'lerle güncellenmelidir.

**Sabit değerler (ENUM):** oda durumu `bos/dolu/temizlikte/bakimda`, rezervasyon durumu `beklemede/onayli/iptal/tamamlandi`, ödeme türü `nakit/kart`, roller `misafir/resepsiyon/yonetici`.

## Veritabanı Nesneleri

**Tetikleyiciler**
- `trg_rezervasyon_cakisma_ekle` / `trg_rezervasyon_cakisma_guncelle`: çakışan tarihli rezervasyonu engeller.
- `trg_konaklama_checkin`, `trg_konaklama_checkout`: check-in'de oda "dolu", check-out'ta "temizlikte" olur.
- `trg_temizlik_tamamlandi`: temizlik kaydı "tamamlandi" olunca oda tekrar "bos" olur.
- `trg_rezervasyon_log_*`, `trg_odeme_log_*`: rezervasyon ve ödeme değişikliklerini `IslemLog` tablosuna yazar.

Çakışma kuralı `sp_cakisma_kontrol` prosedüründedir; trigger'lar bunu çağırır. Çıkış günü başka bir rezervasyonun giriş günü olabilir. Kontrol sırasında oda satırı kilitlenir, böylece eşzamanlı iki rezervasyon aynı odayı alamaz. Kapasite aşımı da aynı yerde engellenir.

**Fonksiyonlar:** `fn_donem_tutar` (gece bazlı sezon fiyatı toplamı), `fn_oda_tutari`, `fn_hizmet_tutari`.

**Saklı prosedürler**
- `sp_bos_odalar(giris, cikis, oda_tipi_id)`: tarih aralığı ve oda tipine göre boş odalar (`oda_tipi_id` NULL ise tümü), toplam fiyatıyla.
- `sp_konaklama_toplam_tutar(konaklama_id)`: gecelik sezon fiyatları + ek hizmetler, ödenen ve kalan tutar.
- `sp_aylik_rapor(yil, ay)`: aylık doluluk oranı ve gelir (genel özet + oda tipi dökümü).
- `sp_checkin(rezervasyon_id, personel_id)`: onaylı rezervasyon için konaklama açar.
- `sp_checkout(konaklama_id, odeme_turu)`: tek transaction içinde check-out (hata olursa ROLLBACK).

**Görünümler**
- `vw_bugun_giris_cikis`: bugün giriş ve çıkış yapacak misafirler.
- `vw_oda_durum`: oda bazında güncel durum ve son temizlik tarihi.

**İndeksler:** rezervasyon tarihleri, oda numarası, misafir e-postası. İndeksli/indekssiz süre karşılaştırması raporda yer alır.

## Normalizasyon

Tüm tablolar en az 3NF düzeyindedir. Ayrıntılar ve ER diyagramı için bkz. [docs/er-diagram.md](docs/er-diagram.md).

## Durum

- [x] README
- [ ] ER diyagramı
- [ ] SQL betiği ve test senaryoları (teslimden önce MySQL 8 üzerinde baştan sona çalıştırılıp doğrulanmalıdır)
- [ ] Backend API
- [ ] Frontend
- [ ] Postman koleksiyonu, rapor ve tanıtım videosu
