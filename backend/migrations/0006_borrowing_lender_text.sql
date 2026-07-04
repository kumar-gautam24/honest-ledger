-- 0006_borrowing_lender_text: borrowings.lender_id was uuid (0003), but client
-- lender ids are text slugs (e.g. 'slice', 'hdfc-swiggy') from the app's catalog.
-- The Flutter integration sends those, so relax the column to text.
ALTER TABLE borrowings ALTER COLUMN lender_id TYPE text USING lender_id::text;
