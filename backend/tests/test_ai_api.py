"""API tests for the /v1/ai/chat proxy.

These run against the default `fake` provider, so no network or model key is needed.
They prove the plumbing: auth is required, the normalized request/response contract
holds, tool schemas pass through, and the per-user rate limit trips.
"""

import httpx

from app.core.rate_limit import SlidingWindowRateLimiter
from app.main import create_app


async def test_chat_requires_auth(client):
    resp = await client.post(
        "/v1/ai/chat", json={"messages": [{"role": "user", "content": "hi"}]}
    )
    assert resp.status_code == 401
    assert resp.json()["error"]["code"] == "invalid_token"


async def test_chat_round_trips_via_fake_provider(client, auth_headers):
    resp = await client.post(
        "/v1/ai/chat",
        headers=auth_headers,
        json={"messages": [{"role": "user", "content": "what do I owe?"}]},
    )
    assert resp.status_code == 200
    body = resp.json()
    assert "what do I owe?" in (body["text"] or "")
    assert body["tool_calls"] == []
    assert body["usage"] is not None


async def test_chat_accepts_tools_and_history(client, auth_headers):
    resp = await client.post(
        "/v1/ai/chat",
        headers=auth_headers,
        json={
            "system": "You are a finance assistant.",
            "messages": [
                {"role": "user", "content": "hello"},
                {"role": "assistant", "content": "hi, how can I help?"},
                {"role": "user", "content": "list my cards"},
            ],
            "tools": [
                {
                    "name": "list_cards",
                    "description": "List the user's cards",
                    "parameters": {"type": "object", "properties": {}},
                }
            ],
        },
    )
    assert resp.status_code == 200
    assert "list my cards" in (resp.json()["text"] or "")


async def test_chat_rejects_empty_messages(client, auth_headers):
    resp = await client.post("/v1/ai/chat", headers=auth_headers, json={"messages": []})
    assert resp.status_code == 422


async def test_chat_is_rate_limited_per_user(session_pool):
    """Second call from the same user trips the limiter (max_requests=1 here)."""
    await session_pool.execute("TRUNCATE users CASCADE")
    app = create_app()
    app.state.pool = session_pool
    app.state.ai_limiter = SlidingWindowRateLimiter(max_requests=1, window_seconds=60)

    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as c:
        creds = {"email": "ai-rl@example.com", "password": "longenough1"}
        await c.post("/v1/auth/register", json=creds)
        login = await c.post("/v1/auth/login", json=creds)
        headers = {"Authorization": f"Bearer {login.json()['access_token']}"}
        body = {"messages": [{"role": "user", "content": "hi"}]}

        first = await c.post("/v1/ai/chat", json=body, headers=headers)
        second = await c.post("/v1/ai/chat", json=body, headers=headers)

    assert first.status_code == 200
    assert second.status_code == 429
    assert second.json()["error"]["code"] == "rate_limited"
