"""HTTP layer for per-user settings. Auth required; identity is (user, key)."""

import uuid

import asyncpg
from fastapi import APIRouter, Depends

from app.settings import service
from app.settings.schemas import SettingListResponse, SettingPut, SettingResponse
from app.core.dependencies import get_current_user_id, get_pool

settings_router = APIRouter(prefix="/v1/settings", tags=["settings"])


@settings_router.get("", response_model=SettingListResponse)
async def list_settings(
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> SettingListResponse:
    rows = await service.list_settings(pool, user_id)
    return SettingListResponse(items=[service.row_to_response(row) for row in rows])


@settings_router.put("/{key}", response_model=SettingResponse)
async def put_setting(
    key: str,
    body: SettingPut,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> SettingResponse:
    row = await service.put_setting(pool, user_id, key, body.value, body.updated_at)
    return service.row_to_response(row)


@settings_router.delete("/{key}", status_code=204)
async def delete_setting(
    key: str,
    user_id: uuid.UUID = Depends(get_current_user_id),
    pool: asyncpg.Pool = Depends(get_pool),
) -> None:
    await service.delete_setting(pool, user_id, key)
