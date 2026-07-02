import uuid

from app.core.config import get_settings
from app.core.security import create_access_token

REGISTER = {"email": "me@example.com", "password": "longenough1"}


async def _login(client) -> str:
    await client.post("/v1/auth/register", json=REGISTER)
    response = await client.post("/v1/auth/login", json=REGISTER)
    return response.json()["access_token"]


async def test_me_returns_current_user(client):
    token = await _login(client)
    response = await client.get("/v1/me", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert response.json()["email"] == REGISTER["email"]


async def test_me_without_token_is_401(client):
    response = await client.get("/v1/me")
    assert response.status_code == 401
    assert response.json()["error"]["code"] == "invalid_token"


async def test_me_with_garbage_token_is_401(client):
    response = await client.get(
        "/v1/me", headers={"Authorization": "Bearer not.a.jwt"}
    )
    assert response.status_code == 401


async def test_me_with_expired_token_is_401(client):
    expired = create_access_token(
        uuid.uuid4(), get_settings().jwt_secret, ttl_minutes=-1
    )
    response = await client.get(
        "/v1/me", headers={"Authorization": f"Bearer {expired}"}
    )
    assert response.status_code == 401
