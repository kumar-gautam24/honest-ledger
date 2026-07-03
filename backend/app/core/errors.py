"""Application errors -> the one error envelope every endpoint uses.

Any expected failure raises an AppError subclass; a single exception handler
(registered in main.py) renders it as {"error": {"code": ..., "message": ...}}.
Routes and services never build error JSON by hand.
"""


class AppError(Exception):
    status_code = 500
    code = "internal_error"

    def __init__(self, message: str, details: dict | None = None):
        self.message = message
        self.details = details
        super().__init__(message)


class EmailTakenError(AppError):
    status_code = 409
    code = "email_taken"


class InvalidCredentialsError(AppError):
    status_code = 401
    code = "invalid_credentials"


class InvalidTokenError(AppError):
    status_code = 401
    code = "invalid_token"


class RateLimitedError(AppError):
    status_code = 429
    code = "rate_limited"


class NotFoundError(AppError):
    status_code = 404
    code = "not_found"


class StaleUpdateError(AppError):
    status_code = 409
    code = "stale_update"


class IdConflictError(AppError):
    status_code = 409
    code = "id_conflict"
