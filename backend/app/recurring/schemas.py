"""Recurring item request/response shapes. Amount is integer paise, always >= 0."""

import uuid
from datetime import datetime

from pydantic import BaseModel, Field


class RecurringCreate(BaseModel):
    id: uuid.UUID  # client-generated: this is what makes creates replay-safe
    title: str = Field(min_length=1, max_length=200)
    type: str = Field(default="subscription", max_length=40)
    amount_paise: int = Field(ge=0)
    frequency: str = Field(default="monthly", max_length=40)
    next_due_date: datetime
    category: str | None = Field(default=None, max_length=100)
    card_id: str | None = Field(default=None, max_length=100)
    is_active: bool = True
    notes: str | None = Field(default=None, max_length=2000)
    created_at: datetime | None = None
    updated_at: datetime | None = None


class RecurringPatch(BaseModel):
    # LWW stamp: required on every edit.
    updated_at: datetime
    title: str | None = Field(default=None, min_length=1, max_length=200)
    type: str | None = Field(default=None, max_length=40)
    amount_paise: int | None = Field(default=None, ge=0)
    frequency: str | None = Field(default=None, max_length=40)
    next_due_date: datetime | None = None
    category: str | None = Field(default=None, max_length=100)
    card_id: str | None = Field(default=None, max_length=100)
    is_active: bool | None = None
    notes: str | None = Field(default=None, max_length=2000)


class RecurringResponse(BaseModel):
    id: uuid.UUID
    title: str
    type: str
    amount_paise: int
    frequency: str
    next_due_date: datetime
    category: str | None
    card_id: str | None
    is_active: bool
    notes: str | None
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None
    server_seq: int


class RecurringListResponse(BaseModel):
    items: list[RecurringResponse]
    next_cursor: int
    has_more: bool
