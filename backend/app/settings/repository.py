"""User-settings SQL. Identity is (user_id, key), not a client UUID. `value` is jsonb,
so it is json.dumps'd on the way in ($N::jsonb) and comes back as a JSON string the
service decodes. LWW is enforced in the upsert's ON CONFLICT ... WHERE clause.
"""

import json
import uuid
from datetime import datetime

import asyncpg

SETTING_COLUMNS = "key, value, updated_at, deleted_at, server_seq"


async def list_settings(
    pool: asyncpg.Pool, user_id: uuid.UUID
) -> list[asyncpg.Record]:
    return await pool.fetch(
        f"""
        SELECT {SETTING_COLUMNS} FROM user_settings
        WHERE user_id = $1 AND deleted_at IS NULL
        ORDER BY key
        """,
        user_id,
    )


async def get_setting(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    key: str,
    include_deleted: bool = False,
) -> asyncpg.Record | None:
    if include_deleted:
        tombstone_filter = ""
    else:
        tombstone_filter = "AND deleted_at IS NULL"
    return await pool.fetchrow(
        f"""
        SELECT {SETTING_COLUMNS} FROM user_settings
        WHERE user_id = $1 AND key = $2 {tombstone_filter}
        """,
        user_id, key,
    )


async def upsert_setting(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    key: str,
    value,
    updated_at: datetime,
) -> asyncpg.Record:
    """LWW upsert: writes only when the incoming stamp is newer (or the row is new).
    A stale write is a no-op that returns the current winning row, so the client can
    reconcile to the server's value."""
    row = await pool.fetchrow(
        f"""
        INSERT INTO user_settings (user_id, key, value, updated_at)
        VALUES ($1, $2, $3::jsonb, $4)
        ON CONFLICT (user_id, key) DO UPDATE SET
            value = EXCLUDED.value, updated_at = EXCLUDED.updated_at,
            deleted_at = NULL, server_seq = nextval('sync_seq')
        WHERE user_settings.updated_at < EXCLUDED.updated_at
        RETURNING {SETTING_COLUMNS}
        """,
        user_id, key, json.dumps(value), updated_at,
    )
    if row is not None:
        return row
    # Stale or equal stamp: no write happened; hand back the current row.
    return await get_setting(pool, user_id, key, include_deleted=True)


async def tombstone_setting(
    pool: asyncpg.Pool, user_id: uuid.UUID, key: str
) -> str | None:
    row = await pool.fetchrow(
        """
        UPDATE user_settings
        SET deleted_at = now(), server_seq = nextval('sync_seq')
        WHERE user_id = $1 AND key = $2 AND deleted_at IS NULL
        RETURNING key
        """,
        user_id, key,
    )
    if row is not None:
        return "deleted"
    ghost = await get_setting(pool, user_id, key, include_deleted=True)
    if ghost is not None:
        return "already"
    return None
