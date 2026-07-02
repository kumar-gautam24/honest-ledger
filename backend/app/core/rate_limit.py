"""In-process sliding-window rate limiter.

Honest limitation, on purpose: this lives in ONE process's memory. It resets on
restart and is not shared between multiple instances behind a load balancer.
Good enough for a single container; B4 replaces the storage with Redis so all
instances share one view. The interface stays the same — only storage changes.
"""

import time
from collections import defaultdict, deque


class SlidingWindowRateLimiter:
    def __init__(self, max_requests: int, window_seconds: float):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self._hits: dict[str, deque[float]] = defaultdict(deque)

    def allow(self, key: str) -> bool:
        now = time.monotonic()
        hits = self._hits[key]
        # Drop timestamps that have slid out of the window.
        while hits and now - hits[0] >= self.window_seconds:
            hits.popleft()
        if len(hits) >= self.max_requests:
            return False
        hits.append(now)
        return True
