"""Card + statement rules: replay-safe create, LWW patch, tombstone delete.

Statements are children of a card, exactly like repayments under a borrowing: the
parent card must be mine and alive, or the statement path 404s.
"""

import uuid
from datetime import datetime, timezone

import asyncpg

from app.cards import repository, statements_repository
from app.cards.schemas import (
    CardCreate,
    CardPatch,
    CardResponse,
    StatementCreate,
    StatementPatch,
    StatementResponse,
)
from app.core.errors import IdConflictError, NotFoundError, StaleUpdateError


def row_to_response(row: asyncpg.Record) -> CardResponse:
    return CardResponse.model_validate(dict(row))


async def create_card(
    pool: asyncpg.Pool, user_id: uuid.UUID, body: CardCreate
) -> tuple[asyncpg.Record, bool]:
    """Returns (row, created). created=False means this was a replay."""
    now = datetime.now(timezone.utc)
    data = body.model_dump()
    if data["created_at"] is None:
        data["created_at"] = now
    if data["updated_at"] is None:
        data["updated_at"] = now

    row = await repository.insert_card(pool, user_id, data)
    if row is not None:
        return row, True

    existing = await repository.get_card(pool, user_id, body.id, include_deleted=True)
    if existing is not None:
        return existing, False
    raise IdConflictError("A record with this id already exists")


async def get_card_or_404(
    pool: asyncpg.Pool, user_id: uuid.UUID, card_id: uuid.UUID
) -> asyncpg.Record:
    row = await repository.get_card(pool, user_id, card_id)
    if row is None:
        raise NotFoundError("Card not found")
    return row


async def list_cards(
    pool: asyncpg.Pool, user_id: uuid.UUID, cursor: int, limit: int
) -> tuple[list[asyncpg.Record], int, bool]:
    rows = await repository.list_cards(pool, user_id, cursor, limit + 1)
    has_more = len(rows) > limit
    rows = rows[:limit]
    if rows:
        next_cursor = rows[-1]["server_seq"]
    else:
        next_cursor = cursor
    return rows, next_cursor, has_more


async def patch_card(
    pool: asyncpg.Pool, user_id: uuid.UUID, card_id: uuid.UUID, body: CardPatch
) -> asyncpg.Record:
    fields = body.model_dump(exclude_unset=True)
    fields.pop("updated_at")
    if not fields:
        return await get_card_or_404(pool, user_id, card_id)

    row = await repository.update_card(pool, user_id, card_id, body.updated_at, fields)
    if row is not None:
        return row

    existing = await repository.get_card(pool, user_id, card_id)
    if existing is None:
        raise NotFoundError("Card not found")
    raise StaleUpdateError(
        "A newer version of this record exists",
        details={"current": row_to_response(existing).model_dump(mode="json")},
    )


async def delete_card(
    pool: asyncpg.Pool, user_id: uuid.UUID, card_id: uuid.UUID
) -> None:
    outcome = await repository.tombstone_card(pool, user_id, card_id)
    if outcome is None:
        raise NotFoundError("Card not found")


def statement_to_response(row: asyncpg.Record) -> StatementResponse:
    return StatementResponse.model_validate(dict(row))


async def create_statement(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    card_id: uuid.UUID,
    body: StatementCreate,
) -> tuple[asyncpg.Record, bool]:
    # Parent must be mine and alive; otherwise the statement path 404s.
    await get_card_or_404(pool, user_id, card_id)

    now = datetime.now(timezone.utc)
    data = body.model_dump()
    if data["created_at"] is None:
        data["created_at"] = now
    if data["updated_at"] is None:
        data["updated_at"] = now

    row = await statements_repository.insert_statement(pool, user_id, card_id, data)
    if row is not None:
        return row, True
    existing = await statements_repository.get_statement(
        pool, user_id, body.id, include_deleted=True
    )
    if existing is not None:
        return existing, False
    raise IdConflictError("A record with this id already exists")


async def list_statements_for(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    card_id: uuid.UUID,
    cursor: int,
    limit: int,
) -> tuple[list[asyncpg.Record], int, bool]:
    await get_card_or_404(pool, user_id, card_id)
    rows = await statements_repository.list_statements(
        pool, user_id, card_id, cursor, limit + 1
    )
    has_more = len(rows) > limit
    rows = rows[:limit]
    if rows:
        next_cursor = rows[-1]["server_seq"]
    else:
        next_cursor = cursor
    return rows, next_cursor, has_more


async def patch_statement(
    pool: asyncpg.Pool,
    user_id: uuid.UUID,
    statement_id: uuid.UUID,
    body: StatementPatch,
) -> asyncpg.Record:
    fields = body.model_dump(exclude_unset=True)
    fields.pop("updated_at")
    if not fields:
        row = await statements_repository.get_statement(pool, user_id, statement_id)
        if row is None:
            raise NotFoundError("Statement not found")
        return row

    row = await statements_repository.update_statement(
        pool, user_id, statement_id, body.updated_at, fields
    )
    if row is not None:
        return row
    existing = await statements_repository.get_statement(pool, user_id, statement_id)
    if existing is None:
        raise NotFoundError("Statement not found")
    raise StaleUpdateError(
        "A newer version of this record exists",
        details={"current": statement_to_response(existing).model_dump(mode="json")},
    )


async def delete_statement(
    pool: asyncpg.Pool, user_id: uuid.UUID, statement_id: uuid.UUID
) -> None:
    outcome = await statements_repository.tombstone_statement(
        pool, user_id, statement_id
    )
    if outcome is None:
        raise NotFoundError("Statement not found")
