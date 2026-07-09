"""Borrowings SQL. Raw, parameterized, user-scoped — the only DB access here.

The UPDATE builds its SET clause dynamically, but ONLY from the _PATCHABLE
whitelist below — column names never come from user input; values are always
bind parameters. That is what keeps dynamic SQL injection-safe.
"""

import uuid
from datetime import datetime

import asyncpg

BORROWING_COLUMNS = """
    id, user_id, title, kind, lender_id, lender_name,
    principal_paise, processing_fee_paise, gst_on_fee_paise, foreclosure_fee_paise,
    gst_on_interest, is_no_cost_emi, fee_financed, interest_rate_pct, rate_type,
    tenure_months, min_payment_paise, day_count, first_due_date, first_period_days,
    start_date, status, notes, created_at, updated_at, deleted_at, server_seq
"""

_PATCHABLE = {
    "title", "kind", "lender_id", "lender_name",
    "principal_paise", "processing_fee_paise", "gst_on_fee_paise",
    "foreclosure_fee_paise", "gst_on_interest", "is_no_cost_emi",
    "fee_financed", "interest_rate_pct",
    "rate_type", "tenure_months", "min_payment_paise",
    "day_count", "first_due_date", "first_period_days",
    "start_date", "status", "notes",
}


async def insert_borrowing(
    pool: asyncpg.Pool, user_id: uuid.UUID, data: dict
) -> asyncpg.Record | None:
    """Idempotent create: on id conflict returns None (caller decides what
    that means — replay of my own row vs collision with someone else's)."""
    return await pool.fetchrow(
        f"""
        INSERT INTO borrowings (
            id, user_id, title, kind, lender_id, lender_name,
            principal_paise, processing_fee_paise, gst_on_fee_paise,
            foreclosure_fee_paise, gst_on_interest, is_no_cost_emi, fee_financed,
            interest_rate_pct,
            rate_type, tenure_months, min_payment_paise,
            day_count, first_due_date, first_period_days,
            start_date, status, notes, created_at, updated_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10,
                $11, $12, $13, $14, $15, $16, $17, $18, $19, $20,
                $21, $22, $23, $24, $25)
        ON CONFLICT (id) DO NOTHING
        RETURNING {BORROWING_COLUMNS}
        """,
        data["id"], user_id, data["title"], data["kind"],
        data["lender_id"], data["lender_name"],
        data["principal_paise"], data["processing_fee_paise"],
        data["gst_on_fee_paise"], data["foreclosure_fee_paise"],
        data["gst_on_interest"], data["is_no_cost_emi"], data["fee_financed"],
        data["interest_rate_pct"],
        data["rate_type"], data["tenure_months"], data["min_payment_paise"],
        data["day_count"], data["first_due_date"], data["first_period_days"],
        data["start_date"], data["status"], data["notes"],
        data["created_at"], data["updated_at"],
    )


async def get_borrowing(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    borrowing_id: uuid.UUID,
    include_deleted: bool = False,
) -> asyncpg.Record | None:
    if include_deleted:
        tombstone_filter = ""
    else:
        tombstone_filter = "AND deleted_at IS NULL"
    return await pool.fetchrow(
        f"""
        SELECT {BORROWING_COLUMNS} FROM borrowings
        WHERE id = $1 AND user_id = $2 {tombstone_filter}
        """,
        borrowing_id, user_id,
    )


async def list_borrowings(
    pool: asyncpg.Pool, user_id: uuid.UUID, cursor: int, limit: int
) -> list[asyncpg.Record]:
    return await pool.fetch(
        f"""
        SELECT {BORROWING_COLUMNS} FROM borrowings
        WHERE user_id = $1 AND deleted_at IS NULL AND server_seq > $2
        ORDER BY server_seq
        LIMIT $3
        """,
        user_id, cursor, limit,
    )


async def update_borrowing(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    borrowing_id: uuid.UUID,
    updated_at: datetime,
    fields: dict,
) -> asyncpg.Record | None:
    """Atomic last-write-wins: the WHERE clause only matches when the incoming
    edit is NEWER than what we hold and the row isn't tombstoned. Returns the
    updated row, or None (absent / foreign / tombstoned / stale)."""
    set_parts = []
    params: list = [borrowing_id, user_id, updated_at]
    for field, value in fields.items():
        if field not in _PATCHABLE:
            raise ValueError(f"not a patchable column: {field}")
        params.append(value)
        set_parts.append(f"{field} = ${len(params)}")
    set_clause = ", ".join(set_parts)
    return await pool.fetchrow(
        f"""
        UPDATE borrowings
        SET {set_clause}, updated_at = $3, server_seq = nextval('sync_seq')
        WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL AND updated_at < $3
        RETURNING {BORROWING_COLUMNS}
        """,
        *params,
    )


async def tombstone_borrowing(
    pool: asyncpg.Pool, user_id: uuid.UUID, borrowing_id: uuid.UUID
) -> str | None:
    """Soft delete. Returns "deleted" | "already" | None (absent/foreign)."""
    row = await pool.fetchrow(
        """
        UPDATE borrowings
        SET deleted_at = now(), server_seq = nextval('sync_seq')
        WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL
        RETURNING id
        """,
        borrowing_id, user_id,
    )
    if row is not None:
        return "deleted"
    ghost = await get_borrowing(pool, user_id, borrowing_id, include_deleted=True)
    if ghost is not None:
        return "already"
    return None
