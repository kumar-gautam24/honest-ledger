"""Auth-specific dependencies. Shared ones live in app/core/dependencies.py."""

from fastapi import Request

from app.core.errors import RateLimitedError


async def check_auth_rate_limit(request: Request) -> None:
    """Router-level guard for credential endpoints (brute-force protection)."""
    if request.client is not None:
        key = request.client.host
    else:
        key = "unknown"
    if not request.app.state.auth_limiter.allow(key):
        raise RateLimitedError("Too many attempts, please try again soon")
