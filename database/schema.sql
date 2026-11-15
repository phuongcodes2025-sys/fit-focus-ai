-- Fit & Focus AI schema (Tiger Data / PostgreSQL 13+)
-- Documentation: docs/erd.md, docs/data-dictionary.md, docs/analytics-model.md

-- Anonymous user; the ID is created in the browser (no personal data)
CREATE TABLE IF NOT EXISTS students (
    student_id  UUID        PRIMARY KEY,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS assignments (
    assignment_id     UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id        UUID         NOT NULL REFERENCES students (student_id) ON DELETE CASCADE,
    course_name       VARCHAR(50)  NOT NULL CHECK (char_length(course_name) >= 1),
    assignment_title  VARCHAR(100) NOT NULL CHECK (char_length(assignment_title) >= 1),
    assignment_type   VARCHAR(10)  NOT NULL DEFAULT 'assignment' CHECK (assignment_type IN ('assignment', 'exam')),
    due_date          DATE         NOT NULL,
    difficulty        SMALLINT     NOT NULL CHECK (difficulty BETWEEN 1 AND 5),
    estimated_hours   NUMERIC(3,1) NOT NULL CHECK (estimated_hours BETWEEN 0.5 AND 40),
    status            VARCHAR(12)  NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed')),
    completed_at      TIMESTAMPTZ,
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CHECK ((status = 'completed') = (completed_at IS NOT NULL))
);

CREATE INDEX IF NOT EXISTS idx_assignments_student ON assignments (student_id);

-- One row per "Generate Plan" click
CREATE TABLE IF NOT EXISTS study_plans (
    plan_id     UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id  UUID        NOT NULL REFERENCES students (student_id) ON DELETE CASCADE,
    plan_date   DATE        NOT NULL,
    source      VARCHAR(10) NOT NULL CHECK (source IN ('gemini', 'fallback')),
    ai_summary  TEXT        NOT NULL CHECK (char_length(ai_summary) <= 2000),
    tips        JSONB       NOT NULL DEFAULT '[]' CHECK (jsonb_typeof(tips) = 'array'),
    warnings    JSONB       NOT NULL DEFAULT '[]' CHECK (jsonb_typeof(warnings) = 'array'),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_study_plans_student_created ON study_plans (student_id, created_at DESC);

-- One row per assignment in a plan (snapshot of the planner engine result)
CREATE TABLE IF NOT EXISTS risk_analyses (
    risk_id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_id         UUID        NOT NULL REFERENCES study_plans (plan_id) ON DELETE CASCADE,
    assignment_id   UUID        NOT NULL REFERENCES assignments (assignment_id) ON DELETE CASCADE,
    risk_score      SMALLINT    NOT NULL CHECK (risk_score BETWEEN 0 AND 100),
    risk_level      VARCHAR(6)  NOT NULL,
    priority_rank   SMALLINT    NOT NULL CHECK (priority_rank >= 1),
    pomodoro_count  SMALLINT    NOT NULL CHECK (pomodoro_count >= 1),
    generated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (plan_id, assignment_id),
    UNIQUE (plan_id, priority_rank),
    -- risk_level must match the score band
    CHECK (
        (risk_level = 'low'    AND risk_score BETWEEN 0  AND 39) OR
        (risk_level = 'medium' AND risk_score BETWEEN 40 AND 69) OR
        (risk_level = 'high'   AND risk_score BETWEEN 70 AND 100)
    )
);

CREATE INDEX IF NOT EXISTS idx_risk_analyses_assignment_latest ON risk_analyses (assignment_id, generated_at DESC);

-- Pomodoros for one assignment on one day of a plan
CREATE TABLE IF NOT EXISTS schedule_blocks (
    block_id       UUID     PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_id        UUID     NOT NULL,
    assignment_id  UUID     NOT NULL,
    block_date     DATE     NOT NULL,
    pomodoros      SMALLINT NOT NULL CHECK (pomodoros BETWEEN 1 AND 8),
    UNIQUE (plan_id, assignment_id, block_date),
    -- the assignment must be part of the plan
    FOREIGN KEY (plan_id, assignment_id) REFERENCES risk_analyses (plan_id, assignment_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_schedule_blocks_date ON schedule_blocks (block_date);

CREATE TABLE IF NOT EXISTS notifications (
    notification_id  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id       UUID        NOT NULL REFERENCES students (student_id) ON DELETE CASCADE,
    plan_id          UUID        REFERENCES study_plans (plan_id) ON DELETE SET NULL,
    channel          VARCHAR(10) NOT NULL DEFAULT 'discord' CHECK (channel IN ('discord')),
    message          TEXT        NOT NULL CHECK (char_length(message) <= 2000),
    status           VARCHAR(6)  NOT NULL CHECK (status IN ('sent', 'failed')),
    error            TEXT,
    sent_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_student ON notifications (student_id);
CREATE INDEX IF NOT EXISTS idx_notifications_plan ON notifications (plan_id);
