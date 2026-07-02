"""Postgres connection pool lifecycle (asyncpg).

Opening a new DB connection per request is slow. Instead we keep a *pool* of open
connections for the app's lifetime, created on startup and closed on shutdown, and
borrow one per query. The pool is stored on FastAPI's `app.state` so routes can reach
it via the app instance (no global mutable singleton).
"""

from __future__ import annotations

import asyncpg

from app.core.logging import get_logger

log = get_logger(__name__)


async def create_pool(database_url: str) -> asyncpg.Pool:
    log.info("db.pool.creating")
    pool = await asyncpg.create_pool(dsn=database_url, min_size=1, max_size=10)
    log.info("db.pool.created")
    return pool


async def close_pool(pool: asyncpg.Pool) -> None:
    await pool.close()
    log.info("db.pool.closed")


async def ping(pool: asyncpg.Pool) -> bool:
    """Cheap 'is the database reachable?' check for the readiness probe."""
    async with pool.acquire() as conn:
        return await conn.fetchval("SELECT 1") == 1
