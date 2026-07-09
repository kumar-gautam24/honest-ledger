-- 0009_day_count_and_foreclosure
--
-- Personal loans (slice SFB and most NBFCs) accrue interest per day on an
-- actual/365 basis, and their first period is irregular — disbursed 31 Jan,
-- first EMI 5 Mar is 34 days, not a month. Card EMIs quote a uniform monthly
-- twelfth. `day_count` distinguishes them; `first_due_date` anchors the
-- schedule; `first_period_days` lets a KFS's own day count win over the
-- calendar when the two disagree.
ALTER TABLE borrowings ADD COLUMN day_count TEXT NOT NULL DEFAULT 'monthlyUniform';
ALTER TABLE borrowings ADD COLUMN first_due_date TIMESTAMPTZ;
ALTER TABLE borrowings ADD COLUMN first_period_days INTEGER;

-- A ledger line is either money that services the debt, or a charge the lender
-- took on top (a penal fee). A charge is waste but retires no principal, so it
-- can never tick off an installment.
ALTER TABLE repayments ADD COLUMN kind TEXT NOT NULL DEFAULT 'payment';

-- Foreclosure terms, so the app can price a payoff instead of asking the user
-- to type a fee. slice charges 0% (RBI Pre-payment Charges Directions, 2025)
-- but adds one day of interest; Axis charges 3% or ₹300 whichever is higher and
-- waives it inside 7 days; HDFC waives it inside 30.
ALTER TABLE lenders ADD COLUMN foreclosure_pct DOUBLE PRECISION;
ALTER TABLE lenders ADD COLUMN foreclosure_min DOUBLE PRECISION;
ALTER TABLE lenders ADD COLUMN foreclosure_free_window_days INTEGER;
ALTER TABLE lenders ADD COLUMN foreclosure_gst BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE lenders ADD COLUMN foreclosure_extra_interest_days INTEGER NOT NULL DEFAULT 0;
