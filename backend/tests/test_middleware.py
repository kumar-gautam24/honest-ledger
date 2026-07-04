"""CORS + request-id/access-log middleware, exercised over the real app."""

import httpx
import pytest

from app.main import create_app


@pytest.fixture
async def bare_client():
    # These middleware behaviours don't touch the DB, so no pool is needed.
    app = create_app()
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as c:
        yield c


async def test_every_response_carries_a_request_id(bare_client):
    response = await bare_client.get("/health")
    assert response.status_code == 200
    request_id = response.headers.get("x-request-id")
    assert request_id is not None and len(request_id) == 12


async def test_request_ids_are_unique_per_request(bare_client):
    first = (await bare_client.get("/health")).headers["x-request-id"]
    second = (await bare_client.get("/health")).headers["x-request-id"]
    assert first != second


async def test_cors_headers_present_for_browser_origin(bare_client):
    response = await bare_client.get(
        "/health", headers={"Origin": "https://app.example.com"}
    )
    assert response.status_code == 200
    # allow_origins="*" echoes "*"; the header being present is what unblocks browsers.
    assert response.headers.get("access-control-allow-origin") == "*"


async def test_cors_preflight_is_answered(bare_client):
    response = await bare_client.options(
        "/v1/borrowings",
        headers={
            "Origin": "https://app.example.com",
            "Access-Control-Request-Method": "POST",
        },
    )
    assert response.status_code == 200
    assert "access-control-allow-origin" in response.headers
