REGISTER = {"email": "user@example.com", "password": "longenough1"}


async def test_login_returns_token_pair(client):
    await client.post("/v1/auth/register", json=REGISTER)
    response = await client.post("/v1/auth/login", json=REGISTER)
    assert response.status_code == 200
    body = response.json()
    assert body["token_type"] == "bearer"
    assert body["access_token"] != body["refresh_token"]


async def test_login_wrong_password_is_401(client):
    await client.post("/v1/auth/register", json=REGISTER)
    response = await client.post(
        "/v1/auth/login", json={"email": REGISTER["email"], "password": "wrong-pass1"}
    )
    assert response.status_code == 401
    assert response.json()["error"]["code"] == "invalid_credentials"


async def test_login_unknown_email_same_error_as_wrong_password(client):
    # Anti-enumeration: attacker must not learn which emails have accounts.
    response = await client.post(
        "/v1/auth/login", json={"email": "ghost@example.com", "password": "whatever1"}
    )
    assert response.status_code == 401
    assert response.json()["error"]["code"] == "invalid_credentials"
