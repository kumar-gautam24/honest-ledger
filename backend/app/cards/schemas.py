"""Card + card-statement shapes. Money is integer paise, always >= 0.

A card references a lender by id, but that lender may be a BUILT-IN (not stored
server-side), so lender_id is a plain string with no server-side FK. Statements are
the child rows (one per billing cycle), mirroring repayments under a borrowing.
"""

import uuid
from datetime import datetime

from pydantic import BaseModel, Field


class CardCreate(BaseModel):
    id: uuid.UUID  # client-generated: this is what makes creates replay-safe
    lender_id: str = Field(min_length=1, max_length=100)
    statement_day: int = Field(ge=1, le=31)
    due_day: int = Field(ge=1, le=31)
    nickname: str | None = Field(default=None, max_length=100)
    credit_limit_paise: int | None = Field(default=None, ge=0)
    is_active: bool = True
    created_at: datetime | None = None
    updated_at: datetime | None = None


class CardPatch(BaseModel):
    updated_at: datetime
    lender_id: str | None = Field(default=None, min_length=1, max_length=100)
    statement_day: int | None = Field(default=None, ge=1, le=31)
    due_day: int | None = Field(default=None, ge=1, le=31)
    nickname: str | None = Field(default=None, max_length=100)
    credit_limit_paise: int | None = Field(default=None, ge=0)
    is_active: bool | None = None


class CardResponse(BaseModel):
    id: uuid.UUID
    lender_id: str
    statement_day: int
    due_day: int
    nickname: str | None
    credit_limit_paise: int | None
    is_active: bool
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None
    server_seq: int


class CardListResponse(BaseModel):
    items: list[CardResponse]
    next_cursor: int
    has_more: bool


class StatementCreate(BaseModel):
    id: uuid.UUID
    cycle_month: datetime
    statement_amount_paise: int = Field(ge=0)
    due_date: datetime
    paid_amount_paise: int = Field(default=0, ge=0)
    paid_date: datetime | None = None
    notes: str | None = Field(default=None, max_length=2000)
    created_at: datetime | None = None
    updated_at: datetime | None = None


class StatementPatch(BaseModel):
    updated_at: datetime
    cycle_month: datetime | None = None
    statement_amount_paise: int | None = Field(default=None, ge=0)
    due_date: datetime | None = None
    paid_amount_paise: int | None = Field(default=None, ge=0)
    paid_date: datetime | None = None
    notes: str | None = Field(default=None, max_length=2000)


class StatementResponse(BaseModel):
    id: uuid.UUID
    card_id: uuid.UUID
    cycle_month: datetime
    statement_amount_paise: int
    due_date: datetime
    paid_amount_paise: int
    paid_date: datetime | None
    notes: str | None
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None
    server_seq: int


class StatementListResponse(BaseModel):
    items: list[StatementResponse]
    next_cursor: int
    has_more: bool
