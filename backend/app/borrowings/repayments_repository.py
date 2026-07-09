"""Repayments SQL — same shape and safety rules as the borrowings repository."""

import uuid
from datetime import datetime

import asyncpg

REPAYMENT_COLUMNS = """
    id, user_id, borrowing_id, amount_paise, date, kind, installment_no, note,
    created_at, updated_at, deleted_at, server_seq
"""

_PATCHABLE = {"amount_paise", "date", "kind", "installment_no", "note"}


async def insert_repayment(
    pool: asyncpg.Pool, user_id: uuid.UUID, borrowing_id: uuid.UUID, data: dict
) -> asyncpg.Record | None:
    return await pool.fetchrow(
        f"""
        INSERT INTO repayments (
            id, user_id, borrowing_id, amount_paise, date, kind,
            installment_no, note, created_at, updated_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        ON CONFLICT (id) DO NOTHING
        RETURNING {REPAYMENT_COLUMNS}
        """,
        data["id"], user_id, borrowing_id, data["amount_paise"], data["date"],
        data["kind"], data["installment_no"], data["note"],
        data["created_at"], data["updated_at"],
    )


async def get_repayment(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    repayment_id: uuid.UUID,
    include_deleted: bool = False,
) -> asyncpg.Record | None:
    if include_deleted:
        tombstone_filter = ""
    else:
        tombstone_filter = "AND deleted_at IS NULL"
    return await pool.fetchrow(
        f"""
        SELECT {REPAYMENT_COLUMNS} FROM repayments
        WHERE id = $1 AND user_id = $2 {tombstone_filter}
        """,
        repayment_id, user_id,
    )


async def list_repayments(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    borrowing_id: uuid.UUID,
    cursor: int,
    limit: int,
) -> list[asyncpg.Record]:
    return await pool.fetch(
        f"""
        SELECT {REPAYMENT_COLUMNS} FROM repayments
        WHERE user_id = $1 AND borrowing_id = $2
          AND deleted_at IS NULL AND server_seq > $3
        ORDER BY server_seq
        LIMIT $4
        """,
        user_id, borrowing_id, cursor, limit,
    )


async def update_repayment(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    repayment_id: uuid.UUID,
    updated_at: datetime,
    fields: dict,
) -> asyncpg.Record | None:
    set_parts = []
    params: list = [repayment_id, user_id, updated_at]
    for field, value in fields.items():
        if field not in _PATCHABLE:
            raise ValueError(f"not a patchable column: {field}")
        params.append(value)
        set_parts.append(f"{field} = ${len(params)}")
    set_clause = ", ".join(set_parts)
    return await pool.fetchrow(
        f"""
        UPDATE repayments
        SET {set_clause}, updated_at = $3, server_seq = nextval('sync_seq')
        WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL AND updated_at < $3
        RETURNING {REPAYMENT_COLUMNS}
        """,
        *params,
    )


async def tombstone_repayment(
    pool: asyncpg.Pool, user_id: uuid.UUID, repayment_id: uuid.UUID
) -> str | None:
    row = await pool.fetchrow(
        """
        UPDATE repayments
        SET deleted_at = now(), server_seq = nextval('sync_seq')
        WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL
        RETURNING id
        """,
        repayment_id, user_id,
    )
    if row is not None:
        return "deleted"
    ghost = await get_repayment(pool, user_id, repayment_id, include_deleted=True)
    if ghost is not None:
        return "already"
    return None
