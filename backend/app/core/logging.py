"""Structured (JSON) logging via structlog.

Free-text logs are hard to search and aggregate. structlog emits each log as a JSON
object with consistent fields (timestamp, level, event, plus any key/values you add),
which log dashboards can filter and chart. We configure it once at startup.
"""

import logging

import structlog


def configure_logging(log_level: str) -> None:
    level = getattr(logging, log_level.upper(), logging.INFO)

    # Route stdlib logging (uvicorn, asyncpg, etc.) through the same level.
    logging.basicConfig(format="%(message)s", level=level)

    structlog.configure(
        processors=[
            structlog.contextvars.merge_contextvars,
            structlog.processors.add_log_level,
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.StackInfoRenderer(),
            structlog.processors.format_exc_info,
            structlog.processors.JSONRenderer(),
        ],
        wrapper_class=structlog.make_filtering_bound_logger(level),
        logger_factory=structlog.PrintLoggerFactory(),
        cache_logger_on_first_use=True,
    )


def get_logger(*args, **kwargs) -> structlog.stdlib.BoundLogger:
    return structlog.get_logger(*args, **kwargs)
