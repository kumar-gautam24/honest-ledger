import time

from app.core.rate_limit import SlidingWindowRateLimiter


def test_limiter_allows_up_to_max_then_blocks():
    limiter = SlidingWindowRateLimiter(max_requests=3, window_seconds=60)
    assert limiter.allow("1.2.3.4") is True
    assert limiter.allow("1.2.3.4") is True
    assert limiter.allow("1.2.3.4") is True
    assert limiter.allow("1.2.3.4") is False


def test_limiter_keys_are_independent():
    limiter = SlidingWindowRateLimiter(max_requests=1, window_seconds=60)
    assert limiter.allow("1.1.1.1") is True
    assert limiter.allow("2.2.2.2") is True


def test_limiter_window_slides():
    limiter = SlidingWindowRateLimiter(max_requests=1, window_seconds=0.05)
    assert limiter.allow("k") is True
    assert limiter.allow("k") is False
    time.sleep(0.06)
    assert limiter.allow("k") is True


async def test_auth_endpoints_return_429_when_hammered(client):
    # App default: 10 requests / 60s per IP across auth endpoints.
    for _ in range(10):
        await client.post(
            "/v1/auth/login", json={"email": "x@example.com", "password": "wrongwrong1"}
        )
    response = await client.post(
        "/v1/auth/login", json={"email": "x@example.com", "password": "wrongwrong1"}
    )
    assert response.status_code == 429
    assert response.json()["error"]["code"] == "rate_limited"
