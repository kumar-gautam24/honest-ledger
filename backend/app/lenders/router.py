"""HTTP layer for lenders. Status-code logic only; rules live in service."""

import uuid

import asyncpg
from fastapi import APIRouter, Depends, Query, Response

from app.lenders import service
from app.lenders.schemas import (
    LenderCreate,
    LenderListResponse,
    LenderPatch,
    LenderResponse,
)
from app.core.dependencies import get_current_user_id, get_pool

lenders_router = APIRouter(prefix="/v1/lenders", tags=["lenders"])


@lenders_router.post("", status_code=201, response_model=LenderResponse)
async def create_lender(
    body: LenderCreate,
    response: Response,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> LenderResponse:
    row, created = await service.create_lender(pool, user_id, body)
    if not created:
        response.status_code = 200  # replay: same request, same row, no new write
    return service.row_to_response(row)


@lenders_router.get("", response_model=LenderListResponse)
async def list_lenders(
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
    cursor: int = Query(default=0, ge=0),
    limit: int = Query(default=50, ge=1, le=200),
) -> LenderListResponse:
    rows, next_cursor, has_more = await service.list_lenders(
        pool, user_id, cursor, limit
    )
    return LenderListResponse(
        items=[service.row_to_response(row) for row in rows],
        next_cursor=next_cursor,
        has_more=has_more,
    )


@lenders_router.get("/{lender_id}", response_model=LenderResponse)
async def get_lender(
    lender_id: str,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> LenderResponse:
    row = await service.get_lender_or_404(pool, user_id, lender_id)
    return service.row_to_response(row)


@lenders_router.patch("/{lender_id}", response_model=LenderResponse)
async def patch_lender(
    lender_id: str,
    body: LenderPatch,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> LenderResponse:
    row = await service.patch_lender(pool, user_id, lender_id, body)
    return service.row_to_response(row)


@lenders_router.delete("/{lender_id}", status_code=204)
async def delete_lender(
    lender_id: str,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> None:
    await service.delete_lender(pool, user_id, lender_id)
