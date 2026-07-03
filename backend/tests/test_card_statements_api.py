from tests.factories import card_payload, card_statement_payload


async def _card(client, headers) -> str:
    payload = card_payload()
    await client.post("/v1/cards", json=payload, headers=headers)
    return payload["id"]


async def test_create_list_statement(client, auth_headers):
    card_id = await _card(client, auth_headers)
    payload = card_statement_payload()

    created = await client.post(
        f"/v1/cards/{card_id}/statements", json=payload, headers=auth_headers
    )
    assert created.status_code == 201
    assert created.json()["card_id"] == card_id
    assert created.json()["statement_amount_paise"] == 1250000

    replay = await client.post(
        f"/v1/cards/{card_id}/statements", json=payload, headers=auth_headers
    )
    assert replay.status_code == 200

    listing = await client.get(
        f"/v1/cards/{card_id}/statements", headers=auth_headers
    )
    assert len(listing.json()["items"]) == 1


async def test_create_under_foreign_card_is_404(
    client, auth_headers, other_auth_headers
):
    card_id = await _card(client, auth_headers)
    response = await client.post(
        f"/v1/cards/{card_id}/statements",
        json=card_statement_payload(),
        headers=other_auth_headers,
    )
    assert response.status_code == 404


async def test_create_under_tombstoned_card_is_404(client, auth_headers):
    card_id = await _card(client, auth_headers)
    await client.delete(f"/v1/cards/{card_id}", headers=auth_headers)
    response = await client.post(
        f"/v1/cards/{card_id}/statements",
        json=card_statement_payload(),
        headers=auth_headers,
    )
    assert response.status_code == 404


async def test_patch_and_delete_statement(client, auth_headers):
    card_id = await _card(client, auth_headers)
    payload = card_statement_payload()
    await client.post(
        f"/v1/cards/{card_id}/statements", json=payload, headers=auth_headers
    )

    patched = await client.patch(
        f"/v1/statements/{payload['id']}",
        json={"paid_amount_paise": 1250000, "updated_at": "2027-01-01T00:00:00Z"},
        headers=auth_headers,
    )
    assert patched.status_code == 200
    assert patched.json()["paid_amount_paise"] == 1250000

    stale = await client.patch(
        f"/v1/statements/{payload['id']}",
        json={"paid_amount_paise": 1, "updated_at": "2020-01-01T00:00:00Z"},
        headers=auth_headers,
    )
    assert stale.status_code == 409

    deleted = await client.delete(
        f"/v1/statements/{payload['id']}", headers=auth_headers
    )
    assert deleted.status_code == 204
    listing = await client.get(
        f"/v1/cards/{card_id}/statements", headers=auth_headers
    )
    assert listing.json()["items"] == []
