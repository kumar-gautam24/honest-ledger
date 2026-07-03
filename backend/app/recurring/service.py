"""Recurring item rules: replay-safe create, LWW patch, tombstone delete."""

import uuid
from datetime import datetime, timezone

import asyncpg

from app.recurring import repository
from app.recurring.schemas import RecurringCreate, RecurringPatch, RecurringResponse
from app.core.errors import IdConflictError, NotFoundError, StaleUpdateError


def row_to_response(row: asyncpg.Record) -> RecurringResponse:
    return RecurringResponse.model_validate(dict(row))


async def create_recurring(
    pool: asyncpg.Pool, user_id: uuid.UUID, body: RecurringCreate
) -> tuple[asyncpg.Record, bool]:
    """Returns (row, created). created=False means this was a replay."""
    now = datetime.now(timezone.utc)
    data = body.model_dump()
    if data["created_at"] is None:
        data["created_at"] = now
    if data["updated_at"] is None:
        data["updated_at"] = now

    row = await repository.insert_recurring(pool, user_id, data)
    if row is not None:
        return row, True

    existing = await repository.get_recurring(
        pool, user_id, body.id, include_deleted=True
    )
    if existing is not None:
        return existing, False
    raise IdConflictError("A record with this id already exists")


async def get_recurring_or_404(
    pool: asyncpg.Pool, user_id: uuid.UUID, recurring_id: uuid.UUID
) -> asyncpg.Record:
    row = await repository.get_recurring(pool, user_id, recurring_id)
    if row is None:
        raise NotFoundError("Recurring item not found")
    return row


async def list_recurring(
    pool: asyncpg.Pool, user_id: uuid.UUID, cursor: int, limit: int
) -> tuple[list[asyncpg.Record], int, bool]:
    rows = await repository.list_recurring(pool, user_id, cursor, limit + 1)
    has_more = len(rows) > limit
    rows = rows[:limit]
    if rows:
        next_cursor = rows[-1]["server_seq"]
    else:
        next_cursor = cursor
    return rows, next_cursor, has_more


async def patch_recurring(
    pool: asyncpg.Pool, user_id: uuid.UUID, recurring_id: uuid.UUID, body: RecurringPatch
) -> asyncpg.Record:
    fields = body.model_dump(exclude_unset=True)
    fields.pop("updated_at")
    if not fields:
        return await get_recurring_or_404(pool, user_id, recurring_id)

    row = await repository.update_recurring(
        pool, user_id, recurring_id, body.updated_at, fields
    )
    if row is not None:
        return row

    existing = await repository.get_recurring(pool, user_id, recurring_id)
    if existing is None:
        raise NotFoundError("Recurring item not found")
    raise StaleUpdateError(
        "A newer version of this record exists",
        details={"current": row_to_response(existing).model_dump(mode="json")},
    )


async def delete_recurring(
    pool: asyncpg.Pool, user_id: uuid.UUID, recurring_id: uuid.UUID
) -> None:
    outcome = await repository.tombstone_recurring(pool, user_id, recurring_id)
    if outcome is None:
        raise NotFoundError("Recurring item not found")
