"""Repository = the only layer that touches SQL. Tested against real Postgres."""

from datetime import datetime, timedelta, timezone

import asyncpg
import pytest

from app.auth import repository


async def test_create_and_get_user(pool):
    created = await repository.create_user(pool, "gautam@example.com", "fake-hash")
    assert created["email"] == "gautam@example.com"

    by_email = await repository.get_user_by_email(pool, "GAUTAM@EXAMPLE.COM")
    assert by_email is not None            # citext: lookup is case-insensitive
    assert by_email["id"] == created["id"]
    assert by_email["password_hash"] == "fake-hash"

    by_id = await repository.get_user_by_id(pool, created["id"])
    assert by_id["email"] == "gautam@example.com"


async def test_duplicate_email_raises_unique_violation(pool):
    await repository.create_user(pool, "dup@example.com", "h")
    with pytest.raises(asyncpg.UniqueViolationError):
        await repository.create_user(pool, "DUP@example.com", "h2")


async def test_get_missing_user_returns_none(pool):
    assert await repository.get_user_by_email(pool, "ghost@example.com") is None


async def test_refresh_token_lifecycle(pool):
    user = await repository.create_user(pool, "t@example.com", "h")
    expires = datetime.now(timezone.utc) + timedelta(days=30)

    await repository.insert_refresh_token(pool, user["id"], "hash-1", expires)
    row = await repository.get_refresh_token_by_hash(pool, "hash-1")
    assert row["user_id"] == user["id"]
    assert row["revoked_at"] is None

    await repository.revoke_refresh_token(pool, row["id"])
    row = await repository.get_refresh_token_by_hash(pool, "hash-1")
    assert row["revoked_at"] is not None


async def test_revoke_all_and_cascade_delete(pool):
    user = await repository.create_user(pool, "many@example.com", "h")
    expires = datetime.now(timezone.utc) + timedelta(days=30)
    await repository.insert_refresh_token(pool, user["id"], "hash-a", expires)
    await repository.insert_refresh_token(pool, user["id"], "hash-b", expires)

    await repository.revoke_all_refresh_tokens_for_user(pool, user["id"])
    for token_hash in ["hash-a", "hash-b"]:
        row = await repository.get_refresh_token_by_hash(pool, token_hash)
        assert row["revoked_at"] is not None

    await repository.delete_user(pool, user["id"])
    # ON DELETE CASCADE: the user's tokens are gone with the user.
    assert await repository.get_refresh_token_by_hash(pool, "hash-a") is None


async def test_update_password_hash(pool):
    user = await repository.create_user(pool, "pw@example.com", "old-hash")
    await repository.update_password_hash(pool, user["id"], "new-hash")
    row = await repository.get_user_by_id(pool, user["id"])
    assert row["password_hash"] == "new-hash"
