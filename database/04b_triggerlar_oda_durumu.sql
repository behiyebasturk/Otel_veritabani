USE otel_db;

DROP TRIGGER IF EXISTS trg_checkin_oda_dolu;
DROP TRIGGER IF EXISTS trg_checkout_oda_temizlikte;

DELIMITER $$

CREATE TRIGGER trg_checkin_oda_dolu
AFTER INSERT ON KONAKLAMA
FOR EACH ROW
BEGIN
    UPDATE ODA
    SET durum = 'dolu'
    WHERE oda_id = (SELECT oda_id
                    FROM REZERVASYON
                    WHERE rezervasyon_id = NEW.rezervasyon_id);
END$$

CREATE TRIGGER trg_checkout_oda_temizlikte
AFTER UPDATE ON KONAKLAMA
FOR EACH ROW
BEGIN
    IF OLD.gercek_cikis IS NULL AND NEW.gercek_cikis IS NOT NULL THEN
        UPDATE ODA
        SET durum = 'temizlikte'
        WHERE oda_id = (SELECT oda_id
                        FROM REZERVASYON
                        WHERE rezervasyon_id = NEW.rezervasyon_id);
    END IF;
END$$

DELIMITER ;
