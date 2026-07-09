"""Lender (custom catalog) request/response shapes.

Only the user's CUSTOM lenders live server-side; built-ins ship in the app. The id
is a client string (built-in ids are slugs), so it stays `str`, not uuid. The rate /
fee fields are calculator config (a percent, or an overloaded flat/percent value),
NOT tracked money, so they stay float — the paise rule is for money the user moves.
"""

from datetime import datetime

from pydantic import BaseModel, Field


class LenderCreate(BaseModel):
    id: str = Field(min_length=1, max_length=100)
    name: str = Field(min_length=1, max_length=200)
    type: str = Field(default="card", max_length=40)
    issuer: str | None = Field(default=None, max_length=200)
    network: str | None = Field(default=None, max_length=200)
    typical_rate_pct: float = Field(default=0, ge=0)
    rate_type: str = Field(default="reducing", max_length=40)
    fee_type: str = Field(default="flat", max_length=40)
    fee_value: float = Field(default=0, ge=0)
    fee_cap: float | None = Field(default=None, ge=0)
    fee_min: float | None = Field(default=None, ge=0)
    foreclosure_pct: float | None = Field(default=None, ge=0)
    foreclosure_min: float | None = Field(default=None, ge=0)
    foreclosure_free_window_days: int | None = Field(default=None, ge=0)
    foreclosure_gst: bool = True
    foreclosure_extra_interest_days: int = Field(default=0, ge=0)
    is_mine: bool = False
    notes: str | None = Field(default=None, max_length=2000)
    created_at: datetime | None = None
    updated_at: datetime | None = None


class LenderPatch(BaseModel):
    # LWW stamp: required on every edit.
    updated_at: datetime
    name: str | None = Field(default=None, min_length=1, max_length=200)
    type: str | None = Field(default=None, max_length=40)
    issuer: str | None = Field(default=None, max_length=200)
    network: str | None = Field(default=None, max_length=200)
    typical_rate_pct: float | None = Field(default=None, ge=0)
    rate_type: str | None = Field(default=None, max_length=40)
    fee_type: str | None = Field(default=None, max_length=40)
    fee_value: float | None = Field(default=None, ge=0)
    fee_cap: float | None = Field(default=None, ge=0)
    fee_min: float | None = Field(default=None, ge=0)
    foreclosure_pct: float | None = Field(default=None, ge=0)
    foreclosure_min: float | None = Field(default=None, ge=0)
    foreclosure_free_window_days: int | None = Field(default=None, ge=0)
    foreclosure_gst: bool | None = None
    foreclosure_extra_interest_days: int | None = Field(default=None, ge=0)
    is_mine: bool | None = None
    notes: str | None = Field(default=None, max_length=2000)


class LenderResponse(BaseModel):
    id: str
    name: str
    type: str
    issuer: str | None
    network: str | None
    typical_rate_pct: float
    rate_type: str
    fee_type: str
    fee_value: float
    fee_cap: float | None
    fee_min: float | None
    foreclosure_pct: float | None
    foreclosure_min: float | None
    foreclosure_free_window_days: int | None
    foreclosure_gst: bool
    foreclosure_extra_interest_days: int
    is_mine: bool
    notes: str | None
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None
    server_seq: int


class LenderListResponse(BaseModel):
    items: list[LenderResponse]
    next_cursor: int
    has_more: bool
