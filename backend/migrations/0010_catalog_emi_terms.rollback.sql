-- Rollback for 0010.
-- Remove the rows introduced by 0010 (the EMI-on-Call / post-purchase variants
-- and the Kotak/Amex issuers). Value edits to pre-existing rows are not restored.
DELETE FROM catalog_lenders WHERE id IN (
    'hdfc-post-purchase', 'icici-emi-on-call', 'sbi-merchant-emi',
    'axis-emi-on-call', 'kotak-card-emi', 'amex-card-emi'
);

ALTER TABLE catalog_lenders DROP COLUMN foreclosure_extra_interest_days;
ALTER TABLE catalog_lenders DROP COLUMN foreclosure_gst;
ALTER TABLE catalog_lenders DROP COLUMN foreclosure_free_window_days;
ALTER TABLE catalog_lenders DROP COLUMN foreclosure_min;
ALTER TABLE catalog_lenders DROP COLUMN foreclosure_pct;
ALTER TABLE catalog_lenders DROP COLUMN fee_min;
