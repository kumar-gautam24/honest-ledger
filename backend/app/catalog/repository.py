"""Catalog SQL. Global (no user_id). Every write bumps `version` from catalog_seq
so clients can cheaply detect "did the catalog change?".

Dynamic SET on PATCH is built ONLY from the _PATCHABLE whitelist; values are always
bind parameters — that keeps the dynamic UPDATE injection-safe.
"""

import asyncpg

CATALOG_COLUMNS = """
    id, name, type, issuer, network, typical_rate_pct, rate_type,
    fee_type, fee_value, fee_cap, notes, is_active, sort_order, updated_at, version
"""

_PATCHABLE = {
    "name", "type", "issuer", "network", "typical_rate_pct", "rate_type",
    "fee_type", "fee_value", "fee_cap", "notes", "is_active", "sort_order",
}


async def get_version(pool: asyncpg.Pool) -> int:
    """Current catalog version = highest row version, or 0 when empty."""
    value = await pool.fetchval("SELECT COALESCE(MAX(version), 0) FROM catalog_lenders")
    return value


async def list_active(pool: asyncpg.Pool) -> list[asyncpg.Record]:
    """Public view: active, non-tombstoned rows in display order."""
    return await pool.fetch(
        f"""
        SELECT {CATALOG_COLUMNS} FROM catalog_lenders
        WHERE deleted_at IS NULL AND is_active = true
        ORDER BY sort_order, name
        """
    )


async def get_lender(pool: asyncpg.Pool, lender_id: str) -> asyncpg.Record | None:
    # deleted_at included for internal tombstone checks; the response model ignores it.
    return await pool.fetchrow(
        f"SELECT {CATALOG_COLUMNS}, deleted_at FROM catalog_lenders WHERE id = $1",
        lender_id,
    )


async def upsert_lender(pool: asyncpg.Pool, data: dict) -> asyncpg.Record:
    """Admin create-or-replace by id. Un-tombstones on re-add; always bumps version."""
    return await pool.fetchrow(
        f"""
        INSERT INTO catalog_lenders (
            id, name, type, issuer, network, typical_rate_pct, rate_type,
            fee_type, fee_value, fee_cap, notes, is_active, sort_order
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
        ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name, type = EXCLUDED.type, issuer = EXCLUDED.issuer,
            network = EXCLUDED.network, typical_rate_pct = EXCLUDED.typical_rate_pct,
            rate_type = EXCLUDED.rate_type, fee_type = EXCLUDED.fee_type,
            fee_value = EXCLUDED.fee_value, fee_cap = EXCLUDED.fee_cap,
            notes = EXCLUDED.notes, is_active = EXCLUDED.is_active,
            sort_order = EXCLUDED.sort_order, deleted_at = NULL,
            updated_at = now(), version = nextval('catalog_seq')
        RETURNING {CATALOG_COLUMNS}
        """,
        data["id"], data["name"], data["type"], data["issuer"], data["network"],
        data["typical_rate_pct"], data["rate_type"], data["fee_type"],
        data["fee_value"], data["fee_cap"], data["notes"], data["is_active"],
        data["sort_order"],
    )


async def update_lender(
    pool: asyncpg.Pool, lender_id: str, fields: dict
) -> asyncpg.Record | None:
    set_parts = []
    params: list = [lender_id]
    for field, value in fields.items():
        if field not in _PATCHABLE:
            raise ValueError(f"not a patchable column: {field}")
        params.append(value)
        set_parts.append(f"{field} = ${len(params)}")
    set_clause = ", ".join(set_parts)
    return await pool.fetchrow(
        f"""
        UPDATE catalog_lenders
        SET {set_clause}, updated_at = now(), version = nextval('catalog_seq')
        WHERE id = $1 AND deleted_at IS NULL
        RETURNING {CATALOG_COLUMNS}
        """,
        *params,
    )


async def tombstone_lender(pool: asyncpg.Pool, lender_id: str) -> str | None:
    """Soft delete so clients drop it. Returns "deleted" | "already" | None."""
    row = await pool.fetchrow(
        """
        UPDATE catalog_lenders
        SET deleted_at = now(), version = nextval('catalog_seq')
        WHERE id = $1 AND deleted_at IS NULL
        RETURNING id
        """,
        lender_id,
    )
    if row is not None:
        return "deleted"
    ghost = await get_lender(pool, lender_id)
    if ghost is not None:
        return "already"
    return None
