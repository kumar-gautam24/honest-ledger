"""Summary SQL: a lightweight cross-device rollup over the user's live rows.

This is NOT the app's authoritative "wasted" figure — that includes modeled interest
which lives in the client domain layer. These are only the directly-recorded numbers,
aggregated in Postgres over non-deleted rows. COALESCE guards the empty-set case so a
fresh user gets zeros, not nulls.
"""

import uuid

import asyncpg


async def get_summary(pool: asyncpg.Pool, user_id: uuid.UUID) -> dict:
    borrowings = await pool.fetchrow(
        """
        SELECT
            COALESCE(SUM(principal_paise), 0) AS total_borrowed_paise,
            COALESCE(SUM(
                processing_fee_paise + gst_on_fee_paise
                + COALESCE(foreclosure_fee_paise, 0)
            ), 0) AS total_fees_paise,
            COUNT(*) AS borrowings_count,
            COUNT(*) FILTER (WHERE status = 'active') AS active_borrowings_count
        FROM borrowings
        WHERE user_id = $1 AND deleted_at IS NULL
        """,
        user_id,
    )
    total_repaid = await pool.fetchval(
        """
        SELECT COALESCE(SUM(amount_paise), 0)
        FROM repayments
        WHERE user_id = $1 AND deleted_at IS NULL
        """,
        user_id,
    )
    return {
        "total_borrowed_paise": borrowings["total_borrowed_paise"],
        "total_fees_paise": borrowings["total_fees_paise"],
        "total_repaid_paise": total_repaid,
        "borrowings_count": borrowings["borrowings_count"],
        "active_borrowings_count": borrowings["active_borrowings_count"],
    }
