"""Global lender catalog: public read, admin-only write, version bumps."""


def catalog_lender(**overrides) -> dict:
    payload = {
        "id": "test-lender",
        "name": "Test Lender",
        "type": "card",
        "typical_rate_pct": 18.0,
        "fee_type": "percent",
        "fee_value": 2.0,
    }
    payload.update(overrides)
    return payload


async def test_public_read_needs_no_auth(client):
    # The migrations seed 20 lenders (0005 + 0010's EMI-on-Call variants and
    # Kotak/Amex); anyone can read them without a token.
    response = await client.get("/v1/catalog/lenders")
    assert response.status_code == 200
    body = response.json()
    assert body["version"] > 0
    ids = [item["id"] for item in body["items"]]
    assert "slice" in ids
    assert "icici-emi-on-call" in ids
    assert len(body["items"]) == 20
    # 0010's new columns are exposed on the response.
    icici = next(i for i in body["items"] if i["id"] == "icici-emi-on-call")
    assert icici["typical_rate_pct"] == 18
    assert icici["fee_value"] == 2
    assert icici["fee_cap"] is None
    assert icici["foreclosure_pct"] == 3


async def test_version_endpoint(client):
    response = await client.get("/v1/catalog/version")
    assert response.status_code == 200
    assert response.json()["version"] > 0


async def test_non_admin_cannot_write(client, auth_headers):
    response = await client.post(
        "/v1/catalog/lenders", json=catalog_lender(), headers=auth_headers
    )
    assert response.status_code == 403
    assert response.json()["error"]["code"] == "forbidden"


async def test_write_requires_auth(client):
    response = await client.post("/v1/catalog/lenders", json=catalog_lender())
    assert response.status_code == 401


async def test_admin_upsert_bumps_version_and_appears_publicly(
    client, admin_auth_headers
):
    before = (await client.get("/v1/catalog/version")).json()["version"]

    created = await client.post(
        "/v1/catalog/lenders", json=catalog_lender(), headers=admin_auth_headers
    )
    assert created.status_code == 200
    assert created.json()["version"] > before

    # Re-upsert (edit) bumps the version again.
    edited = await client.post(
        "/v1/catalog/lenders",
        json=catalog_lender(name="Renamed Lender"),
        headers=admin_auth_headers,
    )
    assert edited.json()["version"] > created.json()["version"]
    assert edited.json()["name"] == "Renamed Lender"

    public = await client.get("/v1/catalog/lenders")
    match = [i for i in public.json()["items"] if i["id"] == "test-lender"]
    assert match and match[0]["name"] == "Renamed Lender"


async def test_admin_patch(client, admin_auth_headers):
    await client.post(
        "/v1/catalog/lenders", json=catalog_lender(), headers=admin_auth_headers
    )
    patched = await client.patch(
        "/v1/catalog/lenders/test-lender",
        json={"fee_value": 3.5},
        headers=admin_auth_headers,
    )
    assert patched.status_code == 200
    assert patched.json()["fee_value"] == 3.5


async def test_admin_delete_removes_from_public_list(client, admin_auth_headers):
    await client.post(
        "/v1/catalog/lenders", json=catalog_lender(), headers=admin_auth_headers
    )
    deleted = await client.delete(
        "/v1/catalog/lenders/test-lender", headers=admin_auth_headers
    )
    assert deleted.status_code == 204
    # Idempotent.
    again = await client.delete(
        "/v1/catalog/lenders/test-lender", headers=admin_auth_headers
    )
    assert again.status_code == 204

    public = await client.get("/v1/catalog/lenders")
    ids = [i["id"] for i in public.json()["items"]]
    assert "test-lender" not in ids


async def test_patch_missing_is_404(client, admin_auth_headers):
    response = await client.patch(
        "/v1/catalog/lenders/does-not-exist",
        json={"fee_value": 1.0},
        headers=admin_auth_headers,
    )
    assert response.status_code == 404
