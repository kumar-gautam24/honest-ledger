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
        ORDER BY server_seq
        LIMIT $3
        """,
        user_id, since, limit,
    )
