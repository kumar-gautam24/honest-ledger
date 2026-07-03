from tests.factories import borrowing_payload, repayment_payload


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


async def test_feed_is_user_scoped(client, auth_headers, other_auth_headers):
    await client.post("/v1/borrowings", json=borrowing_payload(), headers=auth_headers)
    response = await client.get("/v1/changes", headers=other_auth_headers)
    assert response.json()["changes"] == []


async def test_feed_requires_auth(client):
    response = await client.get("/v1/changes")
    assert response.status_code == 401
