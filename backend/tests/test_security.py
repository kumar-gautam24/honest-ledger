"""Pure crypto helpers: password hashing and tokens. No DB needed."""

import uuid

import pytest

from app.core.errors import InvalidTokenError
from app.core.security import (
    create_access_token,
    decode_access_token,
    hash_password,
    hash_refresh_token,
    new_refresh_token,
    verify_password,
)

SECRET = "test-secret"
USER_ID = uuid.uuid4()


def test_password_hash_roundtrip():
    password_hash = hash_password("hunter2boogaloo")
    assert password_hash != "hunter2boogaloo"  # never stored in plaintext
    assert verify_password("hunter2boogaloo", password_hash) is True
    assert verify_password("wrong-password", password_hash) is False


def test_same_password_hashes_differently():
    # argon2 salts every hash: equal passwords must NOT produce equal hashes.
    assert hash_password("same") != hash_password("same")


def test_access_token_roundtrip():
    token = create_access_token(USER_ID, SECRET, ttl_minutes=15)
    assert decode_access_token(token, SECRET) == USER_ID


def test_expired_access_token_rejected():
    token = create_access_token(USER_ID, SECRET, ttl_minutes=-1)
    with pytest.raises(InvalidTokenError):
        decode_access_token(token, SECRET)


def test_tampered_access_token_rejected():
    token = create_access_token(USER_ID, SECRET, ttl_minutes=15)
    with pytest.raises(InvalidTokenError):
        decode_access_token(token, "a-different-secret")


def test_refresh_token_pair():
    raw, token_hash = new_refresh_token()
    assert raw != token_hash                      # what the client holds vs what we store
    assert hash_refresh_token(raw) == token_hash  # deterministic lookup hash
    assert new_refresh_token()[0] != raw          # random every time
