-- 0004_entities: the rest of the synced dataset (recurring items, custom lenders,
-- cards, card statements). Same sync bones on every row as 0003:
--   id/updated_at/deleted_at/server_seq, server_seq from the shared sync_seq.
-- Notes:
--   * lenders.id is TEXT (mirrors the client; built-in ids are slugs). Only the
--     user's CUSTOM lenders live here — built-ins ship in the app.
--   * cards.lender_id has NO foreign key: a card may point at a built-in lender
--     that is not stored server-side.
--   * card_statements.card_id DOES reference cards (the parent IS stored here),
--     but there is no (card_id, cycle_month) unique — it would fight tombstones;
--     the client guarantees one statement per cycle.

CREATE TABLE lenders (
    id               text PRIMARY KEY,
    user_id          uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    name             text NOT NULL,
    type             text NOT NULL DEFAULT 'card',
    issuer           text,
    network          text,
    typical_rate_pct double precision NOT NULL DEFAULT 0,
    rate_type        text NOT NULL DEFAULT 'reducing',
    fee_type         text NOT NULL DEFAULT 'flat',
    fee_value        double precision NOT NULL DEFAULT 0,
    fee_cap          double precision,
    is_mine          boolean NOT NULL DEFAULT false,
    notes            text,
    created_at       timestamptz NOT NULL DEFAULT now(),
    updated_at       timestamptz NOT NULL DEFAULT now(),
    deleted_at       timestamptz,
    server_seq       bigint NOT NULL DEFAULT nextval('sync_seq')
);

CREATE INDEX lenders_user_seq_idx ON lenders (user_id, server_seq);

CREATE TABLE recurring_items (
    id            uuid PRIMARY KEY,
    user_id       uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    title         text NOT NULL,
    type          text NOT NULL DEFAULT 'subscription',
    amount_paise  bigint NOT NULL,
    frequency     text NOT NULL DEFAULT 'monthly',
    next_due_date timestamptz NOT NULL,
    category      text,
    is_active     boolean NOT NULL DEFAULT true,
    notes         text,
    created_at    timestamptz NOT NULL DEFAULT now(),
    updated_at    timestamptz NOT NULL DEFAULT now(),
    deleted_at    timestamptz,
    server_seq    bigint NOT NULL DEFAULT nextval('sync_seq')
);

CREATE INDEX recurring_items_user_seq_idx ON recurring_items (user_id, server_seq);

CREATE TABLE cards (
    id                 uuid PRIMARY KEY,
    user_id            uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    lender_id          text NOT NULL,
    statement_day      integer NOT NULL,
    due_day            integer NOT NULL,
    credit_limit_paise bigint,
    is_active          boolean NOT NULL DEFAULT true,
    created_at         timestamptz NOT NULL DEFAULT now(),
    updated_at         timestamptz NOT NULL DEFAULT now(),
    deleted_at         timestamptz,
    server_seq         bigint NOT NULL DEFAULT nextval('sync_seq')
);

CREATE INDEX cards_user_seq_idx ON cards (user_id, server_seq);

CREATE TABLE card_statements (
    id                     uuid PRIMARY KEY,
    user_id                uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    card_id                uuid NOT NULL REFERENCES cards (id) ON DELETE CASCADE,
    cycle_month            timestamptz NOT NULL,
    statement_amount_paise bigint NOT NULL,
    due_date               timestamptz NOT NULL,
    paid_amount_paise      bigint NOT NULL DEFAULT 0,
    paid_date              timestamptz,
    notes                  text,
    created_at             timestamptz NOT NULL DEFAULT now(),
    updated_at             timestamptz NOT NULL DEFAULT now(),
    deleted_at             timestamptz,
    server_seq             bigint NOT NULL DEFAULT nextval('sync_seq')
);

CREATE INDEX card_statements_user_seq_idx ON card_statements (user_id, server_seq);
CREATE INDEX card_statements_card_idx ON card_statements (card_id);
