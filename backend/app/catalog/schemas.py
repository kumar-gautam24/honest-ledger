"""Catalog lender shapes. This is the GLOBAL, admin-managed template list — no
user_id, no is_mine (that is a per-user concept). Rate/fee fields are calculator
config (percent / overloaded flat), so they stay float, like the per-user lenders.
"""

from datetime import datetime

from pydantic import BaseModel, Field


class CatalogLenderUpsert(BaseModel):
    """Admin create-or-replace by id. All catalog fields; id required."""
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
    notes: str | None = Field(default=None, max_length=2000)
    is_active: bool = True
    sort_order: int = 0


class CatalogLenderPatch(BaseModel):
    """Admin partial update. Admin edits are authoritative (no LWW stamp)."""
    name: str | None = Field(default=None, min_length=1, max_length=200)
    type: str | None = Field(default=None, max_length=40)
    issuer: str | None = Field(default=None, max_length=200)
    network: str | None = Field(default=None, max_length=200)
    typical_rate_pct: float | None = Field(default=None, ge=0)
    rate_type: str | None = Field(default=None, max_length=40)
    fee_type: str | None = Field(default=None, max_length=40)
    fee_value: float | None = Field(default=None, ge=0)
    fee_cap: float | None = Field(default=None, ge=0)
    notes: str | None = Field(default=None, max_length=2000)
    is_active: bool | None = None
    sort_order: int | None = None


class CatalogLenderResponse(BaseModel):
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
    notes: str | None
    is_active: bool
    sort_order: int
    updated_at: datetime
    version: int


class CatalogResponse(BaseModel):
    version: int  # MAX(version) across all rows; the app caches this
    items: list[CatalogLenderResponse]


class CatalogVersionResponse(BaseModel):
    version: int
