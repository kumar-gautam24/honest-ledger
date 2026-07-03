"""HTTP layer for cards and card statements. Status-code logic only."""

import uuid

import asyncpg
from fastapi import APIRouter, Depends, Query, Response

from app.cards import service
from app.cards.schemas import (
    CardCreate,
    CardListResponse,
    CardPatch,
    CardResponse,
    StatementCreate,
    StatementListResponse,
    StatementPatch,
    StatementResponse,
)
from app.core.dependencies import get_current_user_id, get_pool

cards_router = APIRouter(prefix="/v1/cards", tags=["cards"])
statements_router = APIRouter(prefix="/v1", tags=["card-statements"])


@cards_router.post("", status_code=201, response_model=CardResponse)
async def create_card(
    body: CardCreate,
    response: Response,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> CardResponse:
    row, created = await service.create_card(pool, user_id, body)
    if not created:
        response.status_code = 200  # replay: same request, same row, no new write
    return service.row_to_response(row)


@cards_router.get("", response_model=CardListResponse)
async def list_cards(
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
    cursor: int = Query(default=0, ge=0),
    limit: int = Query(default=50, ge=1, le=200),
) -> CardListResponse:
    rows, next_cursor, has_more = await service.list_cards(pool, user_id, cursor, limit)
    return CardListResponse(
        items=[service.row_to_response(row) for row in rows],
        next_cursor=next_cursor,
        has_more=has_more,
    )


@cards_router.get("/{card_id}", response_model=CardResponse)
async def get_card(
    card_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> CardResponse:
    row = await service.get_card_or_404(pool, user_id, card_id)
    return service.row_to_response(row)


@cards_router.patch("/{card_id}", response_model=CardResponse)
async def patch_card(
    card_id: uuid.UUID,
    body: CardPatch,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> CardResponse:
    row = await service.patch_card(pool, user_id, card_id, body)
    return service.row_to_response(row)


@cards_router.delete("/{card_id}", status_code=204)
async def delete_card(
    card_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> None:
    await service.delete_card(pool, user_id, card_id)


@cards_router.post(
    "/{card_id}/statements", status_code=201, response_model=StatementResponse
)
async def create_statement(
    card_id: uuid.UUID,
    body: StatementCreate,
    response: Response,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> StatementResponse:
    row, created = await service.create_statement(pool, user_id, card_id, body)
    if not created:
        response.status_code = 200
    return service.statement_to_response(row)


@cards_router.get("/{card_id}/statements", response_model=StatementListResponse)
async def list_statements(
    card_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
    cursor: int = Query(default=0, ge=0),
    limit: int = Query(default=50, ge=1, le=200),
) -> StatementListResponse:
    rows, next_cursor, has_more = await service.list_statements_for(
        pool, user_id, card_id, cursor, limit
    )
    return StatementListResponse(
        items=[service.statement_to_response(row) for row in rows],
        next_cursor=next_cursor,
        has_more=has_more,
    )


@statements_router.patch(
    "/statements/{statement_id}", response_model=StatementResponse
)
async def patch_statement(
    statement_id: uuid.UUID,
    body: StatementPatch,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> StatementResponse:
    row = await service.patch_statement(pool, user_id, statement_id, body)
    return service.statement_to_response(row)


@statements_router.delete("/statements/{statement_id}", status_code=204)
async def delete_statement(
    statement_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> None:
    await service.delete_statement(pool, user_id, statement_id)
