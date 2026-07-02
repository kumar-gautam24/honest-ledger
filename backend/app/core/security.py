"""Password hashing and token primitives.

- Passwords: argon2id (memory-hard, salted). We store only the hash.
- Access tokens: short-lived JWTs signed HS256 with our secret.
- Refresh tokens: opaque random secrets. The DB stores only a sha256 hash of
  them: the token itself is 256 bits of randomness (not a guessable password),
  so a fast hash is enough — its only job is to make a stolen DB useless.
"""

import hashlib
import secrets
import uuid
from datetime import datetime, timedelta, timezone

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError

from app.core.errors import InvalidTokenError

_hasher = PasswordHasher()


def hash_password(password: str) -> str:
    return _hasher.hash(password)


def verify_password(password: str, password_hash: str) -> bool:
    try:
        _hasher.verify(password_hash, password)
        return True
    except VerifyMismatchError:
        return False


def create_access_token(user_id: uuid.UUID, secret: str, ttl_minutes: int) -> str:
    now = datetime.now(timezone.utc)
    claims = {
        "sub": str(user_id),
        "type": "access",
        "iat": now,
        "exp": now + timedelta(minutes=ttl_minutes),
    }
    return jwt.encode(claims, secret, algorithm="HS256")


def decode_access_token(token: str, secret: str) -> uuid.UUID:
    try:
        claims = jwt.decode(token, secret, algorithms=["HS256"])
    except jwt.PyJWTError:
        raise InvalidTokenError("Access token is invalid or expired")
    if claims.get("type") != "access":
        raise InvalidTokenError("Not an access token")
    return uuid.UUID(claims["sub"])


def new_refresh_token() -> tuple[str, str]:
    """Return (raw_token, token_hash). Client gets raw; DB stores only the hash."""
    raw = secrets.token_urlsafe(32)
    return raw, hash_refresh_token(raw)


def hash_refresh_token(raw: str) -> str:
    return hashlib.sha256(raw.encode()).hexdigest()
