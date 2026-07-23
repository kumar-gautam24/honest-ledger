from tests.factories import borrowing_payload


async def test_create_returns_201_with_row(client, auth_headers):
    payload = borrowing_payload()
    response = await client.post("/v1/borrowings", json=payload, headers=auth_headers)
    assert response.status_code == 201
    body = response.json()
    assert body["id"] == payload["id"]
    assert body["principal_paise"] == 499500
    assert body["server_seq"] > 0
    assert body["deleted_at"] is None


async def test_card_id_round_trips_and_defaults_null(client, auth_headers):
    # v1 client omits card_id → NULL; a newer client sends and patches it.
    omitted = borrowing_payload()
    body = (
        await client.post("/v1/borrowings", json=omitted, headers=auth_headers)
    ).json()
    assert body["card_id"] is None

    linked = borrowing_payload(card_id="card-abc")
    created = (
        await client.post("/v1/borrowings", json=linked, headers=auth_headers)
    ).json()
    assert created["card_id"] == "card-abc"
    fetched = await client.get(
        f"/v1/borrowings/{linked['id']}", headers=auth_headers
    )
    assert fetched.json()["card_id"] == "card-abc"

    patched = await client.patch(
        f"/v1/borrowings/{linked['id']}",
        json={"card_id": "card-xyz", "updated_at": "2027-01-01T00:00:00Z"},
        headers=auth_headers,
    )
    assert patched.json()["card_id"] == "card-xyz"


async def test_create_accepts_text_lender_id_slug(client, auth_headers):
    # Client lender ids are catalog slugs, not UUIDs (see migration 0006).
    payload = borrowing_payload(lender_id="slice")
    response = await client.post("/v1/borrowings", json=payload, headers=auth_headers)
    assert response.status_code == 201
    assert response.json()["lender_id"] == "slice"


async def test_create_replay_returns_200_same_row(client, auth_headers):
    payload = borrowing_payload()
    first = await client.post("/v1/borrowings", json=payload, headers=auth_headers)
    replay = await client.post("/v1/borrowings", json=payload, headers=auth_headers)
    assert replay.status_code == 200
    assert replay.json()["id"] == first.json()["id"]
    assert replay.json()["server_seq"] == first.json()["server_seq"]  # no new write


async def test_create_with_foreign_uuid_is_409(client, auth_headers, other_auth_headers):
    payload = borrowing_payload()
    await client.post("/v1/borrowings", json=payload, headers=auth_headers)
    response = await client.post(
        "/v1/borrowings", json=payload, headers=other_auth_headers
    )
    assert response.status_code == 409
    assert response.json()["error"]["code"] == "id_conflict"


async def test_create_negative_money_is_422(client, auth_headers):
    payload = borrowing_payload(principal_paise=-5)
    response = await client.post("/v1/borrowings", json=payload, headers=auth_headers)
    assert response.status_code == 422


async def test_requires_auth(client):
    response = await client.post("/v1/borrowings", json=borrowing_payload())
    assert response.status_code == 401


async def test_get_and_list(client, auth_headers, other_auth_headers):
    payload = borrowing_payload()
    await client.post("/v1/borrowings", json=payload, headers=auth_headers)

    single = await client.get(f"/v1/borrowings/{payload['id']}", headers=auth_headers)
    assert single.status_code == 200

    listing = await client.get("/v1/borrowings", headers=auth_headers)
    assert listing.status_code == 200
    body = listing.json()
    assert len(body["items"]) == 1
    assert body["has_more"] is False
    assert body["next_cursor"] == body["items"][0]["server_seq"]

    foreign = await client.get(
        f"/v1/borrowings/{payload['id']}", headers=other_auth_headers
    )
    assert foreign.status_code == 404


async def test_list_pagination(client, auth_headers):
    for _ in range(3):
        await client.post(
            "/v1/borrowings", json=borrowing_payload(), headers=auth_headers
        )
    page1 = await client.get("/v1/borrowings?limit=2", headers=auth_headers)
    assert len(page1.json()["items"]) == 2
    assert page1.json()["has_more"] is True

    cursor = page1.json()["next_cursor"]
    page2 = await client.get(
        f"/v1/borrowings?limit=2&cursor={cursor}", headers=auth_headers
    )
    assert len(page2.json()["items"]) == 1
    assert page2.json()["has_more"] is False


async def test_patch_lww(client, auth_headers):
    payload = borrowing_payload()
    created = await client.post("/v1/borrowings", json=payload, headers=auth_headers)
    created_at = created.json()["updated_at"]

    win = await client.patch(
        f"/v1/borrowings/{payload['id']}",
        json={"title": "renamed", "updated_at": "2027-01-01T00:00:00Z"},
        headers=auth_headers,
    )
    assert win.status_code == 200
    assert win.json()["title"] == "renamed"

    lose = await client.patch(
        f"/v1/borrowings/{payload['id']}",
        json={"title": "old edit", "updated_at": created_at},
        headers=auth_headers,
    )
    assert lose.status_code == 409
    body = lose.json()["error"]
    assert body["code"] == "stale_update"
    assert body["details"]["current"]["title"] == "renamed"


async def test_patch_missing_is_404(client, auth_headers):
    response = await client.patch(
        "/v1/borrowings/00000000-0000-0000-0000-000000000000",
        json={"title": "x", "updated_at": "2027-01-01T00:00:00Z"},
        headers=auth_headers,
    )
    assert response.status_code == 404


async def test_delete_is_idempotent_and_hides_row(client, auth_headers):
    payload = borrowing_payload()
    await client.post("/v1/borrowings", json=payload, headers=auth_headers)

    first = await client.delete(f"/v1/borrowings/{payload['id']}", headers=auth_headers)
    assert first.status_code == 204
    again = await client.delete(f"/v1/borrowings/{payload['id']}", headers=auth_headers)
    assert again.status_code == 204

    assert (
        await client.get(f"/v1/borrowings/{payload['id']}", headers=auth_headers)
    ).status_code == 404
    listing = await client.get("/v1/borrowings", headers=auth_headers)
    assert listing.json()["items"] == []
