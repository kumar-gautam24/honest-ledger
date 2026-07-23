"""Recurring items SQL. Same shape and safety rules as the borrowings repository.

Dynamic SET is built ONLY from the _PATCHABLE whitelist; values are always bind
parameters. That is what keeps the dynamic UPDATE injection-safe.
"""

import uuid
from datetime import datetime

import asyncpg

RECURRING_COLUMNS = """
    id, user_id, title, type, amount_paise, frequency, next_due_date,
    category, card_id, is_active, notes, created_at, updated_at, deleted_at,
    server_seq
"""

_PATCHABLE = {
    "title", "type", "amount_paise", "frequency", "next_due_date",
    "category", "card_id", "is_active", "notes",
}


async def insert_recurring(
    pool: asyncpg.Pool, user_id: uuid.UUID, data: dict
) -> asyncpg.Record | None:
    return await pool.fetchrow(
        f"""
        INSERT INTO recurring_items (
            id, user_id, title, type, amount_paise, frequency, next_due_date,
            category, is_active, notes, created_at, updated_at, card_id
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
        ON CONFLICT (id) DO NOTHING
        RETURNING {RECURRING_COLUMNS}
        """,
        data["id"], user_id, data["title"], data["type"], data["amount_paise"],
        data["frequency"], data["next_due_date"], data["category"],
        data["is_active"], data["notes"], data["created_at"], data["updated_at"],
        data["card_id"],
    )


async def get_recurring(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    recurring_id: uuid.UUID,
    include_deleted: bool = False,
) -> asyncpg.Record | None:
    if include_deleted:
        tombstone_filter = ""
    else:
        tombstone_filter = "AND deleted_at IS NULL"
    return await pool.fetchrow(
        f"""
        SELECT {RECURRING_COLUMNS} FROM recurring_items
        WHERE id = $1 AND user_id = $2 {tombstone_filter}
        """,
        recurring_id, user_id,
    )


async def list_recurring(
    pool: asyncpg.Pool, user_id: uuid.UUID, cursor: int, limit: int
) -> list[asyncpg.Record]:
    return await pool.fetch(
        f"""
        SELECT {RECURRING_COLUMNS} FROM recurring_items
        WHERE user_id = $1 AND deleted_at IS NULL AND server_seq > $2
        ORDER BY server_seq
        LIMIT $3
        """,
        user_id, cursor, limit,
    )


async def update_recurring(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    recurring_id: uuid.UUID,
    updated_at: datetime,
    fields: dict,
) -> asyncpg.Record | None:
    set_parts = []
    params: list = [recurring_id, user_id, updated_at]
    for field, value in fields.items():
        if field not in _PATCHABLE:
            raise ValueError(f"not a patchable column: {field}")
        params.append(value)
        set_parts.append(f"{field} = ${len(params)}")
    set_clause = ", ".join(set_parts)
    return await pool.fetchrow(
        f"""
        UPDATE recurring_items
        SET {set_clause}, updated_at = $3, server_seq = nextval('sync_seq')
        WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL AND updated_at < $3
        RETURNING {RECURRING_COLUMNS}
        """,
        *params,
    )


async def tombstone_recurring(
    pool: asyncpg.Pool, user_id: uuid.UUID, recurring_id: uuid.UUID
) -> str | None:
    row = await pool.fetchrow(
        """
        UPDATE recurring_items
        SET deleted_at = now(), server_seq = nextval('sync_seq')
        WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL
        RETURNING id
        """,
        recurring_id, user_id,
    )
    if row is not None:
        return "deleted"
    ghost = await get_recurring(pool, user_id, recurring_id, include_deleted=True)
    if ghost is not None:
        return "already"
    return None
