# API Design

Base URL (local): `http://127.0.0.1:8000`

## POST /api/study-plan

Request:

```json
{
  "courses": ["COSC 1436 Programming", "ITNW 1325 Networking"],
  "assignments": [
    { "title": "Programming Lab", "course": "COSC 1436", "due_date": "2026-11-20" }
  ],
  "exams": [
    { "title": "Networking Quiz", "course": "ITNW 1325", "date": "2026-11-22" }
  ]
}
```

Response:

```json
{
  "id": 1,
  "weekly_plan": [{ "day": "Monday", "tasks": ["2 Pomodoros Programming Lab"] }],
  "priority_matrix": { "high": ["Programming Lab"], "medium": ["Networking Quiz"], "low": [] },
  "pomodoros": [{ "task": "Programming Lab", "count": 6 }],
  "risk_level": "medium",
  "risk_analysis": "Two deadlines within 3 days..."
}
```

## POST /api/meal-plan

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

## GET /api/history

Query params: `type` (optional: `study` | `meal`), `limit` (default 20).

Response: list of stored plans ordered by `created_at` desc.

## POST /api/discord

Request:

```json
{ "plan_id": 1 }
```

Response:

```json
{ "sent": true }
```
