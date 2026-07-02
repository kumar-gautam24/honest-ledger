"""Auth business rules. Knows nothing about HTTP; SQL only via repository."""

import uuid
from datetime import datetime, timedelta, timezone

import asyncpg

from app.auth import repository
from app.core.config import Settings
from app.core.errors import (
    EmailTakenError,
    InvalidCredentialsError,
    InvalidTokenError,
)
from app.core.security import (
    create_access_token,
    hash_password,
    hash_refresh_token,
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


async def refresh(
    pool: asyncpg.Pool, settings: Settings, raw_refresh_token: str
) -> tuple[str, str]:
    row = await repository.get_refresh_token_by_hash(
        pool, hash_refresh_token(raw_refresh_token)
    )
    if row is None:
        raise InvalidTokenError("Refresh token is invalid")
    if row["revoked_at"] is not None:
        # This token was already used or logged out. Someone is REPLAYING it —
        # possibly a thief. Nuke every session for this user; both parties must
        # log in again. This is standard refresh-token reuse detection.
        await repository.revoke_all_refresh_tokens_for_user(pool, row["user_id"])
        raise InvalidTokenError("Refresh token has been revoked")
    if row["expires_at"] <= datetime.now(timezone.utc):
        raise InvalidTokenError("Refresh token has expired")

    # Rotation: each refresh token works exactly once.
    await repository.revoke_refresh_token(pool, row["id"])
    return await _issue_token_pair(pool, settings, row["user_id"])


async def logout(pool: asyncpg.Pool, raw_refresh_token: str) -> None:
    row = await repository.get_refresh_token_by_hash(
        pool, hash_refresh_token(raw_refresh_token)
    )
    if row is not None and row["revoked_at"] is None:
        await repository.revoke_refresh_token(pool, row["id"])
    # Unknown/already-revoked tokens return success too: logout is idempotent,
    # and errors here would only help attackers probe which tokens exist.


async def change_password(
    pool: asyncpg.Pool, user_id: uuid.UUID, current_password: str, new_password: str
) -> None:
    user = await repository.get_user_by_id(pool, user_id)
    if user is None:
        raise InvalidCredentialsError("Current password is incorrect")
    if not verify_password(current_password, user["password_hash"]):
        raise InvalidCredentialsError("Current password is incorrect")
    await repository.update_password_hash(pool, user_id, hash_password(new_password))
    # Changing the password means "secure my account": revoke every session.
    await repository.revoke_all_refresh_tokens_for_user(pool, user_id)


async def delete_account(pool: asyncpg.Pool, user_id: uuid.UUID) -> None:
    # ON DELETE CASCADE removes the user's refresh tokens with the row.
    # B2 domain tables must make the same choice explicitly.
    await repository.delete_user(pool, user_id)
