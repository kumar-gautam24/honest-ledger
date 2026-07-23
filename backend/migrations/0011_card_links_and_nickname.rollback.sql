-- Rollback for 0011.
ALTER TABLE cards DROP COLUMN nickname;
ALTER TABLE recurring_items DROP COLUMN card_id;
ALTER TABLE borrowings DROP COLUMN card_id;
