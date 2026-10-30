DROP DATABASE IF EXISTS otel_db;

CREATE DATABASE otel_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_turkish_ci;

USE otel_db;

CREATE TABLE ODA_TIPI (
  oda_tipi_id  INT PRIMARY KEY AUTO_INCREMENT,
  tip_adi      VARCHAR(30)   NOT NULL UNIQUE,
  kapasite     TINYINT       NOT NULL CHECK (kapasite > 0),
  aciklama     VARCHAR(255),
  temel_fiyat  DECIMAL(10,2) NOT NULL CHECK (temel_fiyat >= 0)
);

CREATE TABLE ODA (
  oda_id      INT PRIMARY KEY AUTO_INCREMENT,
  oda_no      VARCHAR(10) NOT NULL UNIQUE,
  kat         TINYINT     NOT NULL,
  oda_tipi_id INT         NOT NULL,
  durum       ENUM('bos','dolu','temizlikte','bakimda') NOT NULL DEFAULT 'bos',
  FOREIGN KEY (oda_tipi_id) REFERENCES ODA_TIPI(oda_tipi_id)
);

CREATE TABLE SEZON_FIYATI (
  sezon_fiyati_id  INT PRIMARY KEY AUTO_INCREMENT,
  oda_tipi_id      INT           NOT NULL,
  baslangic_tarihi DATE          NOT NULL,
  bitis_tarihi     DATE          NOT NULL,
  gecelik_fiyat    DECIMAL(10,2) NOT NULL CHECK (gecelik_fiyat >= 0),
  FOREIGN KEY (oda_tipi_id) REFERENCES ODA_TIPI(oda_tipi_id),
  CHECK (bitis_tarihi >= baslangic_tarihi),
  UNIQUE (oda_tipi_id, baslangic_tarihi)
);

CREATE TABLE PERSONEL (
  personel_id      INT PRIMARY KEY AUTO_INCREMENT,
  ad               VARCHAR(50) NOT NULL,
  soyad            VARCHAR(50) NOT NULL,
  gorev            ENUM('resepsiyon','kat_gorevlisi','yonetici') NOT NULL,
  ise_giris_tarihi DATE        NOT NULL
);

CREATE TABLE EK_HIZMET (
  ek_hizmet_id INT PRIMARY KEY AUTO_INCREMENT,
  hizmet_adi   VARCHAR(60)   NOT NULL UNIQUE,
  birim_fiyat  DECIMAL(10,2) NOT NULL CHECK (birim_fiyat >= 0)
);

CREATE TABLE TEMIZLIK_KAYDI (
  temizlik_id INT PRIMARY KEY AUTO_INCREMENT,
  oda_id      INT  NOT NULL,
  personel_id INT  NOT NULL,
  tarih       DATE NOT NULL,
  durum       ENUM('bekliyor','yapildi') NOT NULL DEFAULT 'bekliyor',
  FOREIGN KEY (oda_id)      REFERENCES ODA(oda_id),
  FOREIGN KEY (personel_id) REFERENCES PERSONEL(personel_id)
);

CREATE TABLE ISLEM_LOG (
  log_id       BIGINT PRIMARY KEY AUTO_INCREMENT,
  tablo_adi    VARCHAR(50) NOT NULL,
  kayit_id     INT         NOT NULL,
  islem_tipi   ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  eski_deger   JSON NULL,
  yeni_deger   JSON NULL,
  islem_zamani DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sezon_tip_tarih ON SEZON_FIYATI (oda_tipi_id, baslangic_tarihi, bitis_tarihi);
CREATE INDEX idx_log_tablo_zaman ON ISLEM_LOG (tablo_adi, islem_zamani);

