async def test_register_creates_account(client):
    response = await client.post(
        "/v1/auth/register",
        json={"email": "new@example.com", "password": "longenough1"},
    )
    assert response.status_code == 201
    body = response.json()
    assert body["email"] == "new@example.com"
    assert "id" in body
    assert "password" not in body and "password_hash" not in body


async def test_register_duplicate_email_is_409(client):
    payload = {"email": "dup@example.com", "password": "longenough1"}
    await client.post("/v1/auth/register", json=payload)
    response = await client.post("/v1/auth/register", json=payload)
    assert response.status_code == 409
    assert response.json()["error"]["code"] == "email_taken"


async def test_register_invalid_email_is_422(client):
    response = await client.post(
        "/v1/auth/register", json={"email": "not-an-email", "password": "longenough1"}
    )
    assert response.status_code == 422
    assert response.json()["error"]["code"] == "validation_error"


async def test_register_short_password_is_422(client):
    response = await client.post(
        "/v1/auth/register", json={"email": "ok@example.com", "password": "short"}
    )
    assert response.status_code == 422
