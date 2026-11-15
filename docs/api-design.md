# API Design

| | |
|---|---|
| **Updated in** | Sprint 1 - Solution Design · Sprint 2 - Data Architecture |
| **Related** | [Architecture](architecture.md) · [Sequence Diagrams](sequence-diagrams.md) · [Data Dictionary](data-dictionary.md) |

Base URL (local): `http://127.0.0.1:8000/api/v1` · Interactive docs: `/docs` (FastAPI)

All requests and responses are JSON. Dates use `YYYY-MM-DD`; timestamps use ISO 8601 UTC. All IDs are UUID strings.

**Student identity (no login):** the browser creates a UUID once, keeps it in `localStorage` and sends it on every `/api/v1/*` request as the header `X-Student-Id`. The backend creates the student row the first time it sees the ID, and only returns that student's data. Missing or invalid header → `400`.

## Endpoints

| Method | Path | Purpose | MVP |
|--------|------|---------|-----|
| GET | `/api/v1/health` | Health check | Must |
| POST | `/api/v1/study-plan` | Generate a study plan | Must |
| GET | `/api/v1/history` | List previous plans | Should |
| GET | `/api/v1/history/{id}` | Get one plan | Should |
| PATCH | `/api/v1/assignments/{id}` | Update an assignment's status | Should |
| GET | `/api/v1/dashboard` | KPIs and trends | Should |
| POST | `/api/v1/discord` | Send a plan summary to Discord | Should |
| POST | `/api/v1/meal-plan` | Generate a meal plan | Could (stretch) |

---

## GET /api/v1/health

Response `200 OK`:

```json
{ "status": "ok", "database": "ok", "version": "0.1.0" }
```

`database` is `"error"` if the database cannot be reached (status code is still 200 so the server can be woken up).

---

## POST /api/v1/study-plan

> **Current implementation (Sprint 4, mock):** the endpoint accepts `{"course", "assignment", "deadline"}` and always returns `{"risk": "High", "priority": "High", "pomodoros": 6}`. The full request and response below is the target design for Sprint 5.

Request:

```json
{
  "assignments": [
    {
      "id": null,
      "course": "COSC 1436",
      "title": "Programming Lab",
      "type": "assignment",
      "due_date": "2026-11-18",
      "estimated_hours": 6,
      "difficulty": 4
    },
    {
      "course": "ITNW 1325",
      "title": "Networking Quiz",
      "type": "exam",
      "due_date": "2026-11-19",
      "estimated_hours": 2,
      "difficulty": 3
    }
  ]
}
```

| Field | Type | Rules |
|-------|------|-------|
| `assignments` | array | 1 – 20 items |
| `id` | UUID or null | Optional. Send an existing assignment's ID when regenerating a plan; omit or `null` for a new assignment |
| `course` | string | Required, 1 – 50 characters |
| `title` | string | Required, 1 – 100 characters |
| `type` | string | `assignment` (default) or `exam` |
| `due_date` | date | Required, today or later |
| `estimated_hours` | number | 0.5 – 40 |
| `difficulty` | integer | 1 – 5 |

Response `201 Created`:

```json
{
  "id": "c71d2e4a-5b3f-4e0a-9d1c-2f6b8a7e1040",
  "plan_date": "2026-11-16",
  "created_at": "2026-11-16T14:05:00Z",
  "source": "gemini",
  "saved": true,
  "summary": {
    "overall_risk_score": 78,
    "overall_risk_level": "high",
    "total_tasks": 2,
    "total_pomodoros": 20,
    "total_hours": 8
  },
  "tasks": [
    {
      "id": "a3f04b9e-1c2d-4e5f-8a7b-6c5d4e3f2a12",
      "rank": 1,
      "course": "COSC 1436",
      "title": "Programming Lab",
      "type": "assignment",
      "due_date": "2026-11-18",
      "estimated_hours": 6,
      "difficulty": 4,
      "risk_score": 78,
      "risk_level": "high",
      "priority": "high",
      "pomodoros": 15,
      "status": "pending",
      "is_overdue": false
    }
  ],
  "daily_schedule": [
    {
      "date": "2026-11-16",
      "blocks": [
        { "assignment_id": "a3f04b9e-1c2d-4e5f-8a7b-6c5d4e3f2a12", "task": "Programming Lab", "pomodoros": 6 },
        { "assignment_id": "…", "task": "Networking Quiz", "pomodoros": 2 }
      ],
      "total_pomodoros": 8
    }
  ],
  "risk_analysis": "Your Programming Lab is high risk: it is due in 2 days and needs about 6 hours...",
  "tips": ["Start the Programming Lab today.", "Review quiz notes in short sessions."],
  "warnings": []
}
```

| Field | Notes |
|-------|-------|
| `source` | `gemini` or `fallback` (Gemini failed; rule-based schedule) |
| `id` | Plan ID. Task `id` is the assignment ID (reuse it when regenerating) |
| `plan_date` | The "today" used for risk scoring |
| `saved` | `false` if the database save failed; plan `id` is then `null` |
| `risk_level`, `priority` | `low` (0–39), `medium` (40–69), `high` (70–100) |
| `rank` | Order by risk score desc, then due date asc |
| `pomodoros` | `ceil(estimated_hours × 60 / 25)` |
| `status`, `is_overdue` | Assignment status (`pending`, `in_progress`, `completed`); overdue is calculated |
| `warnings` | e.g. `"Not enough days to fit all Pomodoros before 2026-11-18"` |

Risk formula: see [architecture.md § 4](architecture.md#4-key-design-answers).

---

## GET /api/v1/history

Query params: `limit` (default 20, max 100). Returns only the current student's plans.

Response `200 OK` (newest first):

```json
[
  {
    "id": "c71d2e4a-5b3f-4e0a-9d1c-2f6b8a7e1040",
    "plan_date": "2026-11-16",
    "created_at": "2026-11-16T14:05:00Z",
    "source": "gemini",
    "overall_risk_score": 78,
    "overall_risk_level": "high",
    "total_tasks": 2
  }
]
```

## GET /api/v1/history/{id}

Response `200 OK`: same body as the `POST /api/v1/study-plan` response, with each task's current `status` and `is_overdue`. `404` if not found or it belongs to another student.

---

## PATCH /api/v1/assignments/{id}

Request:

```json
{ "status": "completed" }
```

Response `200 OK`:

```json
{ "id": "a3f04b9e-1c2d-4e5f-8a7b-6c5d4e3f2a12", "status": "completed", "completed_at": "2026-11-17T20:00:00Z" }
```

`status` is `pending`, `in_progress` or `completed`. `completed_at` is set when completed and cleared otherwise. `404` if not found or it belongs to another student.

---

## GET /api/v1/dashboard

Response `200 OK`:

```json
{
  "total_plans": 4,
  "total_tasks": 12,
  "completed_tasks": 5,
  "overdue_tasks": 1,
  "average_risk_score": 54,
  "hours_planned": 10.0,
  "pomodoros_planned": 24,
  "ai_success_rate": 0.75,
  "risk_distribution": { "low": 4, "medium": 5, "high": 3 },
  "risk_trend": [{ "date": "2026-11-14", "average_risk_score": 45 }],
  "study_time_trend": [{ "date": "2026-11-16", "pomodoros": 8 }]
}
```

All values are for the current student. Definitions and formulas: [analytics-model.md](analytics-model.md).

---

## POST /api/v1/discord

Request:

```json
{ "plan_id": "c71d2e4a-5b3f-4e0a-9d1c-2f6b8a7e1040" }
```

Response `200 OK`:

```json
{ "sent": true }
```

Errors: `404` plan not found · `502` Discord error or webhook not configured (`{ "sent": false, "detail": "..." }`).

---

## POST /api/v1/meal-plan (stretch)

Not part of the Sprint 2 data model. If built, meal plans get their own table.

Request:

```json
{ "weekly_budget": 50, "preferences": ["vegetarian"] }
```

Response:

```json
{
  "id": "…",
  "days": [{ "day": "Monday", "breakfast": "...", "lunch": "...", "dinner": "..." }],
  "shopping_list": [{ "item": "Rice", "estimated_cost": 3.5 }],
  "tips": ["Cook in batches on Sunday"]
}
```

---

## Errors

| Status | When | Body |
|--------|------|------|
| 400 | Request is not valid JSON, or `X-Student-Id` missing / invalid | `{ "detail": "..." }` |
| 404 | Plan or assignment not found | `{ "detail": "Plan not found" }` |
| 422 | Validation failed | FastAPI format: `{ "detail": [ { "loc": ["body", "assignments", 0, "due_date"], "msg": "...", "type": "..." } ] }` |
| 502 | Discord delivery failed | `{ "sent": false, "detail": "..." }` |
| 500 | Unexpected server error | `{ "detail": "Internal server error" }` |

Gemini failures do **not** produce an error status; the API returns a fallback plan (`source: "fallback"`).
