"""Dependencies shared across features (graduated from auth when the second
consumer — borrowings — arrived)."""

import uuid

import asyncpg
from fastapi import Depends, Header, Request

from app.core.config import Settings, get_settings
from app.core.errors import ForbiddenError, InvalidTokenError
from app.core.security import decode_access_token


def get_pool(request: Request) -> asyncpg.Pool:
    return request.app.state.pool


async def get_current_user_id(
    authorization: str = Header(default=""),
    settings: Settings = Depends(get_settings),
) -> uuid.UUID:
    """Parse `Authorization: Bearer <jwt>` and return the caller's user id."""
    scheme, _, token = authorization.partition(" ")
    if scheme.lower() != "bearer" or token == "":
        raise InvalidTokenError("Missing bearer token")
    return decode_access_token(token, settings.jwt_secret)


async def get_current_admin_id(
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> uuid.UUID:
    """Same bearer token, but the caller must have users.is_admin = true.

    Used only by the catalog write endpoints — a valid login is not enough to
    edit the global catalog; you must be an admin (403 otherwise)."""
    is_admin = await pool.fetchval(
        "SELECT is_admin FROM users WHERE id = $1", user_id
    )
    if not is_admin:
        raise ForbiddenError("Admin privileges required")
    return user_id
