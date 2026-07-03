from tests.factories import borrowing_payload, repayment_payload


async def _borrowing(client, headers) -> str:
    payload = borrowing_payload()
    await client.post("/v1/borrowings", json=payload, headers=headers)
    return payload["id"]


async def test_create_list_repayment(client, auth_headers):
    borrowing_id = await _borrowing(client, auth_headers)
    payload = repayment_payload()

    created = await client.post(
        f"/v1/borrowings/{borrowing_id}/repayments", json=payload, headers=auth_headers
    )
    assert created.status_code == 201
    assert created.json()["borrowing_id"] == borrowing_id
    assert created.json()["amount_paise"] == 100000

    replay = await client.post(
        f"/v1/borrowings/{borrowing_id}/repayments", json=payload, headers=auth_headers
    )
    assert replay.status_code == 200

    listing = await client.get(
        f"/v1/borrowings/{borrowing_id}/repayments", headers=auth_headers
    )
    assert len(listing.json()["items"]) == 1


async def test_create_under_foreign_borrowing_is_404(
    client, auth_headers, other_auth_headers
):
    borrowing_id = await _borrowing(client, auth_headers)
    response = await client.post(
        f"/v1/borrowings/{borrowing_id}/repayments",
        json=repayment_payload(),
        headers=other_auth_headers,
    )
    assert response.status_code == 404


async def test_create_under_tombstoned_borrowing_is_404(client, auth_headers):
    borrowing_id = await _borrowing(client, auth_headers)
    await client.delete(f"/v1/borrowings/{borrowing_id}", headers=auth_headers)
    response = await client.post(
        f"/v1/borrowings/{borrowing_id}/repayments",
        json=repayment_payload(),
        headers=auth_headers,
    )
    assert response.status_code == 404


async def test_patch_and_delete_repayment(client, auth_headers):
    borrowing_id = await _borrowing(client, auth_headers)
    payload = repayment_payload()
    await client.post(
        f"/v1/borrowings/{borrowing_id}/repayments", json=payload, headers=auth_headers
    )

    patched = await client.patch(
        f"/v1/repayments/{payload['id']}",
        json={"amount_paise": 150000, "updated_at": "2027-01-01T00:00:00Z"},
        headers=auth_headers,
    )
    assert patched.status_code == 200
    assert patched.json()["amount_paise"] == 150000

    stale = await client.patch(
        f"/v1/repayments/{payload['id']}",
        json={"amount_paise": 1, "updated_at": "2020-01-01T00:00:00Z"},
        headers=auth_headers,
    )
    assert stale.status_code == 409

    deleted = await client.delete(
        f"/v1/repayments/{payload['id']}", headers=auth_headers
    )
    assert deleted.status_code == 204
    listing = await client.get(
        f"/v1/borrowings/{borrowing_id}/repayments", headers=auth_headers
    )
    assert listing.json()["items"] == []
