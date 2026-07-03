-- 0003_borrowings: first synced entities. Sync bones on every row:
--   id          client-generated UUID (idempotent creates)
--   updated_at  last-write-wins referee
--   deleted_at  tombstone (deletes must propagate to other devices)
--   server_seq  change-feed cursor, from ONE sequence shared by all synced tables
CREATE SEQUENCE IF NOT EXISTS sync_seq;

CREATE TABLE borrowings (
    id                   uuid PRIMARY KEY,
    user_id              uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    title                text NOT NULL,
    kind                 text NOT NULL DEFAULT 'flexibleLoan',
    lender_id            uuid,
    lender_name          text NOT NULL DEFAULT '',
    principal_paise      bigint NOT NULL,
    processing_fee_paise bigint NOT NULL DEFAULT 0,
    gst_on_fee_paise     bigint NOT NULL DEFAULT 0,
    foreclosure_fee_paise bigint,
    gst_on_interest      boolean NOT NULL DEFAULT false,
    interest_rate_pct    double precision NOT NULL DEFAULT 0,
    rate_type            text NOT NULL DEFAULT 'reducing',
    tenure_months        integer NOT NULL DEFAULT 0,
    min_payment_paise    bigint NOT NULL DEFAULT 0,
    start_date           timestamptz NOT NULL,
    status               text NOT NULL DEFAULT 'active',
    notes                text,
    created_at           timestamptz NOT NULL DEFAULT now(),
    updated_at           timestamptz NOT NULL DEFAULT now(),
    deleted_at           timestamptz,
    server_seq           bigint NOT NULL DEFAULT nextval('sync_seq')
);

CREATE INDEX borrowings_user_seq_idx ON borrowings (user_id, server_seq);

CREATE TABLE repayments (
    id             uuid PRIMARY KEY,
    user_id        uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    borrowing_id   uuid NOT NULL REFERENCES borrowings (id) ON DELETE CASCADE,
    amount_paise   bigint NOT NULL,
    date           timestamptz NOT NULL,
    installment_no integer,
    note           text,
    created_at     timestamptz NOT NULL DEFAULT now(),
    updated_at     timestamptz NOT NULL DEFAULT now(),
    deleted_at     timestamptz,
    server_seq     bigint NOT NULL DEFAULT nextval('sync_seq')
);

CREATE INDEX repayments_user_seq_idx ON repayments (user_id, server_seq);
CREATE INDEX repayments_borrowing_idx ON repayments (borrowing_id);
