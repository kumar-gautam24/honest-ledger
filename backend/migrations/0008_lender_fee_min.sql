-- 0008_lender_fee_min: add a fee floor to per-user lenders, mirroring fee_cap
-- (0004's ceiling) so percent fees like SBI Card EMI's "min ₹199" can be modelled.
ALTER TABLE lenders ADD COLUMN fee_min double precision;
