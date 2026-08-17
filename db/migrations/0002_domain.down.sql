DROP TABLE IF EXISTS saved_medicines;
DROP TABLE IF EXISTS pharmacy_stock;
DROP TABLE IF EXISTS medicines;
DROP TABLE IF EXISTS pharmacies;
DROP TRIGGER IF EXISTS users_set_updated_at ON users;
DROP FUNCTION IF EXISTS set_updated_at();
-- Keep pg_trgm and postgis extensions available for future migrations.
