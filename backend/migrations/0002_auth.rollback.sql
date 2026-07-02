-- Rollback for 0002_auth. Children first (FK), then parents.
DROP TABLE IF EXISTS refresh_tokens;
DROP TABLE IF EXISTS users;
