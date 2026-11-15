# Architecture Review — Sprint 1

| | |
|---|---|
| **Sprint** | Sprint 1 - Solution Design |
| **Reviewed artifacts** | [Architecture](architecture.md) · [Use Cases](use-cases.md) · [Data Flow](data-flow.md) · [Sequence Diagrams](sequence-diagrams.md) · [Wireframes](wireframes.md) · [API Design](api-design.md) |

> **Review question:** If a new developer joins tomorrow, can they understand how the system works without reading any code?

---

## 1. Shared Understanding — Core Workflow

```text
Student → Assignment Input → Risk Analysis → AI Planning → Saved Plan → Dashboard → Notifications
```

| Step | Where it is defined |
|------|---------------------|
| Assignment Input | Wireframes Screen 1 · API `POST /api/study-plan` request |
| Risk Analysis | Architecture § 4 (formula) · DFD Level 2 |
| AI Planning | Architecture § 4 (AI) · ADR-002, ADR-003 · Sequence 1 |
| Saved Plan | ERD preview · Sequence 2 |
| Dashboard | Wireframes Screen 3 · API `GET /api/dashboard` |
| Notifications | Sequence 3 · ADR-007 |

---

## 2. Key Decisions Made

| # | Decision | Reference |
|---|----------|-----------|
| 1 | Risk, priority and Pomodoros are calculated by rules in the backend, not by Gemini | ADR-002 |
| 2 | Gemini returns validated JSON; one retry; rule-based fallback | ADR-003 |
| 3 | Synchronous API, 8 s Gemini timeout, ≤ 10 s total | ADR-004 |
| 4 | Tasks stored in their own table; full plan stored as JSONB | ADR-005 |
| 5 | No authentication in the MVP | ADR-006 |
| 6 | Discord sent only when the user clicks, via server-side webhook | ADR-007 |
| 7 | Inputs extended with `estimated_hours`, `difficulty` and `type` (assignment / exam) | API Design |
| 8 | Risk is a 0–100 score with Low / Medium / High bands | Architecture § 4 |

---

## 3. Changes from Earlier Documents

| Document | Change |
|----------|--------|
| `api-design.md` | Request now uses one `assignments` list (exams are `type: "exam"`) with hours and difficulty. Response now has `risk_score` 0–100, `tasks`, `daily_schedule`, `source`, `saved`, `warnings`. Added `/health`, `/api/history/{id}`, `/api/tasks/{id}`, `/api/dashboard`. |
| `architecture.md` | Rewritten with context, component and deployment diagrams, design answers and ADRs. |
| `database/schema.sql` | **Not changed yet.** The ERD preview adds `tasks` and `notifications` tables; Sprint 2 updates the schema. |

---

## 4. Risks and Open Questions

| # | Item | Impact | Proposed action | Sprint |
|---|------|--------|-----------------|--------|
| Q-1 | Risk weights (40/30/20/10) are untested guesses | Scores may feel wrong | Test with 5–10 real assignment sets; tune weights | 5 |
| Q-2 | "Today" depends on time zone | Wrong days-left near midnight | Frontend sends dates; backend uses America/Chicago for the MVP | 5 |
| Q-3 | Shared history (no login) shows everyone's plans | Privacy during public demo | Collect no personal data; consider a browser-generated session id | 7 |
| Q-4 | Render free tier cold start (~30–60 s) | Slow first request in demo | Call `/health` before demoing | 10 |
| Q-5 | `backend/main.py` allows only `http://localhost:3000` (CORS) | Production frontend blocked | Read allowed origins from `ALLOWED_ORIGINS` | 4 |
| Q-6 | `backend/main.py` health route is `/`, design uses `/health` | Mismatch | Add `/health` | 4 |
| Q-7 | Gemini schedule might not match engine counts | Invalid plans | Validation rules in Architecture § 4; fallback | 6 |
| Q-8 | "Completed tasks" KPI needs a new endpoint | Small scope increase | `PATCH /api/tasks/{id}` as Should-have | 7 |

---

## 5. Sign-off Checklist

| Artifact | Status |
|----------|--------|
| System Architecture Diagram | ✅ [architecture.md](architecture.md) |
| Use Case Diagram | ✅ [use-cases.md](use-cases.md) |
| Data Flow Diagram (Level 0, 1, 2) | ✅ [data-flow.md](data-flow.md) |
| ERD Preview | ✅ [data-flow.md § 5](data-flow.md#5-erd-preview-for-sprint-2) |
| Sequence Diagrams (Generate, History, Discord) | ✅ [sequence-diagrams.md](sequence-diagrams.md) |
| Low-Fidelity Wireframes | ✅ [wireframes.md](wireframes.md) |
| API Design updated | ✅ [api-design.md](api-design.md) |
| Architecture Review Notes | ✅ this document |

**Team review:** ⬜ All team members have read the documents and agree with the decisions above.

---

## 6. Next Steps

1. **Sprint 2 — Data Architecture:** finalize the ERD, update `schema.sql`, write the data dictionary.
2. **Sprints 3–4:** set up the environment and API skeleton using the components and endpoints defined here.
