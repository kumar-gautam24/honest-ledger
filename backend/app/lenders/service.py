"""Lender business rules: replay-safe create, LWW patch, tombstone delete."""

import uuid
from datetime import datetime, timezone

import asyncpg

from app.lenders import repository
from app.lenders.schemas import LenderCreate, LenderPatch, LenderResponse
from app.core.errors import IdConflictError, NotFoundError, StaleUpdateError


def row_to_response(row: asyncpg.Record) -> LenderResponse:
    return LenderResponse.model_validate(dict(row))


async def create_lender(
    pool: asyncpg.Pool, user_id: uuid.UUID, body: LenderCreate
) -> tuple[asyncpg.Record, bool]:
    """Returns (row, created). created=False means this was a replay."""
    now = datetime.now(timezone.utc)
    data = body.model_dump()
    if data["created_at"] is None:
        data["created_at"] = now
    if data["updated_at"] is None:
        data["updated_at"] = now

    row = await repository.insert_lender(pool, user_id, data)
    if row is not None:
        return row, True

    # id already exists. Mine -> replay. Not mine -> conflict, reveal nothing.
    existing = await repository.get_lender(pool, user_id, body.id, include_deleted=True)
    if existing is not None:
        return existing, False
    raise IdConflictError("A record with this id already exists")


async def get_lender_or_404(
    pool: asyncpg.Pool, user_id: uuid.UUID, lender_id: str
) -> asyncpg.Record:
    row = await repository.get_lender(pool, user_id, lender_id)
    if row is None:
        raise NotFoundError("Lender not found")
    return row


async def list_lenders(
    pool: asyncpg.Pool, user_id: uuid.UUID, cursor: int, limit: int
) -> tuple[list[asyncpg.Record], int, bool]:
    rows = await repository.list_lenders(pool, user_id, cursor, limit + 1)
    has_more = len(rows) > limit
    rows = rows[:limit]
    if rows:
        next_cursor = rows[-1]["server_seq"]
    else:
        next_cursor = cursor
    return rows, next_cursor, has_more


async def patch_lender(
    pool: asyncpg.Pool, user_id: uuid.UUID, lender_id: str, body: LenderPatch
) -> asyncpg.Record:
    fields = body.model_dump(exclude_unset=True)
    fields.pop("updated_at")
    if not fields:
        return await get_lender_or_404(pool, user_id, lender_id)

    row = await repository.update_lender(
        pool, user_id, lender_id, body.updated_at, fields
    )
    if row is not None:
        return row

    existing = await repository.get_lender(pool, user_id, lender_id)
    if existing is None:
        raise NotFoundError("Lender not found")
    raise StaleUpdateError(
        "A newer version of this record exists",
        details={"current": row_to_response(existing).model_dump(mode="json")},
    )


async def delete_lender(
    pool: asyncpg.Pool, user_id: uuid.UUID, lender_id: str
) -> None:
    outcome = await repository.tombstone_lender(pool, user_id, lender_id)
    if outcome is None:
        raise NotFoundError("Lender not found")
    # "deleted" and "already" both end as 204: deletes are idempotent.
