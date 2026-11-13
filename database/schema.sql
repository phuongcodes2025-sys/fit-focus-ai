-- Fit & Focus AI schema (Tiger Data / PostgreSQL)

CREATE TABLE IF NOT EXISTS plans (
    id          SERIAL PRIMARY KEY,
    plan_type   TEXT        NOT NULL CHECK (plan_type IN ('study', 'meal')),
    input       JSONB       NOT NULL,
    result      JSONB       NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_plans_type_created ON plans (plan_type, created_at DESC);
