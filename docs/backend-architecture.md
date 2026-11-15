# Backend Architecture

| | |
|---|---|
| **Sprint** | Sprint 3 - Development Environment |
| **Related** | [Architecture](architecture.md) · [API Design](api-design.md) · [ERD](erd.md) |

The backend is a FastAPI app deployed on Render. It validates requests, calculates risk, calls Gemini, stores results in Tiger Data (PostgreSQL) and sends Discord messages.

## Request flow

```text
Frontend → API → Service layer → Gemini → Database
```

1. **API** receives the request and validates it with a schema.
2. **Service layer** runs the business logic: risk engine, Gemini call, persistence.
3. **Gemini** adds the study plan and tips; if it fails, a rule-based fallback plan is used.
4. **Database** stores the request and result.

## Folder structure

```text
backend/
├── main.py         # App setup, CORS, router registration
├── api/            # Endpoints (HTTP only: parse, call a service, return)
├── services/       # Business logic
│   ├── planner.py      # Risk, priority, Pomodoro, fallback plan
│   ├── gemini.py       # Prompt, call, JSON validation
│   ├── repository.py   # Save and query plans and tasks
│   └── discord.py      # Format and send summaries
├── models/         # Database table definitions
├── schemas/        # Pydantic request and response schemas
├── database/       # Connection and session handling
└── utils/          # Small shared helpers (dates, ids)
```

Rule: `api/` contains no business logic; `services/` knows nothing about HTTP.

## API versioning

All endpoints live under `/api/v1`. `GET /api/v1/health` reports service status.

```text
POST /api/v1/study-plan
GET  /api/v1/history
GET  /api/v1/health
```

The full list is in [api-design.md](api-design.md). A breaking change would create `/api/v2` while `/api/v1` keeps working.

## Responsibilities

| Layer | Responsibility |
|-------|----------------|
| API | Routing, status codes, reading the `X-Student-Id` header |
| Schemas | Input validation and response shapes |
| Planner service | Deterministic risk score, priority, Pomodoros, fallback |
| Gemini service | Prompt, 8-second timeout, JSON validation |
| Repository | All SQL access |
| Discord service | Message formatting and webhook call |

## Configuration

| Variable | Purpose |
|----------|---------|
| `GEMINI_API_KEY` | Gemini API access |
| `DATABASE_URL` | Tiger Data connection string |
| `DISCORD_WEBHOOK_URL` | Discord notifications |
| `ENVIRONMENT` | `local` or `production`; controls CORS origins and debug behavior |

Use `.env` locally (git-ignored) and the Render dashboard in production. Commit only `.env.example`.

## Notes

- The current scaffold uses `backend/routes/`; it is renamed to `backend/api/` when the API foundation is implemented (Sprint 4).
