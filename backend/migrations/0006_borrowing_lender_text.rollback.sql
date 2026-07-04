-- Rollback for 0006. Only safe if every lender_id is a valid uuid or NULL.
ALTER TABLE borrowings ALTER COLUMN lender_id TYPE uuid USING lender_id::uuid;
