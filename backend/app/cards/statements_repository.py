"""Card statements SQL — the child rows, same shape as the repayments repository."""

import uuid
from datetime import datetime

import asyncpg

STATEMENT_COLUMNS = """
    id, user_id, card_id, cycle_month, statement_amount_paise, due_date,
    paid_amount_paise, paid_date, notes,
    created_at, updated_at, deleted_at, server_seq
"""

_PATCHABLE = {
    "cycle_month", "statement_amount_paise", "due_date",
    "paid_amount_paise", "paid_date", "notes",
}


async def insert_statement(
    pool: asyncpg.Pool, user_id: uuid.UUID, card_id: uuid.UUID, data: dict
) -> asyncpg.Record | None:
    return await pool.fetchrow(
        f"""
        INSERT INTO card_statements (
            id, user_id, card_id, cycle_month, statement_amount_paise, due_date,
            paid_amount_paise, paid_date, notes, created_at, updated_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
        ON CONFLICT (id) DO NOTHING
        RETURNING {STATEMENT_COLUMNS}
        """,
        data["id"], user_id, card_id, data["cycle_month"],
        data["statement_amount_paise"], data["due_date"],
        data["paid_amount_paise"], data["paid_date"], data["notes"],
        data["created_at"], data["updated_at"],
    )


async def get_statement(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    statement_id: uuid.UUID,
    include_deleted: bool = False,
) -> asyncpg.Record | None:
    if include_deleted:
        tombstone_filter = ""
    else:
        tombstone_filter = "AND deleted_at IS NULL"
    return await pool.fetchrow(
        f"""
        SELECT {STATEMENT_COLUMNS} FROM card_statements
        WHERE id = $1 AND user_id = $2 {tombstone_filter}
        """,
        statement_id, user_id,
    )


async def list_statements(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    card_id: uuid.UUID,
    cursor: int,
    limit: int,
) -> list[asyncpg.Record]:
    return await pool.fetch(
        f"""
        SELECT {STATEMENT_COLUMNS} FROM card_statements
        WHERE user_id = $1 AND card_id = $2
          AND deleted_at IS NULL AND server_seq > $3
        ORDER BY server_seq
        LIMIT $4
        """,
        user_id, card_id, cursor, limit,
    )


async def update_statement(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    statement_id: uuid.UUID,
    updated_at: datetime,
    fields: dict,
) -> asyncpg.Record | None:
    set_parts = []
    params: list = [statement_id, user_id, updated_at]
    for field, value in fields.items():
        if field not in _PATCHABLE:
            raise ValueError(f"not a patchable column: {field}")
        params.append(value)
        set_parts.append(f"{field} = ${len(params)}")
    set_clause = ", ".join(set_parts)
    return await pool.fetchrow(
        f"""
        UPDATE card_statements
        SET {set_clause}, updated_at = $3, server_seq = nextval('sync_seq')
        WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL AND updated_at < $3
        RETURNING {STATEMENT_COLUMNS}
        """,
        *params,
    )


async def tombstone_statement(
    pool: asyncpg.Pool, user_id: uuid.UUID, statement_id: uuid.UUID
) -> str | None:
    row = await pool.fetchrow(
        """
        UPDATE card_statements
        SET deleted_at = now(), server_seq = nextval('sync_seq')
        WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL
        RETURNING id
        """,
        statement_id, user_id,
    )
    if row is not None:
        return "deleted"
    ghost = await get_statement(pool, user_id, statement_id, include_deleted=True)
    if ghost is not None:
        return "already"
    return None
