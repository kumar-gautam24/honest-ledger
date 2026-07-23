from tests.factories import card_payload


async def test_create_returns_201_with_row(client, auth_headers):
    payload = card_payload()
    response = await client.post("/v1/cards", json=payload, headers=auth_headers)
    assert response.status_code == 201
    body = response.json()
    assert body["id"] == payload["id"]
    assert body["lender_id"] == "hdfc-swiggy"
    assert body["credit_limit_paise"] == 20000000
    assert body["server_seq"] > 0
    assert body["deleted_at"] is None


async def test_nickname_round_trips_and_defaults_null(client, auth_headers):
    # A shipped v1 client omits nickname → stored NULL, returned null.
    omitted = card_payload()
    body = (
        await client.post("/v1/cards", json=omitted, headers=auth_headers)
    ).json()
    assert body["nickname"] is None

    # A newer client sends it → round-trips on create and on GET.
    named = card_payload(nickname="ICICI Amazon Pay")
    created = (
        await client.post("/v1/cards", json=named, headers=auth_headers)
    ).json()
    assert created["nickname"] == "ICICI Amazon Pay"
    fetched = await client.get(f"/v1/cards/{named['id']}", headers=auth_headers)
    assert fetched.json()["nickname"] == "ICICI Amazon Pay"

    # And it is patchable.
    patched = await client.patch(
        f"/v1/cards/{named['id']}",
        json={"nickname": "ICICI Coral", "updated_at": "2027-01-01T00:00:00Z"},
        headers=auth_headers,
    )
    assert patched.json()["nickname"] == "ICICI Coral"


async def test_create_replay_returns_200_same_row(client, auth_headers):
    payload = card_payload()
    first = await client.post("/v1/cards", json=payload, headers=auth_headers)
    replay = await client.post("/v1/cards", json=payload, headers=auth_headers)
    assert replay.status_code == 200
    assert replay.json()["server_seq"] == first.json()["server_seq"]


async def test_create_with_foreign_id_is_409(client, auth_headers, other_auth_headers):
    payload = card_payload()
    await client.post("/v1/cards", json=payload, headers=auth_headers)
    response = await client.post("/v1/cards", json=payload, headers=other_auth_headers)
    assert response.status_code == 409
    assert response.json()["error"]["code"] == "id_conflict"


async def test_invalid_statement_day_is_422(client, auth_headers):
    payload = card_payload(statement_day=40)
    response = await client.post("/v1/cards", json=payload, headers=auth_headers)
    assert response.status_code == 422


async def test_requires_auth(client):
    response = await client.post("/v1/cards", json=card_payload())
    assert response.status_code == 401


async def test_get_and_list_scoped(client, auth_headers, other_auth_headers):
    payload = card_payload()
    await client.post("/v1/cards", json=payload, headers=auth_headers)

    single = await client.get(f"/v1/cards/{payload['id']}", headers=auth_headers)
    assert single.status_code == 200

    listing = await client.get("/v1/cards", headers=auth_headers)
    assert len(listing.json()["items"]) == 1

    foreign = await client.get(f"/v1/cards/{payload['id']}", headers=other_auth_headers)
    assert foreign.status_code == 404


async def test_list_pagination(client, auth_headers):
    for _ in range(3):
        await client.post("/v1/cards", json=card_payload(), headers=auth_headers)
    page1 = await client.get("/v1/cards?limit=2", headers=auth_headers)
    assert len(page1.json()["items"]) == 2
    assert page1.json()["has_more"] is True

    cursor = page1.json()["next_cursor"]
    page2 = await client.get(f"/v1/cards?limit=2&cursor={cursor}", headers=auth_headers)
    assert len(page2.json()["items"]) == 1
    assert page2.json()["has_more"] is False


async def test_patch_lww(client, auth_headers):
    payload = card_payload()
    created = await client.post("/v1/cards", json=payload, headers=auth_headers)
    created_at = created.json()["updated_at"]

    win = await client.patch(
        f"/v1/cards/{payload['id']}",
        json={"due_day": 20, "updated_at": "2027-01-01T00:00:00Z"},
        headers=auth_headers,
    )
    assert win.status_code == 200
    assert win.json()["due_day"] == 20

    lose = await client.patch(
        f"/v1/cards/{payload['id']}",
        json={"due_day": 1, "updated_at": created_at},
        headers=auth_headers,
    )
    assert lose.status_code == 409
    assert lose.json()["error"]["code"] == "stale_update"
    assert lose.json()["error"]["details"]["current"]["due_day"] == 20


async def test_delete_is_idempotent_and_hides_row(client, auth_headers):
    payload = card_payload()
    await client.post("/v1/cards", json=payload, headers=auth_headers)

    first = await client.delete(f"/v1/cards/{payload['id']}", headers=auth_headers)
    assert first.status_code == 204
    again = await client.delete(f"/v1/cards/{payload['id']}", headers=auth_headers)
    assert again.status_code == 204

    assert (
        await client.get(f"/v1/cards/{payload['id']}", headers=auth_headers)
    ).status_code == 404
    listing = await client.get("/v1/cards", headers=auth_headers)
    assert listing.json()["items"] == []
