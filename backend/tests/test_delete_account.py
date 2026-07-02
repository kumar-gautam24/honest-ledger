REGISTER = {"email": "bye@example.com", "password": "longenough1"}


async def test_delete_account(client):
    await client.post("/v1/auth/register", json=REGISTER)
    login = await client.post("/v1/auth/login", json=REGISTER)
    headers = {"Authorization": f"Bearer {login.json()['access_token']}"}

    response = await client.delete("/v1/me", headers=headers)
    assert response.status_code == 204

    # The account is gone: login fails, and the old (still-unexpired) access
    # token dies at the /me user lookup.
    response = await client.post("/v1/auth/login", json=REGISTER)
    assert response.status_code == 401
    response = await client.get("/v1/me", headers=headers)
    assert response.status_code == 401


async def test_delete_account_requires_auth(client):
    response = await client.delete("/v1/me")
    assert response.status_code == 401
