"""Per-user settings: income round-trip, LWW, tombstone, tenant scope."""


async def test_put_and_get_income(client, auth_headers):
    put = await client.put(
        "/v1/settings/income",
        json={"value": 5000000, "updated_at": "2026-07-01T00:00:00Z"},
        headers=auth_headers,
    )
    assert put.status_code == 200
    assert put.json()["key"] == "income"
    assert put.json()["value"] == 5000000

    listing = await client.get("/v1/settings", headers=auth_headers)
    assert listing.status_code == 200
    items = {s["key"]: s["value"] for s in listing.json()["items"]}
    assert items == {"income": 5000000}


async def test_put_is_lww(client, auth_headers):
    await client.put(
        "/v1/settings/income",
        json={"value": 5000000, "updated_at": "2026-07-01T00:00:00Z"},
        headers=auth_headers,
    )
    # Newer stamp wins.
    win = await client.put(
        "/v1/settings/income",
        json={"value": 6000000, "updated_at": "2026-07-02T00:00:00Z"},
        headers=auth_headers,
    )
    assert win.json()["value"] == 6000000
    # Older stamp loses: value stays at the newer 6000000.
    lose = await client.put(
        "/v1/settings/income",
        json={"value": 1, "updated_at": "2020-01-01T00:00:00Z"},
        headers=auth_headers,
    )
    assert lose.json()["value"] == 6000000


async def test_delete_setting(client, auth_headers):
    await client.put(
        "/v1/settings/income",
        json={"value": 5000000, "updated_at": "2026-07-01T00:00:00Z"},
        headers=auth_headers,
    )
    deleted = await client.delete("/v1/settings/income", headers=auth_headers)
    assert deleted.status_code == 204
    listing = await client.get("/v1/settings", headers=auth_headers)
    assert listing.json()["items"] == []


async def test_settings_are_user_scoped(client, auth_headers, other_auth_headers):
    await client.put(
        "/v1/settings/income",
        json={"value": 5000000, "updated_at": "2026-07-01T00:00:00Z"},
        headers=auth_headers,
    )
    listing = await client.get("/v1/settings", headers=other_auth_headers)
    assert listing.json()["items"] == []


async def test_settings_require_auth(client):
    assert (await client.get("/v1/settings")).status_code == 401


async def test_setting_appears_in_changes_feed(client, auth_headers):
    await client.put(
        "/v1/settings/income",
        json={"value": 5000000, "updated_at": "2026-07-01T00:00:00Z"},
        headers=auth_headers,
    )
    feed = await client.get("/v1/changes", headers=auth_headers)
    settings = [c for c in feed.json()["changes"] if c["entity"] == "setting"]
    assert len(settings) == 1
    assert settings[0]["data"]["key"] == "income"
