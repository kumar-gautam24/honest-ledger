"""Payload factories for domain tests: valid by default, override what matters."""

import uuid


def borrowing_payload(**overrides) -> dict:
    payload = {
        "id": str(uuid.uuid4()),
        "title": "iPhone case EMI",
        "kind": "fixedEmi",
        "lender_name": "Slice",
        "principal_paise": 499500,
        "start_date": "2026-07-01T00:00:00Z",
    }
    payload.update(overrides)
    return payload


def repayment_payload(**overrides) -> dict:
    payload = {
        "id": str(uuid.uuid4()),
        "amount_paise": 100000,
        "date": "2026-07-15T00:00:00Z",
    }
    payload.update(overrides)
    return payload


def lender_payload(**overrides) -> dict:
    payload = {
        "id": str(uuid.uuid4()),  # a custom lender the user added
        "name": "My Credit Union Card",
        "type": "card",
        "typical_rate_pct": 18.0,
        "fee_type": "percent",
        "fee_value": 2.5,
        "fee_cap": 299.0,
        "is_mine": True,
    }
    payload.update(overrides)
    return payload


def recurring_payload(**overrides) -> dict:
    payload = {
        "id": str(uuid.uuid4()),
        "title": "Netflix",
        "type": "subscription",
        "amount_paise": 64900,
        "frequency": "monthly",
        "next_due_date": "2026-08-01T00:00:00Z",
    }
    payload.update(overrides)
    return payload


def card_payload(**overrides) -> dict:
    payload = {
        "id": str(uuid.uuid4()),
        "lender_id": "hdfc-swiggy",  # may be a built-in slug (no FK server-side)
        "statement_day": 5,
        "due_day": 25,
        "credit_limit_paise": 20000000,
    }
    payload.update(overrides)
    return payload


def card_statement_payload(**overrides) -> dict:
    payload = {
        "id": str(uuid.uuid4()),
        "cycle_month": "2026-07-01T00:00:00Z",
        "statement_amount_paise": 1250000,
        "due_date": "2026-07-25T00:00:00Z",
    }
    payload.update(overrides)
    return payload
