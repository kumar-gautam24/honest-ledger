"""FastAPI dependencies shared by auth routes."""

import uuid

import asyncpg
from fastapi import Depends, Header, Request

from app.core.config import Settings, get_settings
from app.core.errors import InvalidTokenError
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
