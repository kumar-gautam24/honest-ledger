"""Migration 0009's columns must survive the wire, not merely default.

Backs the slice SFB personal loan: an actual/365 fixed EMI whose fee was
financed into the sanctioned amount, whose first period is the 34 days its KFS
states, and whose lender charges nothing to foreclose but one extra day of
interest.
"""

import uuid

from tests.factories import borrowing_payload


async def test_day_count_fields_round_trip(client, auth_headers):
    payload = borrowing_payload(
        kind="fixedEmi",
        fee_financed=True,
        day_count="actual365",
        first_due_date="2026-03-05T00:00:00Z",
        first_period_days=34,
        interest_rate_pct=31.15,
        tenure_months=12,
    )
    created = await client.post("/v1/borrowings", json=payload, headers=auth_headers)
    assert created.status_code == 201
    body = created.json()
    assert body["day_count"] == "actual365"
    assert body["first_period_days"] == 34
    assert body["first_due_date"].startswith("2026-03-05")
    assert body["fee_financed"] is True

    fetched = await client.get(f"/v1/borrowings/{payload['id']}", headers=auth_headers)
    assert fetched.json()["day_count"] == "actual365"


async def test_day_count_defaults_keep_old_clients_working(client, auth_headers):
    # An older app version sends no day-count fields at all.
    payload = borrowing_payload()
    payload.pop("day_count", None)
    payload.pop("first_due_date", None)
    payload.pop("first_period_days", None)
    response = await client.post("/v1/borrowings", json=payload, headers=auth_headers)
    assert response.status_code == 201
    body = response.json()
    assert body["day_count"] == "monthlyUniform"
    assert body["first_due_date"] is None
    assert body["first_period_days"] is None


async def test_day_count_is_patchable(client, auth_headers):
    payload = borrowing_payload()
    await client.post("/v1/borrowings", json=payload, headers=auth_headers)
    patched = await client.patch(
        f"/v1/borrowings/{payload['id']}",
        json={"updated_at": "2030-01-01T00:00:00Z", "day_count": "actual365"},
        headers=auth_headers,
    )
    assert patched.status_code == 200
    assert patched.json()["day_count"] == "actual365"


async def test_repayment_kind_round_trips_and_defaults_to_payment(
    client, auth_headers
):
    borrowing = borrowing_payload()
    await client.post("/v1/borrowings", json=borrowing, headers=auth_headers)

    charge = {
        "id": str(uuid.uuid4()),
        "amount_paise": 50000,
        "date": "2026-04-06T00:00:00Z",
        "kind": "charge",
        "note": "late payment penal charge",
    }
    created = await client.post(
        f"/v1/borrowings/{borrowing['id']}/repayments",
        json=charge,
        headers=auth_headers,
    )
    assert created.status_code == 201
    assert created.json()["kind"] == "charge"

    # An older client omits `kind` entirely.
    plain = {
        "id": str(uuid.uuid4()),
        "amount_paise": 793653,
        "date": "2026-03-05T00:00:00Z",
    }
    response = await client.post(
        f"/v1/borrowings/{borrowing['id']}/repayments",
        json=plain,
        headers=auth_headers,
    )
    assert response.status_code == 201
    assert response.json()["kind"] == "payment"


async def test_lender_foreclosure_rules_round_trip(client, auth_headers):
    lender = {
        "id": "slice-sfb",
        "name": "slice SFB",
        "type": "bnpl",
        "typical_rate_pct": 31.15,
        "foreclosure_pct": 0,
        "foreclosure_gst": False,
        "foreclosure_extra_interest_days": 1,
    }
    created = await client.post("/v1/lenders", json=lender, headers=auth_headers)
    assert created.status_code == 201
    body = created.json()
    assert body["foreclosure_pct"] == 0
    assert body["foreclosure_gst"] is False
    assert body["foreclosure_extra_interest_days"] == 1
    # Unspecified rules stay unknown rather than defaulting to a guess.
    assert body["foreclosure_min"] is None
    assert body["foreclosure_free_window_days"] is None


async def test_lender_foreclosure_defaults(client, auth_headers):
    lender = {"id": "plain-card", "name": "Plain Card", "type": "card"}
    body = (
        await client.post("/v1/lenders", json=lender, headers=auth_headers)
    ).json()
    assert body["foreclosure_gst"] is True
    assert body["foreclosure_extra_interest_days"] == 0
    assert body["foreclosure_pct"] is None
