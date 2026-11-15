# API Design

| | |
|---|---|
| **Updated in** | Sprint 1 - Solution Design |
| **Related** | [Architecture](architecture.md) · [Sequence Diagrams](sequence-diagrams.md) |

Base URL (local): `http://127.0.0.1:8000` · Interactive docs: `/docs` (FastAPI)

All requests and responses are JSON. Dates use `YYYY-MM-DD`; timestamps use ISO 8601 UTC.

## Endpoints

| Method | Path | Purpose | MVP |
|--------|------|---------|-----|
| GET | `/health` | Health check | Must |
| POST | `/api/study-plan` | Generate a study plan | Must |
| GET | `/api/history` | List previous plans | Should |
| GET | `/api/history/{id}` | Get one plan | Should |
| PATCH | `/api/tasks/{id}` | Mark a task completed | Should |
| GET | `/api/dashboard` | KPIs and trends | Should |
| POST | `/api/discord` | Send a plan summary to Discord | Should |
| POST | `/api/meal-plan` | Generate a meal plan | Could (stretch) |

---

## GET /health

Response `200 OK`:

```json
{ "status": "ok", "database": "ok", "version": "0.1.0" }
```

`database` is `"error"` if the database cannot be reached (status code is still 200 so the server can be woken up).

---

## POST /api/study-plan

Request:

```json
{
  "assignments": [
    {
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
| `course` | string | Required, 1 – 50 characters |
| `title` | string | Required, 1 – 100 characters |
| `type` | string | `assignment` (default) or `exam` |
| `due_date` | date | Required, today or later |
| `estimated_hours` | number | 0.5 – 40 |
| `difficulty` | integer | 1 – 5 |

Response `201 Created`:

```json
{
  "id": 1,
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
      "id": 1,
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
      "completed": false
    }
  ],
  "daily_schedule": [
    {
      "date": "2026-11-16",
      "blocks": [
        { "task": "Programming Lab", "pomodoros": 6 },
        { "task": "Networking Quiz", "pomodoros": 2 }
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
| `saved` | `false` if the database save failed; `id` and task `id`s are then `null` |
| `risk_level`, `priority` | `low` (0–39), `medium` (40–69), `high` (70–100) |
| `rank` | Order by risk score desc, then due date asc |
| `pomodoros` | `ceil(estimated_hours × 60 / 25)` |
| `warnings` | e.g. `"Not enough days to fit all Pomodoros before 2026-11-18"` |

Risk formula: see [architecture.md § 4](architecture.md#4-key-design-answers).

---

## GET /api/history

Query params: `limit` (default 20, max 100), `type` (optional: `study` | `meal`).

Response `200 OK` (newest first):

```json
[
  {
    "id": 1,
    "plan_type": "study",
    "created_at": "2026-11-16T14:05:00Z",
    "source": "gemini",
    "overall_risk_score": 78,
    "overall_risk_level": "high",
    "total_tasks": 2
  }
]
```

## GET /api/history/{id}

Response `200 OK`: same body as the `POST /api/study-plan` response, with current task `completed` values. `404` if not found.

---

## PATCH /api/tasks/{id}

Request:

```json
{ "completed": true }
```

Response `200 OK`:

```json
{ "id": 1, "completed": true }
```

`404` if the task does not exist.

---

## GET /api/dashboard

Response `200 OK`:

```json
{
  "total_plans": 4,
  "total_tasks": 12,
  "completed_tasks": 5,
  "average_risk_score": 54,
  "risk_distribution": { "low": 4, "medium": 5, "high": 3 },
  "risk_trend": [{ "date": "2026-11-14", "average_risk_score": 45 }],
  "study_time_trend": [{ "date": "2026-11-16", "pomodoros": 8 }]
}
```

---

## POST /api/discord

Request:

```json
{ "plan_id": 1 }
```

Response `200 OK`:

```json
{ "sent": true }
```

Errors: `404` plan not found · `502` Discord error or webhook not configured (`{ "sent": false, "detail": "..." }`).

---

## POST /api/meal-plan (stretch)

Request:

```json
{ "weekly_budget": 50, "preferences": ["vegetarian"] }
```

Response:

```json
{
  "id": 2,
  "days": [{ "day": "Monday", "breakfast": "...", "lunch": "...", "dinner": "..." }],
  "shopping_list": [{ "item": "Rice", "estimated_cost": 3.5 }],
  "tips": ["Cook in batches on Sunday"]
}
```

---

## Errors

| Status | When | Body |
|--------|------|------|
| 400 | Request is not valid JSON | `{ "detail": "..." }` |
| 404 | Plan or task not found | `{ "detail": "Plan not found" }` |
| 422 | Validation failed | FastAPI format: `{ "detail": [ { "loc": ["body", "assignments", 0, "due_date"], "msg": "...", "type": "..." } ] }` |
| 502 | Discord delivery failed | `{ "sent": false, "detail": "..." }` |
| 500 | Unexpected server error | `{ "detail": "Internal server error" }` |

Gemini failures do **not** produce an error status; the API returns a fallback plan (`source: "fallback"`).
