"""Repository-level truths: idempotent insert, atomic LWW, tombstones, seq."""

import uuid
from datetime import datetime, timedelta, timezone

from app.auth import repository as auth_repository
from app.borrowings import repository

NOW = datetime.now(timezone.utc)


def _data(**overrides) -> dict:
    data = {
        "id": uuid.uuid4(),
        "title": "Slice loan",
        "kind": "flexibleLoan",
        "lender_id": None,
        "lender_name": "Slice",
        "principal_paise": 500000,
        "processing_fee_paise": 0,
        "gst_on_fee_paise": 0,
        "foreclosure_fee_paise": None,
        "gst_on_interest": False,
        "interest_rate_pct": 36.0,
        "rate_type": "reducing",
        "tenure_months": 6,
        "min_payment_paise": 0,
        "start_date": NOW,
        "status": "active",
        "notes": None,
        "created_at": NOW,
        "updated_at": NOW,
    }
    data.update(overrides)
    return data


async def _user(pool, email="repo@example.com"):
    row = await auth_repository.create_user(pool, email, "hash")
    return row["id"]


async def test_insert_is_idempotent_on_id(pool):
    user_id = await _user(pool)
    data = _data()
    first = await repository.insert_borrowing(pool, user_id, data)
    assert first["server_seq"] > 0
    replay = await repository.insert_borrowing(pool, user_id, data)
    assert replay is None  # conflict -> caller decides (200 vs 409)


async def test_lww_update_applies_only_newer(pool):
    user_id = await _user(pool)
    data = _data()
    await repository.insert_borrowing(pool, user_id, data)

    newer = NOW + timedelta(seconds=5)
    updated = await repository.update_borrowing(
        pool, user_id, data["id"], newer, {"title": "renamed"}
    )
    assert updated["title"] == "renamed"
    assert updated["server_seq"] > 0

    older = NOW - timedelta(seconds=5)
    stale = await repository.update_borrowing(
        pool, user_id, data["id"], older, {"title": "should lose"}
    )
    assert stale is None
    current = await repository.get_borrowing(pool, user_id, data["id"])
    assert current["title"] == "renamed"


async def test_update_bumps_server_seq(pool):
    user_id = await _user(pool)
    data = _data()
    created = await repository.insert_borrowing(pool, user_id, data)
    updated = await repository.update_borrowing(
        pool, user_id, data["id"], NOW + timedelta(seconds=1), {"status": "closed"}
    )
    assert updated["server_seq"] > created["server_seq"]


async def test_tombstone_lifecycle(pool):
    user_id = await _user(pool)
    data = _data()
    await repository.insert_borrowing(pool, user_id, data)

    assert await repository.tombstone_borrowing(pool, user_id, data["id"]) == "deleted"
    assert await repository.tombstone_borrowing(pool, user_id, data["id"]) == "already"
    assert await repository.tombstone_borrowing(pool, user_id, uuid.uuid4()) is None

    assert await repository.get_borrowing(pool, user_id, data["id"]) is None
    ghost = await repository.get_borrowing(pool, user_id, data["id"], include_deleted=True)
    assert ghost["deleted_at"] is not None
    assert await repository.list_borrowings(pool, user_id, 0, 50) == []


async def test_user_isolation(pool):
    alice = await _user(pool, "alice@example.com")
    bob = await _user(pool, "bob@example.com")
    data = _data()
    await repository.insert_borrowing(pool, alice, data)

    assert await repository.get_borrowing(pool, bob, data["id"]) is None
    assert await repository.update_borrowing(
        pool, bob, data["id"], NOW + timedelta(days=1), {"title": "stolen"}
    ) is None
    assert await repository.tombstone_borrowing(pool, bob, data["id"]) is None
    assert await repository.list_borrowings(pool, bob, 0, 50) == []
