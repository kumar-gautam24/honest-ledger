"""Borrowing business rules: replay-safe create, LWW patch, tombstone delete."""

import uuid
from datetime import datetime, timezone

import asyncpg

from app.borrowings import repayments_repository, repository
from app.borrowings.schemas import (
    BorrowingCreate,
    BorrowingPatch,
    BorrowingResponse,
    RepaymentCreate,
    RepaymentPatch,
    RepaymentResponse,
)
from app.core.errors import IdConflictError, NotFoundError, StaleUpdateError


def row_to_response(row: asyncpg.Record) -> BorrowingResponse:
    return BorrowingResponse.model_validate(dict(row))


async def create_borrowing(
    pool: asyncpg.Pool, user_id: uuid.UUID, body: BorrowingCreate
) -> tuple[asyncpg.Record, bool]:
    """Returns (row, created). created=False means this was a replay."""
    now = datetime.now(timezone.utc)
    data = body.model_dump()
    if data["created_at"] is None:
        data["created_at"] = now
    if data["updated_at"] is None:
        data["updated_at"] = now

    row = await repository.insert_borrowing(pool, user_id, data)
    if row is not None:
        return row, True

    # id already exists. Mine -> replay (fine). Not mine -> conflict, and we
    # reveal nothing about the other row.
    existing = await repository.get_borrowing(
        pool, user_id, body.id, include_deleted=True
    )
    if existing is not None:
        return existing, False
    raise IdConflictError("A record with this id already exists")


async def get_borrowing_or_404(
    pool: asyncpg.Pool, user_id: uuid.UUID, borrowing_id: uuid.UUID
) -> asyncpg.Record:
    row = await repository.get_borrowing(pool, user_id, borrowing_id)
    if row is None:
        raise NotFoundError("Borrowing not found")
    return row


async def list_borrowings(
    pool: asyncpg.Pool, user_id: uuid.UUID, cursor: int, limit: int
) -> tuple[list[asyncpg.Record], int, bool]:
    # Fetch one extra row: if it exists there is another page.
    rows = await repository.list_borrowings(pool, user_id, cursor, limit + 1)
    has_more = len(rows) > limit
    rows = rows[:limit]
    if rows:
        next_cursor = rows[-1]["server_seq"]
    else:
        next_cursor = cursor
    return rows, next_cursor, has_more


async def patch_borrowing(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    borrowing_id: uuid.UUID,
    body: BorrowingPatch,
) -> asyncpg.Record:
    fields = body.model_dump(exclude_unset=True)
    fields.pop("updated_at")
    if not fields:
        return await get_borrowing_or_404(pool, user_id, borrowing_id)

    row = await repository.update_borrowing(
        pool, user_id, borrowing_id, body.updated_at, fields
    )
    if row is not None:
        return row

    # Update matched nothing: distinguish "doesn't exist / not yours /
    # tombstoned" (404) from "exists but your edit is older" (409 + current).
    existing = await repository.get_borrowing(pool, user_id, borrowing_id)
    if existing is None:
        raise NotFoundError("Borrowing not found")
    raise StaleUpdateError(
        "A newer version of this record exists",
        details={"current": row_to_response(existing).model_dump(mode="json")},
    )


async def delete_borrowing(
    pool: asyncpg.Pool, user_id: uuid.UUID, borrowing_id: uuid.UUID
) -> None:
    outcome = await repository.tombstone_borrowing(pool, user_id, borrowing_id)
    if outcome is None:
        raise NotFoundError("Borrowing not found")
    # "deleted" and "already" both end as 204: deletes are idempotent.


def repayment_to_response(row: asyncpg.Record) -> RepaymentResponse:
    return RepaymentResponse.model_validate(dict(row))


async def create_repayment(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    borrowing_id: uuid.UUID,
    body: RepaymentCreate,
) -> tuple[asyncpg.Record, bool]:
    # Parent must be mine and alive; otherwise the repayment path 404s.
    await get_borrowing_or_404(pool, user_id, borrowing_id)

    now = datetime.now(timezone.utc)
    data = body.model_dump()
    if data["created_at"] is None:
        data["created_at"] = now
    if data["updated_at"] is None:
        data["updated_at"] = now

    row = await repayments_repository.insert_repayment(
        pool, user_id, borrowing_id, data
    )
    if row is not None:
        return row, True
    existing = await repayments_repository.get_repayment(
        pool, user_id, body.id, include_deleted=True
    )
    if existing is not None:
        return existing, False
    raise IdConflictError("A record with this id already exists")


async def list_repayments_for(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    borrowing_id: uuid.UUID,
    cursor: int,
    limit: int,
) -> tuple[list[asyncpg.Record], int, bool]:
    await get_borrowing_or_404(pool, user_id, borrowing_id)
    rows = await repayments_repository.list_repayments(
        pool, user_id, borrowing_id, cursor, limit + 1
    )
    has_more = len(rows) > limit
    rows = rows[:limit]
    if rows:
        next_cursor = rows[-1]["server_seq"]
    else:
        next_cursor = cursor
    return rows, next_cursor, has_more


async def patch_repayment(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    repayment_id: uuid.UUID,
    body: RepaymentPatch,
) -> asyncpg.Record:
    fields = body.model_dump(exclude_unset=True)
    fields.pop("updated_at")
    if not fields:
        row = await repayments_repository.get_repayment(pool, user_id, repayment_id)
        if row is None:
            raise NotFoundError("Repayment not found")
        return row

    row = await repayments_repository.update_repayment(
        pool, user_id, repayment_id, body.updated_at, fields
    )
    if row is not None:
        return row
    existing = await repayments_repository.get_repayment(pool, user_id, repayment_id)
    if existing is None:
        raise NotFoundError("Repayment not found")
    raise StaleUpdateError(
        "A newer version of this record exists",
        details={"current": repayment_to_response(existing).model_dump(mode="json")},
    )


async def delete_repayment(
    pool: asyncpg.Pool, user_id: uuid.UUID, repayment_id: uuid.UUID
) -> None:
    outcome = await repayments_repository.tombstone_repayment(
        pool, user_id, repayment_id
    )
    if outcome is None:
        raise NotFoundError("Repayment not found")
