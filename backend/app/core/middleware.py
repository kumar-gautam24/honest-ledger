"""HTTP middleware — the layer that wraps EVERY request/response.

Two things every request gets, uniformly, regardless of route:

  1. CORS — lets browser clients (Flutter web, etc.) call the API cross-origin.
     Native mobile ignores CORS, but the header costs nothing and unblocks the web.
  2. A request id + one structured access log line. The id is bound into structlog's
     contextvars so EVERY log emitted while handling the request carries it (trace a
     request end-to-end), and it is echoed back in the `X-Request-ID` response header.

Ordering note: middleware added last is outermost. We add CORS first and the logging
middleware second, so logging wraps the whole request — its timing includes everything.
"""

import time
import uuid

import structlog
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import Settings
from app.core.logging import get_logger

_log = get_logger("app.request")


def register_middleware(app: FastAPI, settings: Settings) -> None:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins_list,
        # We authenticate with a bearer token, not cookies, so credentials are off;
        # that is what lets allow_origins="*" be safe.
        allow_credentials=False,
        allow_methods=["*"],
        allow_headers=["*"],
        expose_headers=["X-Request-ID"],
    )

    @app.middleware("http")
    async def access_log(request: Request, call_next):
        request_id = uuid.uuid4().hex[:12]
        structlog.contextvars.bind_contextvars(request_id=request_id)
        start = time.perf_counter()
        try:
            response = await call_next(request)
        except Exception:
            # Unhandled error (a real 500). Log it, then re-raise so Starlette's
            # server-error handling still runs. Handled AppErrors never reach here —
            # the exception handler converts them to a normal response first.
            duration_ms = round((time.perf_counter() - start) * 1000, 2)
            _log.error(
                "http.request",
                method=request.method,
                path=request.url.path,
                status_code=500,
                duration_ms=duration_ms,
            )
            structlog.contextvars.clear_contextvars()
            raise

        duration_ms = round((time.perf_counter() - start) * 1000, 2)
        _log.info(
            "http.request",
            method=request.method,
            path=request.url.path,
            status_code=response.status_code,
            duration_ms=duration_ms,
        )
        response.headers["X-Request-ID"] = request_id
        structlog.contextvars.clear_contextvars()
        return response
