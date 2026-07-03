"""GET /v1/summary — a fast server-side rollup of the user's borrowing totals.

Field names say exactly what they are: total_fees_paise is the directly-recorded fee
cost, NOT the app's full "wasted" figure (which folds in modeled interest client-side).
"""

import uuid

import asyncpg
from fastapi import APIRouter, Depends
from pydantic import BaseModel

from app.core.dependencies import get_current_user_id, get_pool
from app.summary import repository

summary_router = APIRouter(prefix="/v1", tags=["summary"])


class SummaryResponse(BaseModel):
    total_borrowed_paise: int
    total_fees_paise: int
    total_repaid_paise: int
    borrowings_count: int
    active_borrowings_count: int


@summary_router.get("/summary", response_model=SummaryResponse)
async def get_summary(
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> SummaryResponse:
    data = await repository.get_summary(pool, user_id)
    return SummaryResponse(**data)
