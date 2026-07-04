-- 0005_catalog_settings: server-driven lender catalog (global, admin-managed,
-- public-read) + per-user settings (income & friends), + an is_admin flag.
--
-- The catalog is NOT the per-user `lenders` table from 0004 (that is the user's
-- CUSTOM lenders). This is one shared, editable-without-an-app-release template list.
-- It has no user_id and its own version sequence so clients refetch only on change.

ALTER TABLE users ADD COLUMN is_admin boolean NOT NULL DEFAULT false;

CREATE SEQUENCE IF NOT EXISTS catalog_seq;

CREATE TABLE catalog_lenders (
    id               text PRIMARY KEY,
    name             text NOT NULL,
    type             text NOT NULL DEFAULT 'card',
    issuer           text,
    network          text,
    typical_rate_pct double precision NOT NULL DEFAULT 0,
    rate_type        text NOT NULL DEFAULT 'reducing',
    fee_type         text NOT NULL DEFAULT 'flat',
    fee_value        double precision NOT NULL DEFAULT 0,
    fee_cap          double precision,
    notes            text,
    is_active        boolean NOT NULL DEFAULT true,
    sort_order       integer NOT NULL DEFAULT 0,
    updated_at       timestamptz NOT NULL DEFAULT now(),
    deleted_at       timestamptz,
    version          bigint NOT NULL DEFAULT nextval('catalog_seq')
);

-- Seed parity with the app's kSeedLenders (kLenderSeedVersion = 3). is_mine is a
-- per-user concept, so it is intentionally NOT carried into the global catalog.
INSERT INTO catalog_lenders
    (id, name, type, issuer, network, typical_rate_pct, fee_type, fee_value, fee_cap, sort_order, notes)
VALUES
    ('slice', 'slice', 'bnpl', NULL, NULL, 36, 'percent', 2.5, NULL, 0,
     'slice borrow ~18% p.a.; slice card ~36% online / 42% bank transfer. 2.5% transfer fee (min ₹25) + 18% GST.'),
    ('mpokket', 'mPokket', 'bnpl', NULL, NULL, 30, 'percent', 3.75, NULL, 1,
     '1.58–3%/month (AIR up to 36%, APR up to ~58%). Processing ~3.75% + GST.'),
    ('lazypay', 'LazyPay', 'bnpl', NULL, NULL, 24, 'flat', 0, NULL, 2,
     '18–32% p.a. depending on profile.'),
    ('simpl', 'Simpl', 'bnpl', NULL, NULL, 0, 'flat', 0, NULL, 3,
     'Interest-free if paid on time; late fees apply.'),
    ('kreditbee', 'KreditBee', 'nbfc', NULL, NULL, 24, 'percent', 5, NULL, 4,
     '12–28.5% p.a. Processing up to ~5.1% + GST.'),
    ('hdfc-card-emi', 'HDFC Card EMI', 'card', 'HDFC', NULL, 16, 'percent', 2, 849, 5,
     'SmartEMI: POS ~15% / post-purchase ~18% p.a. Processing up to 2% (min ₹149, max ₹849) + 18% GST.'),
    ('icici-card-emi', 'ICICI Card EMI', 'card', 'ICICI', NULL, 15.99, 'percent', 2.99, 299, 6,
     'Instant EMI 15.99% p.a.; 2.99% fee (max ₹299) + 18% GST. EMI-on-call: up to 2% of the amount.'),
    ('sbi-card-emi', 'SBI Card EMI', 'card', 'SBI', NULL, 16, 'percent', 1, 2000, 7,
     'Flexipay 9.75–24% p.a.; 1% fee (max ₹2000) + 18% GST; nil fee for 24/36 months.'),
    ('axis-card-emi', 'Axis Card EMI', 'card', 'Axis', NULL, 16, 'flat', 150, NULL, 8,
     'Merchant EMI ~14% / post-purchase ~18% p.a. Processing ₹150 (+18% GST); some products up to 2%.'),
    ('sbi-flipkart', 'SBI Flipkart', 'card', 'SBI', NULL, 16, 'percent', 1, 2000, 9,
     'SBI Card Flexipay: 9.75–24% p.a.; 1% fee (max ₹2000) + 18% GST; nil for 24/36 months.'),
    ('hdfc-swiggy', 'HDFC Swiggy', 'card', 'HDFC', NULL, 16, 'percent', 2, 849, 10,
     'HDFC SmartEMI: up to 2% (min ₹149, max ₹849) + 18% GST.'),
    ('hdfc-rupay', 'HDFC RuPay', 'card', 'HDFC', 'RuPay', 16, 'percent', 2, 849, 11,
     'HDFC SmartEMI: up to 2% (min ₹149, max ₹849) + 18% GST.'),
    ('axis-flipkart', 'Axis Flipkart', 'card', 'Axis', NULL, 16, 'flat', 150, NULL, 12,
     'Axis EMI terms: ~14–18% p.a.; ₹150 fee (+18% GST); some products up to 2%.'),
    ('icici-amazon-pay', 'ICICI Amazon Pay', 'card', 'ICICI', 'Visa', 15.99, 'percent', 2.99, 299, 13,
     'ICICI Instant EMI 15.99% p.a.; 2.99% fee (max ₹299) + 18% GST.');

CREATE TABLE user_settings (
    user_id    uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    key        text NOT NULL,
    value      jsonb NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz,
    server_seq bigint NOT NULL DEFAULT nextval('sync_seq'),
    PRIMARY KEY (user_id, key)
);

CREATE INDEX user_settings_user_seq_idx ON user_settings (user_id, server_seq);
