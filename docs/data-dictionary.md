# Data Dictionary — Fit & Focus AI

| | |
|---|---|
| **Sprint** | Sprint 2 - Data Architecture (2.2) |
| **Related** | [ERD & Validation](erd.md) · [Analytics Model](analytics-model.md) · [API Design](api-design.md) |

**Database:** Tiger Data (PostgreSQL 13+) · **Time zone:** timestamps in UTC; "today" for scoring and overdue uses `America/Chicago`.

**Filled by:** 🧑 Student (form) · ⚙️ Planner engine (rules) · 🤖 Gemini (or fallback) · 🗄️ Database default · 🖥️ Backend

**Naming:** `snake_case`, plural table names, primary key `<entity>_id`, foreign key named after the referenced key.

---

## 1. `students`

Anonymous user. No personal data (DM-1).

| Column | Type | Null | Default | Rules | Filled by | API field | Example |
|--------|------|------|---------|-------|-----------|-----------|---------|
| `student_id` | UUID | No | — | PK. Created by the browser (`crypto.randomUUID()`) | 🖥️ from header `X-Student-Id` | — | `5b1c…e9` |
| `created_at` | TIMESTAMPTZ | No | `NOW()` | First request seen | 🗄️ | — | `2026-11-16T14:00:00Z` |

---

## 2. `assignments`

| Column | Type | Null | Default | Rules | Filled by | API field | Example |
|--------|------|------|---------|-------|-----------|-----------|---------|
| `assignment_id` | UUID | No | `gen_random_uuid()` | PK | 🗄️ | `id` | `a3f0…12` |
| `student_id` | UUID | No | — | FK → `students` (cascade) | 🖥️ | — | `5b1c…e9` |
| `course_name` | VARCHAR(50) | No | — | 1–50 characters | 🧑 | `course` | `COSC 1436` |
| `assignment_title` | VARCHAR(100) | No | — | 1–100 characters | 🧑 | `title` | `Programming Lab` |
| `assignment_type` | VARCHAR(10) | No | `'assignment'` | `assignment` or `exam` | 🧑 | `type` | `assignment` |
| `due_date` | DATE | No | — | Today or later **when submitted** (API rule) | 🧑 | `due_date` | `2026-11-18` |
| `difficulty` | SMALLINT | No | — | 1 (easy) – 5 (hard) | 🧑 | `difficulty` | `4` |
| `estimated_hours` | NUMERIC(3,1) | No | — | 0.5 – 40.0 | 🧑 | `estimated_hours` | `6.0` |
| `status` | VARCHAR(12) | No | `'pending'` | `pending`, `in_progress`, `completed` | 🧑 | `status` | `pending` |
| `completed_at` | TIMESTAMPTZ | Yes | `NULL` | Set when status becomes `completed`; cleared otherwise | 🖥️ | `completed_at` | `NULL` |
| `created_at` | TIMESTAMPTZ | No | `NOW()` | | 🗄️ | `created_at` | |
| `updated_at` | TIMESTAMPTZ | No | `NOW()` | Updated on every change | 🖥️ | — | |

**Calculated (not stored):** `is_overdue` = `status <> 'completed' AND due_date < today` → API field `is_overdue`.

---

## 3. `study_plans`

One row per **Generate Plan** click (DM-2).

| Column | Type | Null | Default | Rules | Filled by | API field | Example |
|--------|------|------|---------|-------|-----------|-----------|---------|
| `plan_id` | UUID | No | `gen_random_uuid()` | PK | 🗄️ | `id` | `c71d…40` |
| `student_id` | UUID | No | — | FK → `students` (cascade) | 🖥️ | — | `5b1c…e9` |
| `plan_date` | DATE | No | — | The "today" used for risk scoring | ⚙️ | `plan_date` | `2026-11-16` |
| `source` | VARCHAR(10) | No | — | `gemini` or `fallback` | 🖥️ | `source` | `gemini` |
| `ai_summary` | TEXT | No | — | Plain-language risk explanation, ≤ 2,000 characters | 🤖 | `risk_analysis` | `Your Programming Lab is high risk…` |
| `tips` | JSONB | No | `'[]'` | JSON array of 0–5 strings | 🤖 | `tips` | `["Start the lab today."]` |
| `warnings` | JSONB | No | `'[]'` | JSON array of strings (e.g. overload) | ⚙️ | `warnings` | `[]` |
| `created_at` | TIMESTAMPTZ | No | `NOW()` | | 🗄️ | `created_at` | |

**Calculated (not stored):**

| API field | Formula |
|-----------|---------|
| `summary.overall_risk_score` | `MAX(risk_analyses.risk_score)` for the plan |
| `summary.overall_risk_level` | Band of the overall score |
| `summary.total_tasks` | `COUNT(risk_analyses)` |
| `summary.total_pomodoros` | `SUM(risk_analyses.pomodoro_count)` |
| `summary.total_hours` | `total_pomodoros × 25 / 60` (1 decimal) |

---

## 4. `risk_analyses`

One row per assignment **in** a plan. Snapshot of the planner engine's result at plan time.

| Column | Type | Null | Default | Rules | Filled by | API field (`tasks[]`) | Example |
|--------|------|------|---------|-------|-----------|-----------------------|---------|
| `risk_id` | UUID | No | `gen_random_uuid()` | PK | 🗄️ | — | `e2a9…7b` |
| `plan_id` | UUID | No | — | FK → `study_plans` (cascade) | 🖥️ | — | `c71d…40` |
| `assignment_id` | UUID | No | — | FK → `assignments` (cascade) | 🖥️ | `id` | `a3f0…12` |
| `risk_score` | SMALLINT | No | — | 0 – 100 | ⚙️ | `risk_score` | `78` |
| `risk_level` | VARCHAR(6) | No | — | `low` 0–39, `medium` 40–69, `high` 70–100; must match score | ⚙️ | `risk_level`, `priority` | `high` |
| `priority_rank` | SMALLINT | No | — | ≥ 1; unique within a plan | ⚙️ | `rank` | `1` |
| `pomodoro_count` | SMALLINT | No | — | ≥ 1; `ceil(estimated_hours × 60 / 25)` | ⚙️ | `pomodoros` | `15` |
| `generated_at` | TIMESTAMPTZ | No | `NOW()` | | 🗄️ | — | |

**Unique:** (`plan_id`, `assignment_id`), (`plan_id`, `priority_rank`).

**Calculated (not stored):** `priority` = `risk_level`; `recommended_hours` = `pomodoro_count × 25 / 60`.

---

## 5. `schedule_blocks`

Pomodoros for one assignment on one day of a plan (DM-6).

| Column | Type | Null | Default | Rules | Filled by | API field (`daily_schedule[]`) | Example |
|--------|------|------|---------|-------|-----------|--------------------------------|---------|
| `block_id` | UUID | No | `gen_random_uuid()` | PK | 🗄️ | — | `9d3e…aa` |
| `plan_id` | UUID | No | — | FK (`plan_id`, `assignment_id`) → `risk_analyses` (cascade) | 🖥️ | — | `c71d…40` |
| `assignment_id` | UUID | No | — | Part of the FK above (assignment must be in the plan) | 🖥️ | `blocks[].assignment_id` | `a3f0…12` |
| `block_date` | DATE | No | — | Between `plan_date` and the due date (app rule) | 🤖 | `date` | `2026-11-16` |
| `pomodoros` | SMALLINT | No | — | 1 – 8; day total across assignments ≤ 8 (app rule) | 🤖 | `blocks[].pomodoros` | `3` |

**Unique:** (`plan_id`, `assignment_id`, `block_date`).

**Rule:** the sum of `pomodoros` per (`plan_id`, `assignment_id`) equals that row's `risk_analyses.pomodoro_count` (checked when validating Gemini's response).

---

## 6. `notifications`

| Column | Type | Null | Default | Rules | Filled by | API field | Example |
|--------|------|------|---------|-------|-----------|-----------|---------|
| `notification_id` | UUID | No | `gen_random_uuid()` | PK | 🗄️ | — | `1f5c…03` |
| `student_id` | UUID | No | — | FK → `students` (cascade) | 🖥️ | — | `5b1c…e9` |
| `plan_id` | UUID | Yes | — | FK → `study_plans` (set null). Null for future reminders | 🖥️ | `plan_id` | `c71d…40` |
| `channel` | VARCHAR(10) | No | `'discord'` | `discord` (others future) | 🖥️ | — | `discord` |
| `message` | TEXT | No | — | Text sent, ≤ 2,000 characters (Discord limit) | 🖥️ | — | `Weekly Focus Plan…` |
| `status` | VARCHAR(6) | No | — | `sent` or `failed` | 🖥️ | `sent` (true/false) | `sent` |
| `error` | TEXT | Yes | `NULL` | Error message when `failed`; never contains the webhook URL | 🖥️ | `detail` | `NULL` |
| `sent_at` | TIMESTAMPTZ | No | `NOW()` | | 🗄️ | — | |

---

## 7. Enumerations

| Name | Values | Used in |
|------|--------|---------|
| Assignment type | `assignment`, `exam` | `assignments.assignment_type` |
| Assignment status | `pending`, `in_progress`, `completed` (+ calculated *overdue*) | `assignments.status` |
| Risk level / priority | `low`, `medium`, `high` | `risk_analyses.risk_level` |
| Plan source | `gemini`, `fallback` | `study_plans.source` |
| Notification channel | `discord` | `notifications.channel` |
| Notification status | `sent`, `failed` | `notifications.status` |

Enumerations are `VARCHAR` with `CHECK` constraints (not PostgreSQL `ENUM` types) so values are easy to add later.

---

## 8. What Is Stored vs. Generated

| Data | Origin | Stored in |
|------|--------|-----------|
| Course, title, type, due date, difficulty, hours, status | 🧑 Student | `assignments` |
| Risk score, risk level, rank, Pomodoro count, warnings, plan date | ⚙️ Planner engine | `risk_analyses`, `study_plans` |
| Daily schedule, risk explanation, tips | 🤖 Gemini (or fallback) | `schedule_blocks`, `study_plans` |
| Student ID | 🖥️ Browser | `students` |
| Discord messages and delivery result | 🖥️ Backend | `notifications` |
| **Not stored:** raw Gemini prompt and response, API keys, webhook URL, form state | — | — |
