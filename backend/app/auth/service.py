"""Auth business rules. Knows nothing about HTTP; SQL only via repository."""

import uuid
from datetime import datetime, timedelta, timezone

import asyncpg

from app.auth import repository
from app.core.config import Settings
from app.core.errors import EmailTakenError, InvalidCredentialsError
from app.core.security import (
    create_access_token,
    hash_password,
    new_refresh_token,
    verify_password,
)

# Verified when the email doesn't exist, so unknown-email and wrong-password
# take the same time. Otherwise response timing leaks which emails have accounts.
_DUMMY_PASSWORD_HASH = hash_password("timing-equalizer-dummy")


async def register(pool: asyncpg.Pool, email: str, password: str) -> asyncpg.Record:
    try:
        return await repository.create_user(pool, email, hash_password(password))
    except asyncpg.UniqueViolationError:
        # Let the DB's unique index be the referee: checking first then inserting
        # would race against a concurrent register with the same email.
        raise EmailTakenError("An account with this email already exists")


async def login(
    pool: asyncpg.Pool, settings: Settings, email: str, password: str
) -> tuple[str, str]:
    user = await repository.get_user_by_email(pool, email)
    if user is None:
        verify_password(password, _DUMMY_PASSWORD_HASH)
        raise InvalidCredentialsError("Email or password is incorrect")
    if not verify_password(password, user["password_hash"]):
        raise InvalidCredentialsError("Email or password is incorrect")
    return await _issue_token_pair(pool, settings, user["id"])


async def _issue_token_pair(
    pool: asyncpg.Pool, settings: Settings, user_id: uuid.UUID
) -> tuple[str, str]:
    access = create_access_token(
        user_id, settings.jwt_secret, settings.access_token_ttl_minutes
    )
    raw_refresh, refresh_hash = new_refresh_token()
    expires_at = datetime.now(timezone.utc) + timedelta(
        days=settings.refresh_token_ttl_days
    )
    await repository.insert_refresh_token(pool, user_id, refresh_hash, expires_at)
    return access, raw_refresh
