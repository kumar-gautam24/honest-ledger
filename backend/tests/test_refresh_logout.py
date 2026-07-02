REGISTER = {"email": "rot@example.com", "password": "longenough1"}


async def _token_pair(client) -> dict:
    await client.post("/v1/auth/register", json=REGISTER)
    response = await client.post("/v1/auth/login", json=REGISTER)
    return response.json()


async def test_refresh_rotates_the_token(client):
    pair = await _token_pair(client)

    response = await client.post(
        "/v1/auth/refresh", json={"refresh_token": pair["refresh_token"]}
    )
    assert response.status_code == 200
    new_pair = response.json()
    assert new_pair["refresh_token"] != pair["refresh_token"]

    # Rotation: the OLD refresh token is now dead.
    response = await client.post(
        "/v1/auth/refresh", json={"refresh_token": pair["refresh_token"]}
    )
    assert response.status_code == 401


async def test_reusing_a_rotated_token_kills_the_whole_family(client):
    pair = await _token_pair(client)
    response = await client.post(
        "/v1/auth/refresh", json={"refresh_token": pair["refresh_token"]}
    )
    stolen_replay_target = response.json()["refresh_token"]

    # Attacker replays the already-used token...
    await client.post("/v1/auth/refresh", json={"refresh_token": pair["refresh_token"]})

    # ...so even the LEGITIMATE newest token must now be revoked (theft response).
    response = await client.post(
        "/v1/auth/refresh", json={"refresh_token": stolen_replay_target}
    )
    assert response.status_code == 401


async def test_refresh_with_garbage_is_401(client):
    response = await client.post("/v1/auth/refresh", json={"refresh_token": "junk"})
    assert response.status_code == 401


async def test_logout_revokes_the_refresh_token(client):
    pair = await _token_pair(client)
    response = await client.post(
        "/v1/auth/logout", json={"refresh_token": pair["refresh_token"]}
    )
    assert response.status_code == 204

    response = await client.post(
        "/v1/auth/refresh", json={"refresh_token": pair["refresh_token"]}
    )
    assert response.status_code == 401
