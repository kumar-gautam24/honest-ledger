-- Rollback for 0009.
ALTER TABLE lenders DROP COLUMN foreclosure_extra_interest_days;
ALTER TABLE lenders DROP COLUMN foreclosure_gst;
ALTER TABLE lenders DROP COLUMN foreclosure_free_window_days;
ALTER TABLE lenders DROP COLUMN foreclosure_min;
ALTER TABLE lenders DROP COLUMN foreclosure_pct;

ALTER TABLE repayments DROP COLUMN kind;

ALTER TABLE borrowings DROP COLUMN first_period_days;
ALTER TABLE borrowings DROP COLUMN first_due_date;
ALTER TABLE borrowings DROP COLUMN day_count;
