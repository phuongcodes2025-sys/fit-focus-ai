# Architecture

```text
Student
    │
    ▼
Next.js Frontend (Vercel)
    │  REST (JSON)
    ▼
FastAPI Backend (Render)
    │
 ┌──┴───────────┐
 ▼              ▼
Gemini API   Tiger Data (PostgreSQL)
    │
    ▼
Discord Webhook
```

## Components

| Component | Responsibility |
|-----------|----------------|
| Frontend (Next.js, TypeScript, Tailwind) | Input forms (syllabus, deadlines, budget), dashboard, history view |
| Backend (FastAPI) | Validates requests, builds prompts, calls Gemini, persists results, sends Discord messages |
| Gemini API | Generates study plans, priority matrix, Pomodoro breakdown, risk analysis, meal plans |
| Tiger Data | Stores prompts, AI results and activity history |
| Discord Webhook | Delivers plan summaries to a channel |

## Request Flow (Study Plan)

1. User submits courses, assignments and exam dates from the frontend.
2. Frontend calls `POST /api/study-plan`.
3. Backend builds a structured prompt and calls Gemini.
4. Gemini returns a JSON plan (priorities, Pomodoros, risk level).
5. Backend stores the request + response in the `plans` table.
6. Backend returns the plan to the frontend dashboard.
7. Optionally, user triggers `POST /api/discord` to share the summary.
