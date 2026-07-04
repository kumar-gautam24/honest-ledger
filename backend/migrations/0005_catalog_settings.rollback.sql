-- Rollback for 0005_catalog_settings.
DROP TABLE IF EXISTS user_settings;
DROP TABLE IF EXISTS catalog_lenders;
DROP SEQUENCE IF EXISTS catalog_seq;
ALTER TABLE users DROP COLUMN IF EXISTS is_admin;
