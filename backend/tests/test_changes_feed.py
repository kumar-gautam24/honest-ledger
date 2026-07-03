from tests.factories import (
    borrowing_payload,
    card_payload,
    card_statement_payload,
    lender_payload,
    recurring_payload,
    repayment_payload,
)


async def test_feed_streams_creates_updates_and_tombstones_in_order(
    client, auth_headers
):
    borrowing = borrowing_payload()
    await client.post("/v1/borrowings", json=borrowing, headers=auth_headers)
    repayment = repayment_payload()
    await client.post(
        f"/v1/borrowings/{borrowing['id']}/repayments",
        json=repayment,
        headers=auth_headers,
    )
    await client.patch(
        f"/v1/borrowings/{borrowing['id']}",
        json={"title": "renamed", "updated_at": "2027-01-01T00:00:00Z"},
        headers=auth_headers,
    )
    await client.delete(f"/v1/repayments/{repayment['id']}", headers=auth_headers)

    response = await client.get("/v1/changes", headers=auth_headers)
    assert response.status_code == 200
    body = response.json()

    # 4 writes happened, but the feed shows CURRENT STATE per row (2 rows):
    # the borrowing (renamed) and the repayment (tombstoned), ordered by seq.
    entities = [(c["entity"], c["data"]["id"]) for c in body["changes"]]
    assert entities == [
        ("borrowing", borrowing["id"]),
        ("repayment", repayment["id"]),
    ]
    assert body["changes"][0]["data"]["title"] == "renamed"
    assert body["changes"][1]["data"]["deleted_at"] is not None
    assert body["has_more"] is False
    assert body["next_cursor"] == max(c["data"]["server_seq"] for c in body["changes"])


async def test_feed_cursor_pagination(client, auth_headers):
    for _ in range(3):
        await client.post(
            "/v1/borrowings", json=borrowing_payload(), headers=auth_headers
        )

    page1 = await client.get("/v1/changes?limit=2", headers=auth_headers)
    assert len(page1.json()["changes"]) == 2
    assert page1.json()["has_more"] is True

    cursor = page1.json()["next_cursor"]
    page2 = await client.get(f"/v1/changes?since={cursor}", headers=auth_headers)
    assert len(page2.json()["changes"]) == 1
    assert page2.json()["has_more"] is False

    # A cursor at the tip yields an empty page — the "I'm up to date" signal.
    tip = page2.json()["next_cursor"]
    empty = await client.get(f"/v1/changes?since={tip}", headers=auth_headers)
    assert empty.json()["changes"] == []
    assert empty.json()["next_cursor"] == tip


async def test_feed_includes_all_b3_entities_with_tombstones(client, auth_headers):
    # One of every B3 entity, plus a card statement under the card.
    lender = lender_payload()
    await client.post("/v1/lenders", json=lender, headers=auth_headers)
    recurring = recurring_payload()
    await client.post("/v1/recurring-items", json=recurring, headers=auth_headers)
    card = card_payload()
    await client.post("/v1/cards", json=card, headers=auth_headers)
    statement = card_statement_payload()
    await client.post(
        f"/v1/cards/{card['id']}/statements", json=statement, headers=auth_headers
    )
    # Delete the recurring item — the feed must still carry it as a tombstone.
    await client.delete(
        f"/v1/recurring-items/{recurring['id']}", headers=auth_headers
    )

    body = (await client.get("/v1/changes", headers=auth_headers)).json()
    by_entity = {c["entity"]: c["data"] for c in body["changes"]}

    assert by_entity["lender"]["id"] == lender["id"]
    assert by_entity["card"]["id"] == card["id"]
    assert by_entity["card_statement"]["id"] == statement["id"]
    assert by_entity["recurring_item"]["id"] == recurring["id"]
    assert by_entity["recurring_item"]["deleted_at"] is not None


async def test_feed_is_user_scoped(client, auth_headers, other_auth_headers):
    await client.post("/v1/borrowings", json=borrowing_payload(), headers=auth_headers)
    response = await client.get("/v1/changes", headers=other_auth_headers)
    assert response.json()["changes"] == []


async def test_feed_requires_auth(client):
    response = await client.get("/v1/changes")
    assert response.status_code == 401
