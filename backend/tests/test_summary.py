from tests.factories import borrowing_payload, repayment_payload


async def test_summary_aggregates_borrowings_and_repayments(client, auth_headers):
    # Active borrowing with fees.
    active = borrowing_payload(
        status="active",
        principal_paise=500000,
        processing_fee_paise=10000,
        gst_on_fee_paise=1800,
    )
    await client.post("/v1/borrowings", json=active, headers=auth_headers)
    # A closed borrowing, no fees.
    closed = borrowing_payload(status="closed", principal_paise=200000)
    await client.post("/v1/borrowings", json=closed, headers=auth_headers)
    # One repayment against the active borrowing.
    await client.post(
        f"/v1/borrowings/{active['id']}/repayments",
        json=repayment_payload(amount_paise=150000),
        headers=auth_headers,
    )

    response = await client.get("/v1/summary", headers=auth_headers)
    assert response.status_code == 200
    body = response.json()
    assert body["total_borrowed_paise"] == 700000
    assert body["total_fees_paise"] == 11800
    assert body["total_repaid_paise"] == 150000
    assert body["borrowings_count"] == 2
    assert body["active_borrowings_count"] == 1


async def test_summary_is_zero_for_fresh_user(client, auth_headers):
    response = await client.get("/v1/summary", headers=auth_headers)
    assert response.json() == {
        "total_borrowed_paise": 0,
        "total_fees_paise": 0,
        "total_repaid_paise": 0,
        "borrowings_count": 0,
        "active_borrowings_count": 0,
    }


async def test_summary_excludes_deleted_rows(client, auth_headers):
    payload = borrowing_payload(principal_paise=999000)
    await client.post("/v1/borrowings", json=payload, headers=auth_headers)
    await client.delete(f"/v1/borrowings/{payload['id']}", headers=auth_headers)
    response = await client.get("/v1/summary", headers=auth_headers)
    assert response.json()["total_borrowed_paise"] == 0
    assert response.json()["borrowings_count"] == 0


async def test_summary_is_user_scoped(client, auth_headers, other_auth_headers):
    await client.post(
        "/v1/borrowings", json=borrowing_payload(), headers=auth_headers
    )
    response = await client.get("/v1/summary", headers=other_auth_headers)
    assert response.json()["borrowings_count"] == 0


async def test_summary_requires_auth(client):
    response = await client.get("/v1/summary")
    assert response.status_code == 401
