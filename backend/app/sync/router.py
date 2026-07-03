"""GET /v1/changes — how a device catches up on everything it missed.

Tombstones are INCLUDED here (unlike list endpoints): a device that was
offline must learn about deletions, not just additions.
"""

import json
import uuid

import asyncpg
from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel

from app.core.dependencies import get_current_user_id, get_pool
from app.sync import repository

sync_router = APIRouter(prefix="/v1", tags=["sync"])


class ChangeItem(BaseModel):
    entity: str
    data: dict


class ChangesResponse(BaseModel):
    changes: list[ChangeItem]
    next_cursor: int
    has_more: bool


@sync_router.get("/changes", response_model=ChangesResponse)
async def get_changes(
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
    since: int = Query(default=0, ge=0),
    limit: int = Query(default=50, ge=1, le=200),
) -> ChangesResponse:
    rows = await repository.list_changes(pool, user_id, since, limit + 1)
    has_more = len(rows) > limit
    rows = rows[:limit]

    changes = []
    for row in rows:
        changes.append(ChangeItem(entity=row["entity"], data=json.loads(row["data"])))

    if rows:
        next_cursor = rows[-1]["server_seq"]
    else:
        next_cursor = since
    return ChangesResponse(changes=changes, next_cursor=next_cursor, has_more=has_more)
