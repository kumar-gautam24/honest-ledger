"""HTTP layer for recurring items. Status-code logic only; rules live in service."""

import uuid

import asyncpg
from fastapi import APIRouter, Depends, Query, Response

from app.recurring import service
from app.recurring.schemas import (
    RecurringCreate,
    RecurringListResponse,
    RecurringPatch,
    RecurringResponse,
)
from app.core.dependencies import get_current_user_id, get_pool

recurring_router = APIRouter(prefix="/v1/recurring-items", tags=["recurring-items"])


@recurring_router.post("", status_code=201, response_model=RecurringResponse)
async def create_recurring(
    body: RecurringCreate,
    response: Response,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> RecurringResponse:
    row, created = await service.create_recurring(pool, user_id, body)
    if not created:
        response.status_code = 200  # replay: same request, same row, no new write
    return service.row_to_response(row)


@recurring_router.get("", response_model=RecurringListResponse)
async def list_recurring(
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
    cursor: int = Query(default=0, ge=0),
    limit: int = Query(default=50, ge=1, le=200),
) -> RecurringListResponse:
    rows, next_cursor, has_more = await service.list_recurring(
        pool, user_id, cursor, limit
    )
    return RecurringListResponse(
        items=[service.row_to_response(row) for row in rows],
        next_cursor=next_cursor,
        has_more=has_more,
    )


@recurring_router.get("/{recurring_id}", response_model=RecurringResponse)
async def get_recurring(
    recurring_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> RecurringResponse:
    row = await service.get_recurring_or_404(pool, user_id, recurring_id)
    return service.row_to_response(row)


@recurring_router.patch("/{recurring_id}", response_model=RecurringResponse)
async def patch_recurring(
    recurring_id: uuid.UUID,
    body: RecurringPatch,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> RecurringResponse:
    row = await service.patch_recurring(pool, user_id, recurring_id, body)
    return service.row_to_response(row)


@recurring_router.delete("/{recurring_id}", status_code=204)
async def delete_recurring(
    recurring_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> None:
    await service.delete_recurring(pool, user_id, recurring_id)
