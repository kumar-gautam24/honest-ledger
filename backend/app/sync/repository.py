"""The changes feed: one UNION over the synced tables, ordered by server_seq.

to_jsonb(t) serializes the whole row to JSON in Postgres itself — the feed
needs no per-entity Python mapping, and new synced tables (B3) just add one
UNION arm.
"""

import uuid

import asyncpg


async def list_changes(
    pool: asyncpg.Pool, user_id: uuid.UUID, since: int, limit: int
) -> list[asyncpg.Record]:
    return await pool.fetch(
        """
        SELECT 'borrowing' AS entity, to_jsonb(b) AS data, b.server_seq
        FROM borrowings b
        WHERE b.user_id = $1 AND b.server_seq > $2
        UNION ALL
        SELECT 'repayment' AS entity, to_jsonb(r) AS data, r.server_seq
        FROM repayments r
        WHERE r.user_id = $1 AND r.server_seq > $2
        UNION ALL
        SELECT 'lender' AS entity, to_jsonb(l) AS data, l.server_seq
        FROM lenders l
        WHERE l.user_id = $1 AND l.server_seq > $2
        UNION ALL
        SELECT 'recurring_item' AS entity, to_jsonb(ri) AS data, ri.server_seq
        FROM recurring_items ri
        WHERE ri.user_id = $1 AND ri.server_seq > $2
        UNION ALL
        SELECT 'card' AS entity, to_jsonb(c) AS data, c.server_seq
        FROM cards c
        WHERE c.user_id = $1 AND c.server_seq > $2
        UNION ALL
        SELECT 'card_statement' AS entity, to_jsonb(cs) AS data, cs.server_seq
        FROM card_statements cs
        WHERE cs.user_id = $1 AND cs.server_seq > $2
        ORDER BY server_seq
        LIMIT $3
        """,
        user_id, since, limit,
    )
