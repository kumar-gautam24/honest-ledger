"""User-settings rules. `value` is stored as jsonb (a JSON string out of the DB),
so we json.loads it back into a real value for the response."""

import json
import uuid
from datetime import datetime

import asyncpg

from app.settings import repository
from app.settings.schemas import SettingResponse
from app.core.errors import NotFoundError


def row_to_response(row: asyncpg.Record) -> SettingResponse:
    data = dict(row)
    data["value"] = json.loads(data["value"])
    return SettingResponse.model_validate(data)


async def list_settings(
    pool: asyncpg.Pool, user_id: uuid.UUID
) -> list[asyncpg.Record]:
    return await repository.list_settings(pool, user_id)


async def put_setting(
    pool: asyncpg.Pool, user_id: uuid.UUID, key: str, value, updated_at: datetime
) -> asyncpg.Record:
    return await repository.upsert_setting(pool, user_id, key, value, updated_at)


async def delete_setting(
    pool: asyncpg.Pool, user_id: uuid.UUID, key: str
) -> None:
    outcome = await repository.tombstone_setting(pool, user_id, key)
    if outcome is None:
        raise NotFoundError("Setting not found")
