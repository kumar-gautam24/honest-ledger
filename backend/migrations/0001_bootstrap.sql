-- 0001_bootstrap: proves the migration pipeline end-to-end.
-- Creates a tiny key/value table we can use for schema-wide metadata later
-- (e.g. a seed version). Real domain tables arrive in B1 (users) and B2 (borrowings).
-- The rollback (down) SQL lives in the sibling file 0001_bootstrap.rollback.sql.

CREATE TABLE IF NOT EXISTS schema_meta (
    key        text PRIMARY KEY,
    value      text NOT NULL,
    updated_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO schema_meta (key, value)
VALUES ('bootstrap', '0001')
ON CONFLICT (key) DO NOTHING;
