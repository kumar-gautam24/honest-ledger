"""AI-specific dependencies. Shared ones live in app/core/dependencies.py."""

import uuid

from fastapi import Depends, Request

from app.core.dependencies import get_current_user_id
from app.core.errors import RateLimitedError


async def check_ai_rate_limit(
    request: Request,
    user_id: uuid.UUID = Depends(get_current_user_id),
) -> uuid.UUID:
    """Per-USER throttle on the shared paid model key.

    Keyed on the authenticated user id (not the IP) — a reverse proxy can only see
    the IP, so this is the layer that actually stops one account from draining the
    key. Runs after `get_current_user_id`, so unauthenticated calls are rejected
    before they ever count against a limit."""
    if not request.app.state.ai_limiter.allow(str(user_id)):
        raise RateLimitedError("Too many AI requests, please slow down")
    return user_id
