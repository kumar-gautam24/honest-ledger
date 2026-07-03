"""Lenders SQL. Same shape and safety rules as the borrowings repository, but the
id is a client string (built-in slug or custom id), so helpers take `str`.

Dynamic SET is built ONLY from the _PATCHABLE whitelist; values are always bind
parameters. That is what keeps the dynamic UPDATE injection-safe.
"""

import uuid
from datetime import datetime

import asyncpg

LENDER_COLUMNS = """
    id, user_id, name, type, issuer, network, typical_rate_pct, rate_type,
    fee_type, fee_value, fee_cap, is_mine, notes,
    created_at, updated_at, deleted_at, server_seq
"""

_PATCHABLE = {
    "name", "type", "issuer", "network", "typical_rate_pct", "rate_type",
    "fee_type", "fee_value", "fee_cap", "is_mine", "notes",
}


async def insert_lender(
    pool: asyncpg.Pool, user_id: uuid.UUID, data: dict
) -> asyncpg.Record | None:
    """Idempotent create: on id conflict returns None (caller decides replay vs
    collision)."""
    return await pool.fetchrow(
        f"""
        INSERT INTO lenders (
            id, user_id, name, type, issuer, network, typical_rate_pct,
            rate_type, fee_type, fee_value, fee_cap, is_mine, notes,
            created_at, updated_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10,
                $11, $12, $13, $14, $15)
        ON CONFLICT (id) DO NOTHING
        RETURNING {LENDER_COLUMNS}
        """,
        data["id"], user_id, data["name"], data["type"], data["issuer"],
        data["network"], data["typical_rate_pct"], data["rate_type"],
        data["fee_type"], data["fee_value"], data["fee_cap"], data["is_mine"],
        data["notes"], data["created_at"], data["updated_at"],
    )


async def get_lender(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    lender_id: str,
    include_deleted: bool = False,
) -> asyncpg.Record | None:
    if include_deleted:
        tombstone_filter = ""
    else:
        tombstone_filter = "AND deleted_at IS NULL"
    return await pool.fetchrow(
        f"""
        SELECT {LENDER_COLUMNS} FROM lenders
        WHERE id = $1 AND user_id = $2 {tombstone_filter}
        """,
        lender_id, user_id,
    )


async def list_lenders(
    pool: asyncpg.Pool, user_id: uuid.UUID, cursor: int, limit: int
) -> list[asyncpg.Record]:
    return await pool.fetch(
        f"""
        SELECT {LENDER_COLUMNS} FROM lenders
        WHERE user_id = $1 AND deleted_at IS NULL AND server_seq > $2
        ORDER BY server_seq
        LIMIT $3
        """,
        user_id, cursor, limit,
    )


async def update_lender(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    lender_id: str,
    updated_at: datetime,
    fields: dict,
) -> asyncpg.Record | None:
    """Atomic last-write-wins: matches only when the edit is NEWER and the row is
    alive. Returns the updated row, or None (absent / foreign / tombstoned / stale)."""
    set_parts = []
    params: list = [lender_id, user_id, updated_at]
    for field, value in fields.items():
        if field not in _PATCHABLE:
            raise ValueError(f"not a patchable column: {field}")
        params.append(value)
        set_parts.append(f"{field} = ${len(params)}")
    set_clause = ", ".join(set_parts)
    return await pool.fetchrow(
        f"""
        UPDATE lenders
        SET {set_clause}, updated_at = $3, server_seq = nextval('sync_seq')
        WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL AND updated_at < $3
        RETURNING {LENDER_COLUMNS}
        """,
        *params,
    )


async def tombstone_lender(
    pool: asyncpg.Pool, user_id: uuid.UUID, lender_id: str
) -> str | None:
    """Soft delete. Returns "deleted" | "already" | None (absent/foreign)."""
    row = await pool.fetchrow(
        """
        UPDATE lenders
        SET deleted_at = now(), server_seq = nextval('sync_seq')
        WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL
        RETURNING id
        """,
        lender_id, user_id,
    )
    if row is not None:
        return "deleted"
    ghost = await get_lender(pool, user_id, lender_id, include_deleted=True)
    if ghost is not None:
        return "already"
    return None
