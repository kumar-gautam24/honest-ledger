-- Rollback for 0007.
ALTER TABLE borrowings DROP COLUMN fee_financed;
ALTER TABLE borrowings DROP COLUMN is_no_cost_emi;
