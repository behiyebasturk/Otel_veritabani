CREATE DATABASE IF NOT EXISTS otel_db CHARACTER SET utf8mb4;
USE otel_db;

DROP TABLE IF EXISTS ODEME;
DROP TABLE IF EXISTS KONAKLAMA_HIZMETI;
DROP TABLE IF EXISTS KONAKLAMA;
DROP TABLE IF EXISTS REZERVASYON;
DROP TABLE IF EXISTS KULLANICI;
DROP TABLE IF EXISTS MISAFIR;

SHOW TABLES;

CREATE TABLE MISAFIR(
   misafir_id INT PRIMARY KEY AUTO_INCREMENT,
   ad VARCHAR(50) NOT NULL,
   soyad VARCHAR(50) NOT NULL,
   telefon VARCHAR(25),
   eposta VARCHAR(100) NOT NULL UNIQUE,
    tc_no VARCHAR(20) NOT NULL UNIQUE,
    dogum_tarihi DATE
);

CREATE TABLE KULLANICI(
  kullanici_id INT PRIMARY KEY AUTO_INCREMENT,
  kullanici_adi VARCHAR(50) NOT NULL UNIQUE,
  sifre VARCHAR(255) NOT NULL,
  rol ENUM('misafir','resepsiyon','yonetici') NOT NULL,
  misafir_id INT UNIQUE,
  personel_id INT UNIQUE,
  FOREIGN KEY(misafir_id)
      REFERENCES MISAFIR(misafir_id),
  CONSTRAINT chk_kullanici_iliski CHECK((misafir_id IS NOT NULL AND personel_id IS NULL)
     OR (misafir_id IS NULL AND personel_id IS NOT NULL))
);

CREATE TABLE REZERVASYON(
  rezervasyon_id INT PRIMARY KEY AUTO_INCREMENT,
  misafir_id INT NOT NULL,
  oda_id INT NOT NULL,
  giris_tarihi DATE NOT NULL,
  cikis_tarihi DATE NOT NULL,
  kisi_sayisi INT NOT NULL,
  durum   ENUM('beklemede','onayli','iptal','tamamlandi') NOT NULL DEFAULT 'beklemede',
  olusturma_tarihi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(misafir_id)
      REFERENCES MISAFIR(misafir_id),
   FOREIGN KEY(oda_id)
      REFERENCES ODA(oda_id),
       CONSTRAINT chk_rez_tarih CHECK (cikis_tarihi > giris_tarihi)
);

CREATE TABLE KONAKLAMA(
  konaklama_id INT PRIMARY KEY AUTO_INCREMENT,
  rezervasyon_id INT NOT NULL UNIQUE,
  gercek_giris DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gercek_cikis DATETIME NULL,
  personel_id INT NULL,
FOREIGN KEY(rezervasyon_id)
      REFERENCES REZERVASYON(rezervasyon_id)
);

CREATE TABLE KONAKLAMA_HIZMETI (
  konaklama_hizmeti_id INT PRIMARY KEY AUTO_INCREMENT,
  konaklama_id INT NOT NULL,
  ek_hizmet_id INT NOT NULL,            
  adet INT NOT NULL DEFAULT 1,
  tarih DATE NOT NULL,
  uygulanan_fiyat      DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (konaklama_id)
    REFERENCES KONAKLAMA(konaklama_id)
);

CREATE TABLE ODEME(
      odeme_id INT PRIMARY KEY AUTO_INCREMENT,
      konaklama_id INT NOT NULL,
      tutar DECIMAL(10,2) NOT NULL,
      odeme_tarihi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      odeme_yontemi ENUM('nakit','kart') NOT NULL,
      odeme_durumu VARCHAR(20) NOT NULL DEFAULT 'beklemede',
       FOREIGN KEY(konaklama_id)
       REFERENCES KONAKLAMA(konaklama_id)
);

ALTER TABLE KULLANICI         ADD FOREIGN KEY (personel_id)  REFERENCES PERSONEL(personel_id);
ALTER TABLE KONAKLAMA         ADD FOREIGN KEY (personel_id)  REFERENCES PERSONEL(personel_id);
ALTER TABLE KONAKLAMA_HIZMETI ADD FOREIGN KEY (ek_hizmet_id) REFERENCES EK_HIZMET(ek_hizmet_id);

SHOW TABLES;
