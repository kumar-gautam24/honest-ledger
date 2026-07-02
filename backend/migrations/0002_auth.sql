-- 0002_auth: users + refresh token sessions.
-- citext = case-insensitive text, so Foo@Bar.com and foo@bar.com are one account.
CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE users (
    id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email         citext UNIQUE NOT NULL,
    -- argon2 hash, never the password. NOT NULL for now; when Google OAuth
    -- arrives, a migration will relax this for OAuth-only accounts.
    password_hash text NOT NULL,
    created_at    timestamptz NOT NULL DEFAULT now(),
    updated_at    timestamptz NOT NULL DEFAULT now()
);

-- One row per issued refresh token ("session"). We store only a sha256 hash of
-- the token; revoked_at is our kill switch (rotation, logout, password change).
CREATE TABLE refresh_tokens (
    id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    token_hash text UNIQUE NOT NULL,
    expires_at timestamptz NOT NULL,
    revoked_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX refresh_tokens_user_id_idx ON refresh_tokens (user_id);
