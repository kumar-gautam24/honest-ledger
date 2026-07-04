"""Per-user settings shapes. A small key-value store so device-agnostic settings
(income first; currency/toggles later) travel with the account. `value` is JSON, so
income is stored as an integer number of paise under key "income".
"""

from datetime import datetime
from typing import Any

from pydantic import BaseModel


class SettingPut(BaseModel):
    value: Any  # any JSON value; income = integer paise
    updated_at: datetime  # LWW stamp: required on every write


class SettingResponse(BaseModel):
    key: str
    value: Any
    updated_at: datetime
    deleted_at: datetime | None
    server_seq: int


class SettingListResponse(BaseModel):
    items: list[SettingResponse]
