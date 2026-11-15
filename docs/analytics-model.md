# Analytics Model — Fit & Focus AI

| | |
|---|---|
| **Sprint** | Sprint 2 - Data Architecture (2.4) |
| **Used in** | Sprint 9 - Dashboard (`GET /api/dashboard`) |
| **Related** | [ERD & Validation](erd.md) · [Data Dictionary](data-dictionary.md) · [Wireframes — Dashboard](wireframes.md#screen-3--dashboard) |

All metrics are **per student** (filtered by `student_id`).

---

## 1. Core Rule — "Latest Analysis per Assignment"

Because risk history is kept (Option B), an assignment that was regenerated 3 times has 3 `risk_analyses` rows. Adding them all would count it 3 times.

**Rule:** KPIs that describe the student's *current* situation use only the **most recent** `risk_analyses` row for each assignment (latest `generated_at`). In this document this set is called **Latest Analyses**. Trend charts use the full history.

```text
Assignment "Programming Lab"
   ├── plan v1 → risk 62   (history only)
   ├── plan v2 → risk 70   (history only)
   └── plan v3 → risk 78   ← Latest Analysis (used by KPIs)
```

---

## 2. KPIs

| # | KPI | Definition | Formula | Source | Dashboard |
|---|-----|------------|---------|--------|-----------|
| K1 | **Average Risk Score** | Average current risk of assignments not yet completed | `AVG(risk_score)` over Latest Analyses where `status <> 'completed'`, rounded | `risk_analyses`, `assignments` | "Avg risk" tile |
| K2 | **Assignments by Risk Level** | Count of not-completed assignments per level | `COUNT(*)` grouped by `risk_level` over Latest Analyses where `status <> 'completed'` | `risk_analyses`, `assignments` | Risk distribution |
| K3 | **Completed Assignments** | Share of assignments marked completed | `COUNT(status = 'completed') / COUNT(*)` | `assignments` | "Completed" tile (5 / 12) |
| K4 | **Hours Planned** | Planned study time | `SUM(pomodoro_count) × 25 / 60` over Latest Analyses, 1 decimal | `risk_analyses` | Tile |
| K5 | **Pomodoros Planned** | Planned focus sessions | `SUM(pomodoro_count)` over Latest Analyses | `risk_analyses` | Tile |

**Supporting counts**

| # | Metric | Formula | Source |
|---|--------|---------|--------|
| K6 | Total assignments | `COUNT(*)` | `assignments` |
| K7 | Overdue assignments | `COUNT(*)` where `status <> 'completed' AND due_date < today` | `assignments` |
| K8 | Plans generated | `COUNT(*)` | `study_plans` |
| K9 | AI success rate | `COUNT(source = 'gemini') / COUNT(*)` | `study_plans` |

> K4 and K5 are named "Hours Planned" and "Pomodoros **Planned**" (not "Generated") because they count each assignment once. Total Pomodoros generated across all regenerations can be added later if needed.

---

## 3. Trends (charts)

| # | Chart | X axis | Y axis | Formula | Source |
|---|-------|--------|--------|---------|--------|
| T1 | **Risk Trend** | Plan date | Average risk | `AVG(risk_score)` of all `risk_analyses` grouped by `study_plans.plan_date` (full history) | `risk_analyses`, `study_plans` |
| T2 | **Study Time Trend** | Calendar day | Pomodoros | `SUM(pomodoros)` grouped by `block_date`, only blocks belonging to Latest Analyses | `schedule_blocks`, `risk_analyses` |

T2 joins `schedule_blocks` to Latest Analyses on (`plan_id`, `assignment_id`) so that blocks from older, replaced plans are not counted twice.

---

## 4. Dashboard Data Map

| Wireframe element | Metric | `GET /api/dashboard` field |
|-------------------|--------|----------------------------|
| Total tile | K6 | `total_tasks` |
| Avg risk tile | K1 | `average_risk_score` |
| Completed tile | K3 | `completed_tasks`, `total_tasks` |
| Plans tile | K8 | `total_plans` |
| Risk distribution | K2 | `risk_distribution` |
| Hours / Pomodoros | K4, K5 | `hours_planned`, `pomodoros_planned` *(new)* |
| Overdue badge | K7 | `overdue_tasks` *(new)* |
| Risk trend chart | T1 | `risk_trend[]` |
| Study time trend chart | T2 | `study_time_trend[]` |
| History table | — | `GET /api/history` |

Fields marked *(new)* are added to [api-design.md](api-design.md) at the end of Sprint 2.

---

## 5. Worked Example

Student has 3 assignments; "Programming Lab" was regenerated once.

| Assignment | Status | Analyses (score) | Latest | Pomodoros (latest) |
|------------|--------|------------------|--------|--------------------|
| Programming Lab | pending | 70 → 78 | 78 high | 15 |
| Networking Quiz | in_progress | 52 | 52 medium | 5 |
| English Essay | completed | 21 | 21 low | 4 |

| KPI | Result |
|-----|--------|
| K1 Average risk | (78 + 52) / 2 = **65** (essay is completed) |
| K2 By level | high 1 · medium 1 · low 0 |
| K3 Completed | **1 / 3** |
| K4 Hours planned | (15 + 5 + 4) × 25 / 60 = **10.0 h** |
| K5 Pomodoros planned | **24** |
| K8 Plans generated | **2** |

---

## 6. Performance

Expected data volume is small (hundreds to a few thousand rows), so all metrics are calculated **live** with SQL on each request. No caching, materialized views or warehouse are needed. Indexes on `student_id`, `assignment_id` + `generated_at`, and `block_date` keep the queries fast.
