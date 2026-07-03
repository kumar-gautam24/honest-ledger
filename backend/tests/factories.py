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
