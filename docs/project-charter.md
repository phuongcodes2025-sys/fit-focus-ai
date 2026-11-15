# Project Charter — Fit & Focus AI

| | |
|---|---|
| **Project** | Fit & Focus AI |
| **Event** | HackUTA 2026 |
| **Sprint** | Sprint 0 - Discovery & Planning (0.1) |
| **Repository** | [phuongcodes2025-sys/fit-focus-ai](https://github.com/phuongcodes2025-sys/fit-focus-ai) |

---

## 1. Problem Statement

College students juggle multiple classes, assignment deadlines, exams, part-time jobs and personal responsibilities at the same time. Most students **know what needs to be done but not what to do first**. Without a clear way to prioritize, they:

- Start high-stakes work too late and cram before deadlines
- Underestimate the risk of overlapping deadlines and exams
- Spend time planning instead of studying
- Neglect healthy habits (sleep, meals, budget) under academic pressure

Existing tools (calendars, to-do apps, LMS dashboards) **list** tasks but do not **analyze** workload, assess risk, or turn deadlines into an actionable study schedule.

**Problem statement:**
> Students need a fast, simple way to turn their courses and deadlines into a prioritized, realistic study plan that highlights academic risk before it becomes a missed deadline.

---

## 2. Solution Overview

**Fit & Focus AI** is an AI-powered student success companion. Students enter their courses, assignments and exam dates. Google Gemini then turns them into an actionable plan.

### Core capabilities (MVP)

| Capability | Description |
|------------|-------------|
| **Study Plan Generator** | Converts assignments and exams into a weekly study plan |
| **Priority Matrix** | Ranks tasks as High / Medium / Low priority |
| **Pomodoro Breakdown** | Splits each task into focused 25-minute sessions |
| **Academic Risk Analysis** | Flags overloaded weeks and at-risk deadlines with a risk level |
| **Activity History** | Saves plans and AI results in Tiger Data (PostgreSQL) |
| **Discord Notifications** | Sends a plan summary to a Discord channel via webhook |

### Stretch capability

- **Meal Planner:** a 7-day, budget-friendly meal plan and shopping list.

### Architecture

```text
Student → Next.js (Vercel) → FastAPI (Render) → Gemini API
                                         ├──→ Tiger Data (PostgreSQL)
                                         └──→ Discord Webhook
```

See [architecture.md](architecture.md) and [api-design.md](api-design.md).

---

## 3. Project Goals

### Product goals

1. **G1 — Prioritization:** Turn a student's deadlines into a clear High / Medium / Low priority list.
2. **G2 — Actionable planning:** Generate a weekly study plan with Pomodoro sessions the student can follow immediately.
3. **G3 — Early warning:** Detect academic risk (deadline clustering, heavy workload) and explain it in plain language.
4. **G4 — Persistence:** Store plans and AI results so students can review their history.
5. **G5 — Reach students where they are:** Push plan summaries to Discord.

### Engineering goals

6. **G6 — Working MVP:** Deliver a deployed, end-to-end app (frontend + API + AI + database).
7. **G7 — Structured AI output:** Gemini returns validated JSON, not free text.
8. **G8 — Clean architecture:** Separate routes, services and models in FastAPI; document the API.

### HackUTA goals

9. **G9 — Prize categories:** Compete for *Best Use of Gemini API*, *Best Use of Tiger Data* and *Build with SpaceXSI*.
10. **G10 — Submission:** Ship a public repo, demo video and presentation before the deadline.

---

## 4. Success Criteria

### Functional

| # | Criterion | Measure | Goal |
|---|-----------|---------|------|
| S1 | Study plan generation works end to end | `POST /api/study-plan` returns a weekly plan, priority matrix, Pomodoros and risk level | G1, G2, G3 |
| S2 | AI output is reliable | Gemini response passes JSON schema validation; invalid responses are handled with a clear error | G7 |
| S3 | Plans are persisted | Each generated plan is saved to Tiger Data and returned by `GET /api/history` | G4 |
| S4 | Discord integration works | `POST /api/discord` posts a readable summary to the configured channel | G5 |
| S5 | Frontend workflow works | A user can enter assignments → generate a plan → view result cards on the homepage | G6 |

### Quality / non-functional

| # | Criterion | Target |
|---|-----------|--------|
| Q1 | Response time for plan generation | ≤ 10 seconds |
| Q2 | Health check | `GET /health` returns `200 OK` in production |
| Q3 | Test coverage of core logic | Risk scoring, priority matrix and Pomodoro generator have unit tests |
| Q4 | No secrets in source code | API keys loaded from environment variables only |

### Delivery

| # | Criterion | Goal |
|---|-----------|------|
| D1 | Frontend deployed on Vercel and backend deployed on Render with a public production URL | G6 |
| D2 | README, architecture docs and API docs complete | G8, G10 |
| D3 | Demo video and final presentation submitted to HackUTA on time | G10 |
| D4 | Demo shows Gemini and Tiger Data usage clearly for judges | G9 |

### Definition of Done (MVP)

The MVP is **done** when a judge can open the production URL, enter assignments and receive a prioritized study plan with risk analysis and Pomodoros. The plan must also appear in history and be shareable to Discord.

---

## Related Documents

- [SPRINTS.md](SPRINTS.md): 12-sprint MVP development workbook
- [architecture.md](architecture.md): system architecture
- [api-design.md](api-design.md): API design
