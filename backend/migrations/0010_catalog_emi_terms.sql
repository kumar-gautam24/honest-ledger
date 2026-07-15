-- 0010_catalog_emi_terms
--
-- The global `catalog_lenders` table (0005) never got the fee floor (0008) or
-- the foreclosure columns (0009) that the per-user `lenders` table and the
-- Flutter `Lender` model already carry, so it could not represent a card's full
-- EMI terms. It also modelled each issuer as ONE product, but an issuer runs
-- several EMI channels with different rates/fees: Instant/POS (~15-16%, fee
-- capped) vs EMI-on-Call / post-purchase (~18%, bigger uncapped fee) — per the
-- issuers' published EMI T&C.
--
-- This migration (a) adds the missing fee_min + foreclosure_* columns and
-- (b) re-seeds every row to parity with the app's kSeedLenders (kLenderSeedVersion
-- = 6), including the new EMI-on-Call / post-purchase variants and the Kotak/Amex
-- issuers. Every upserted row bumps `version` so clients refetch.

ALTER TABLE catalog_lenders ADD COLUMN fee_min double precision;
ALTER TABLE catalog_lenders ADD COLUMN foreclosure_pct double precision;
ALTER TABLE catalog_lenders ADD COLUMN foreclosure_min double precision;
ALTER TABLE catalog_lenders ADD COLUMN foreclosure_free_window_days integer;
ALTER TABLE catalog_lenders ADD COLUMN foreclosure_gst boolean NOT NULL DEFAULT true;
ALTER TABLE catalog_lenders ADD COLUMN foreclosure_extra_interest_days integer NOT NULL DEFAULT 0;

INSERT INTO catalog_lenders
    (id, name, type, issuer, network, typical_rate_pct, fee_type, fee_value,
     fee_cap, fee_min, foreclosure_pct, foreclosure_min,
     foreclosure_free_window_days, foreclosure_gst, foreclosure_extra_interest_days,
     sort_order, notes)
VALUES
    -- ---- BNPL / app-based credit / NBFC ----
    ('slice', 'slice', 'bnpl', NULL, NULL, 31.15, 'percent', 4,
     NULL, NULL, 0, NULL, NULL, false, 1, 0,
     'Per a slice SFB personal-loan KFS: 31.15% p.a. fixed, fee 4% + 18% GST financed '
     'INTO the loan, daily actual/365 interest, APR 39.73% (effective 47.83%). '
     'Foreclosure free (RBI 2025) but costs 1 extra day of interest.'),
    ('mpokket', 'mPokket', 'bnpl', NULL, NULL, 30, 'percent', 3.75,
     NULL, NULL, NULL, NULL, NULL, true, 0, 1,
     '1.58-3%/month (AIR up to 36%, APR up to ~58%, indicative). Processing ~3.75% + GST.'),
    ('lazypay', 'LazyPay', 'bnpl', NULL, NULL, 24, 'flat', 0,
     NULL, NULL, NULL, NULL, NULL, true, 0, 2,
     '18-32% p.a. depending on profile (indicative).'),
    ('simpl', 'Simpl', 'bnpl', NULL, NULL, 0, 'flat', 0,
     NULL, NULL, NULL, NULL, NULL, true, 0, 3,
     'Interest-free if paid on time; late fees apply.'),
    ('kreditbee', 'KreditBee', 'nbfc', NULL, NULL, 24, 'percent', 5,
     NULL, NULL, NULL, NULL, NULL, true, 0, 4,
     '12-28.5% p.a. (indicative). Processing up to ~5.1% + GST.'),

    -- ---- Generic card-EMI issuers: Instant/POS vs EMI-on-Call/post-purchase ----
    ('hdfc-card-emi', 'HDFC Card EMI', 'card', 'HDFC', NULL, 16.05, 'percent', 2,
     849, 149, 3, NULL, 30, true, 0, 5,
     'SmartEMI at POS ~16.05% p.a. Promos as low as 0.99%/month (indicative). '
     'Processing up to 2% (min 149, max 849) + 18% GST. Foreclosure 3% (free within 30 days).'),
    ('hdfc-post-purchase', 'HDFC SmartEMI (post-purchase)', 'card', 'HDFC', NULL, 18, 'percent', 2,
     849, 149, 3, NULL, 30, true, 0, 6,
     'Post-purchase SmartEMI / Dial-an-EMI ~18% p.a. (indicative). Processing up to 2% '
     '(min 149, max 849) + 18% GST. Foreclosure 3% (free within 30 days).'),
    ('icici-card-emi', 'ICICI Card EMI', 'card', 'ICICI', NULL, 15.99, 'percent', 2.99,
     299, NULL, 3, NULL, NULL, true, 0, 7,
     'Instant EMI (at checkout). Fee VERIFIED from ICICI Instant EMI T&C (w.e.f. 01 Sep '
     '2025): 2.99% capped at 299 + 18% GST. 15.99% indicative. Foreclosure 3% + GST.'),
    ('icici-emi-on-call', 'ICICI EMI-on-Call', 'card', 'ICICI', NULL, 18, 'percent', 2,
     NULL, NULL, 3, NULL, NULL, true, 0, 8,
     'Post-purchase conversion. Per ICICI EMI-on-Call T&C: up to 1.5%/month (~18% p.a.) '
     'and up to 2% fee (no 299 Instant-EMI cap) + 18% GST, foreclosure 3%.'),
    ('sbi-card-emi', 'SBI Card EMI', 'card', 'SBI', NULL, 15, 'percent', 1,
     2000, NULL, 3, NULL, NULL, true, 0, 9,
     'Flexipay (post-purchase). VERIFIED w.e.f. 23 Nov 2025: 9.75-24% p.a. by segment; '
     'fee 1% or 2,000 whichever is LESS (zero at 24/36 months). Foreclosure 3%.'),
    ('sbi-merchant-emi', 'SBI Merchant EMI', 'card', 'SBI', NULL, 18, 'percent', 1,
     2000, NULL, 3, NULL, NULL, true, 0, 10,
     'Merchant/instant EMI at checkout (indicative ~18% upper; SBI rates 9.75-24% by '
     'segment). Fee 1% max 2,000 + 18% GST. Foreclosure 3%.'),
    ('axis-card-emi', 'Axis Card EMI', 'card', 'Axis', NULL, 16, 'flat', 150,
     NULL, NULL, 3, 300, 7, true, 0, 11,
     'Merchant EMI at checkout ~14-16% p.a. (indicative). Processing 150 (+18% GST); '
     'some products up to 2%. Foreclosure 3% or 300 (whichever more), free within 7 days.'),
    ('axis-emi-on-call', 'Axis EMI-on-Call (post-purchase)', 'card', 'Axis', NULL, 18, 'flat', 150,
     NULL, NULL, 3, 300, 7, true, 0, 12,
     'Post-purchase conversion (1.5%/month = ~18% p.a., indicative). Processing 150 flat '
     '(+18% GST); some products up to 2%. Foreclosure 3% or 300 (whichever more).'),
    ('kotak-card-emi', 'Kotak Card EMI', 'card', 'Kotak', NULL, 16, 'flat', 199,
     NULL, NULL, NULL, NULL, NULL, true, 0, 13,
     'Kotak Card EMI (indicative): ~16% p.a.; flat 199 processing fee + 18% GST.'),
    ('amex-card-emi', 'Amex Card EMI', 'card', 'Amex', NULL, 14.99, 'flat', 250,
     NULL, NULL, NULL, NULL, NULL, true, 0, 14,
     'Amex Card EMI (indicative): ~14.99% p.a.; flat 250 processing fee + 18% GST.'),

    -- ---- Common co-branded cards (templates; is_mine is a per-user concept) ----
    ('sbi-flipkart', 'SBI Flipkart', 'card', 'SBI', NULL, 16, 'percent', 1,
     2000, NULL, 3, NULL, NULL, true, 0, 15,
     'SBI Card Flexipay: 9.75-24% p.a. (indicative); 1% fee (max 2,000) + 18% GST; '
     'nil for 24/36 months. Foreclosure 3%.'),
    ('hdfc-swiggy', 'HDFC Swiggy', 'card', 'HDFC', NULL, 16, 'percent', 2,
     849, 149, 3, NULL, 30, true, 0, 16,
     'HDFC SmartEMI (indicative): up to 2% fee (min 149, max 849) + 18% GST. Foreclosure 3%.'),
    ('hdfc-rupay', 'HDFC RuPay', 'card', 'HDFC', 'RuPay', 16, 'percent', 2,
     849, 149, 3, NULL, 30, true, 0, 17,
     'HDFC SmartEMI (indicative): up to 2% fee (min 149, max 849) + 18% GST. Foreclosure 3%.'),
    ('axis-flipkart', 'Axis Flipkart', 'card', 'Axis', NULL, 16, 'flat', 150,
     NULL, NULL, 3, 300, 7, true, 0, 18,
     'Axis merchant EMI at checkout ~14-16% p.a. (indicative); 150 fee (+18% GST); some '
     'products up to 2%. For post-purchase use Axis EMI-on-Call (~18%). Foreclosure 3%.'),
    ('icici-amazon-pay', 'ICICI Amazon Pay', 'card', 'ICICI', 'Visa', 15.99, 'percent', 2.99,
     299, NULL, 3, NULL, NULL, true, 0, 19,
     'ICICI Instant EMI 15.99% p.a.; 2.99% fee (max 299) + 18% GST (verified, Jul 2026). '
     'For a merchant/post-purchase conversion use ICICI EMI-on-Call (18% + 2% fee).')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name, type = EXCLUDED.type, issuer = EXCLUDED.issuer,
    network = EXCLUDED.network, typical_rate_pct = EXCLUDED.typical_rate_pct,
    fee_type = EXCLUDED.fee_type, fee_value = EXCLUDED.fee_value,
    fee_cap = EXCLUDED.fee_cap, fee_min = EXCLUDED.fee_min,
    foreclosure_pct = EXCLUDED.foreclosure_pct, foreclosure_min = EXCLUDED.foreclosure_min,
    foreclosure_free_window_days = EXCLUDED.foreclosure_free_window_days,
    foreclosure_gst = EXCLUDED.foreclosure_gst,
    foreclosure_extra_interest_days = EXCLUDED.foreclosure_extra_interest_days,
    sort_order = EXCLUDED.sort_order, notes = EXCLUDED.notes,
    deleted_at = NULL, updated_at = now(), version = nextval('catalog_seq');
