-- 0007_no_cost_emi_flags: add no-cost-EMI and financed-fee flags to borrowings
ALTER TABLE borrowings ADD COLUMN is_no_cost_emi BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE borrowings ADD COLUMN fee_financed BOOLEAN NOT NULL DEFAULT FALSE;
