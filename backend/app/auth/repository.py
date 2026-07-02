"""Auth SQL. The ONLY file in the auth feature that touches the database.

Every query is parameterized ($1, $2 ...) — never build SQL with f-strings;
that is how SQL injection happens.
"""

import uuid
from datetime import datetime

import asyncpg


async def create_user(
    pool: asyncpg.Pool, email: str, password_hash: str
) -> asyncpg.Record:
    return await pool.fetchrow(
        """
        INSERT INTO users (email, password_hash)
        VALUES ($1, $2)
        RETURNING id, email, created_at
        """,
        email,
        password_hash,
    )


async def get_user_by_email(pool: asyncpg.Pool, email: str) -> asyncpg.Record | None:
    return await pool.fetchrow(
        "SELECT id, email, password_hash, created_at FROM users WHERE email = $1",
        email,
    )


async def get_user_by_id(
    pool: asyncpg.Pool, user_id: uuid.UUID
) -> asyncpg.Record | None:
    return await pool.fetchrow(
        "SELECT id, email, password_hash, created_at FROM users WHERE id = $1",
        user_id,
    )


async def insert_refresh_token(
    pool: asyncpg.Pool, user_id: uuid.UUID, token_hash: str, expires_at: datetime
) -> None:
    await pool.execute(
        """
        INSERT INTO refresh_tokens (user_id, token_hash, expires_at)
        VALUES ($1, $2, $3)
        """,
        user_id,
        token_hash,
        expires_at,
    )


async def get_refresh_token_by_hash(
    pool: asyncpg.Pool, token_hash: str
) -> asyncpg.Record | None:
    return await pool.fetchrow(
        """
        SELECT id, user_id, token_hash, expires_at, revoked_at
        FROM refresh_tokens
        WHERE token_hash = $1
        """,
        token_hash,
    )


async def revoke_refresh_token(pool: asyncpg.Pool, token_id: uuid.UUID) -> None:
    await pool.execute(
        "UPDATE refresh_tokens SET revoked_at = now() WHERE id = $1", token_id
    )


async def revoke_all_refresh_tokens_for_user(
    pool: asyncpg.Pool, user_id: uuid.UUID
) -> None:
    await pool.execute(
        """
        UPDATE refresh_tokens SET revoked_at = now()
        WHERE user_id = $1 AND revoked_at IS NULL
        """,
        user_id,
    )


async def update_password_hash(
    pool: asyncpg.Pool, user_id: uuid.UUID, password_hash: str
) -> None:
    await pool.execute(
        "UPDATE users SET password_hash = $2, updated_at = now() WHERE id = $1",
        user_id,
        password_hash,
    )


async def delete_user(pool: asyncpg.Pool, user_id: uuid.UUID) -> None:
    await pool.execute("DELETE FROM users WHERE id = $1", user_id)
