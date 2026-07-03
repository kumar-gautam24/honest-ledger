-- Rollback for 0003_borrowings. Children first.
DROP TABLE IF EXISTS repayments;
DROP TABLE IF EXISTS borrowings;
DROP SEQUENCE IF EXISTS sync_seq;
