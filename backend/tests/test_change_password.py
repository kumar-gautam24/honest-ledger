REGISTER = {"email": "cp@example.com", "password": "oldpassword1"}


async def _login_pair(client) -> dict:
    await client.post("/v1/auth/register", json=REGISTER)
    response = await client.post("/v1/auth/login", json=REGISTER)
    return response.json()


async def test_change_password_flow(client):
    pair = await _login_pair(client)
    headers = {"Authorization": f"Bearer {pair['access_token']}"}

    response = await client.post(
        "/v1/me/change-password",
        headers=headers,
        json={"current_password": "oldpassword1", "new_password": "newpassword1"},
    )
    assert response.status_code == 204

    # Old password dead, new password works.
    response = await client.post("/v1/auth/login", json=REGISTER)
    assert response.status_code == 401
    response = await client.post(
        "/v1/auth/login",
        json={"email": REGISTER["email"], "password": "newpassword1"},
    )
    assert response.status_code == 200

    # All refresh tokens were revoked (a password change locks everyone out).
    response = await client.post(
        "/v1/auth/refresh", json={"refresh_token": pair["refresh_token"]}
    )
    assert response.status_code == 401


async def test_change_password_wrong_current_is_401(client):
    pair = await _login_pair(client)
    response = await client.post(
        "/v1/me/change-password",
        headers={"Authorization": f"Bearer {pair['access_token']}"},
        json={"current_password": "not-the-password", "new_password": "newpassword1"},
    )
    assert response.status_code == 401


async def test_change_password_requires_auth(client):
    response = await client.post(
        "/v1/me/change-password",
        json={"current_password": "x", "new_password": "newpassword1"},
    )
    assert response.status_code == 401
