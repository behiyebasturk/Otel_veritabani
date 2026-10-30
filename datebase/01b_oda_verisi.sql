USE otel_db;

-- 3 oda tipi
INSERT INTO ODA_TIPI (tip_adi, kapasite, aciklama, temel_fiyat) VALUES
('standart', 2, 'Çift kişilik standart oda, şehir manzaralı', 1500.00),
('deluxe',   3, 'Geniş deluxe oda, balkonlu, deniz manzaralı', 2500.00),
('suit',     4, 'Oturma alanlı lüks suit, jakuzili',           4500.00);

-- 20 oda (1-2. kat standart, 3-4. kat deluxe, 5. kat suit)
INSERT INTO ODA (oda_no, kat, oda_tipi_id, durum) VALUES
('101',1,1,'bos'),('102',1,1,'bos'),('103',1,1,'bos'),('104',1,1,'bos'),('105',1,1,'bos'),
('201',2,1,'bos'),('202',2,1,'bos'),('203',2,1,'bos'),('204',2,1,'bos'),('205',2,1,'bos'),
('301',3,2,'bos'),('302',3,2,'bos'),('303',3,2,'bos'),('304',3,2,'bos'),
('401',4,2,'bos'),('402',4,2,'bos'),('403',4,2,'bakimda'),
('501',5,3,'bos'),('502',5,3,'bos'),('503',5,3,'bos');

-- Sezon fiyatları (2026-2027, her tip için 3 dönem)
INSERT INTO SEZON_FIYATI (oda_tipi_id, baslangic_tarihi, bitis_tarihi, gecelik_fiyat) VALUES
(1,'2026-01-01','2026-03-31',1200.00),
(1,'2026-04-01','2026-06-14',1600.00),
(1,'2026-06-15','2026-09-30',2200.00),
(1,'2026-10-01','2026-10-31',1400.00),
(1,'2026-11-01','2027-03-31',1200.00),
(1,'2027-04-01','2027-06-14',1600.00),
(1,'2027-06-15','2027-09-30',2200.00),
(1,'2027-10-01','2027-12-31',1400.00),
(2,'2026-01-01','2026-03-31',2000.00),
(2,'2026-04-01','2026-06-14',2700.00),
(2,'2026-06-15','2026-09-30',3500.00),
(2,'2026-10-01','2026-10-31',2300.00),
(2,'2026-11-01','2027-03-31',2000.00),
(2,'2027-04-01','2027-06-14',2700.00),
(2,'2027-06-15','2027-09-30',3500.00),
(2,'2027-10-01','2027-12-31',2300.00),
(3,'2026-01-01','2026-03-31',3800.00),
(3,'2026-04-01','2026-06-14',5000.00),
(3,'2026-06-15','2026-09-30',6500.00),
(3,'2026-10-01','2026-10-31',4200.00),
(3,'2026-11-01','2027-03-31',3800.00),
(3,'2027-04-01','2027-06-14',5000.00),
(3,'2027-06-15','2027-09-30',6500.00),
(3,'2027-10-01','2027-12-31',4200.00);

-- Personel
INSERT INTO PERSONEL (ad, soyad, gorev, ise_giris_tarihi) VALUES
('Mehmet','Kaya','yonetici','2020-03-01'),
('Ayşe','Demir','resepsiyon','2022-06-15'),
('Burak','Çelik','resepsiyon','2023-01-10'),
('Elif','Yıldız','resepsiyon','2024-04-20'),
('Fatma','Şahin','kat_gorevlisi','2021-09-05'),
('Hasan','Arslan','kat_gorevlisi','2022-11-12'),
('Zeynep','Öztürk','kat_gorevlisi','2023-07-01'),
('Murat','Aydın','kat_gorevlisi','2024-02-15');

-- Ek hizmetler
INSERT INTO EK_HIZMET (hizmet_adi, birim_fiyat) VALUES
('Kahvaltı', 250.00),
('Spa', 800.00),
('Otopark', 150.00),
('Oda servisi', 400.00),
('Çamaşırhane', 200.00),
('Havalimanı transferi', 600.00);
