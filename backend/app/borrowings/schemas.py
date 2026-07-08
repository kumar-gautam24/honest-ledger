"""Borrowing request/response shapes. Money is integer paise, always >= 0."""

import uuid
from datetime import datetime

from pydantic import BaseModel, Field


class BorrowingCreate(BaseModel):
    id: uuid.UUID  # client-generated: this is what makes creates replay-safe
    title: str = Field(min_length=1, max_length=200)
    kind: str = Field(default="flexibleLoan", max_length=40)
    lender_id: str | None = Field(default=None, max_length=100)
    lender_name: str = Field(default="", max_length=200)
    principal_paise: int = Field(ge=0)
    processing_fee_paise: int = Field(default=0, ge=0)
    gst_on_fee_paise: int = Field(default=0, ge=0)
    foreclosure_fee_paise: int | None = Field(default=None, ge=0)
    gst_on_interest: bool = False
    is_no_cost_emi: bool = False
    fee_financed: bool = False
    interest_rate_pct: float = Field(default=0, ge=0)
    rate_type: str = Field(default="reducing", max_length=40)
    tenure_months: int = Field(default=0, ge=0)
    min_payment_paise: int = Field(default=0, ge=0)
    start_date: datetime
    status: str = Field(default="active", max_length=40)
    notes: str | None = Field(default=None, max_length=2000)
    created_at: datetime | None = None
    updated_at: datetime | None = None


class BorrowingPatch(BaseModel):
    # LWW stamp: required on every edit.
    updated_at: datetime
    title: str | None = Field(default=None, min_length=1, max_length=200)
    kind: str | None = Field(default=None, max_length=40)
    lender_id: str | None = Field(default=None, max_length=100)
    lender_name: str | None = Field(default=None, max_length=200)
    principal_paise: int | None = Field(default=None, ge=0)
    processing_fee_paise: int | None = Field(default=None, ge=0)
    gst_on_fee_paise: int | None = Field(default=None, ge=0)
    foreclosure_fee_paise: int | None = Field(default=None, ge=0)
    gst_on_interest: bool | None = None
    is_no_cost_emi: bool | None = None
    fee_financed: bool | None = None
    interest_rate_pct: float | None = Field(default=None, ge=0)
    rate_type: str | None = Field(default=None, max_length=40)
    tenure_months: int | None = Field(default=None, ge=0)
    min_payment_paise: int | None = Field(default=None, ge=0)
    start_date: datetime | None = None
    status: str | None = Field(default=None, max_length=40)
    notes: str | None = Field(default=None, max_length=2000)


class BorrowingResponse(BaseModel):
    id: uuid.UUID
    title: str
    kind: str
    lender_id: str | None
    lender_name: str
    principal_paise: int
    processing_fee_paise: int
    gst_on_fee_paise: int
    foreclosure_fee_paise: int | None
    gst_on_interest: bool
    is_no_cost_emi: bool
    fee_financed: bool
    interest_rate_pct: float
    rate_type: str
    tenure_months: int
    min_payment_paise: int
    start_date: datetime
    status: str
    notes: str | None
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None
    server_seq: int


class BorrowingListResponse(BaseModel):
    items: list[BorrowingResponse]
    next_cursor: int
    has_more: bool


class RepaymentCreate(BaseModel):
    id: uuid.UUID
    amount_paise: int = Field(ge=0)
    date: datetime
    installment_no: int | None = Field(default=None, ge=0)
    note: str | None = Field(default=None, max_length=500)
    created_at: datetime | None = None
    updated_at: datetime | None = None


class RepaymentPatch(BaseModel):
    updated_at: datetime
    amount_paise: int | None = Field(default=None, ge=0)
    date: datetime | None = None
    installment_no: int | None = Field(default=None, ge=0)
    note: str | None = Field(default=None, max_length=500)


class RepaymentResponse(BaseModel):
    id: uuid.UUID
    borrowing_id: uuid.UUID
    amount_paise: int
    date: datetime
    installment_no: int | None
    note: str | None
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None
    server_seq: int


class RepaymentListResponse(BaseModel):
    items: list[RepaymentResponse]
    next_cursor: int
    has_more: bool
