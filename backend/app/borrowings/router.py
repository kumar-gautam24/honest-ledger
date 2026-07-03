"""HTTP layer for borrowings. Status-code logic only; rules live in service."""

import uuid

import asyncpg
from fastapi import APIRouter, Depends, Query, Response

from app.borrowings import service
from app.borrowings.schemas import (
    BorrowingCreate,
    BorrowingListResponse,
    BorrowingPatch,
    BorrowingResponse,
)
from app.core.dependencies import get_current_user_id, get_pool

borrowings_router = APIRouter(prefix="/v1/borrowings", tags=["borrowings"])


@borrowings_router.post("", status_code=201, response_model=BorrowingResponse)
async def create_borrowing(
    body: BorrowingCreate,
    response: Response,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> BorrowingResponse:
    row, created = await service.create_borrowing(pool, user_id, body)
    if not created:
        response.status_code = 200  # replay: same request, same row, no new write
    return service.row_to_response(row)


@borrowings_router.get("", response_model=BorrowingListResponse)
async def list_borrowings(
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
    cursor: int = Query(default=0, ge=0),
    limit: int = Query(default=50, ge=1, le=200),
) -> BorrowingListResponse:
    rows, next_cursor, has_more = await service.list_borrowings(
        pool, user_id, cursor, limit
    )
    return BorrowingListResponse(
        items=[service.row_to_response(row) for row in rows],
        next_cursor=next_cursor,
        has_more=has_more,
    )


@borrowings_router.get("/{borrowing_id}", response_model=BorrowingResponse)
async def get_borrowing(
    borrowing_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> BorrowingResponse:
    row = await service.get_borrowing_or_404(pool, user_id, borrowing_id)
    return service.row_to_response(row)


@borrowings_router.patch("/{borrowing_id}", response_model=BorrowingResponse)
async def patch_borrowing(
    borrowing_id: uuid.UUID,
    body: BorrowingPatch,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> BorrowingResponse:
    row = await service.patch_borrowing(pool, user_id, borrowing_id, body)
    return service.row_to_response(row)


@borrowings_router.delete("/{borrowing_id}", status_code=204)
async def delete_borrowing(
    borrowing_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> None:
    await service.delete_borrowing(pool, user_id, borrowing_id)
