# Business Analysis — Fit & Focus AI

| | |
|---|---|
| **Project** | Fit & Focus AI |
| **Event** | HackUTA 2026 |
| **Sprint** | Sprint 0 - Discovery & Planning (0.2) |
| **Related** | [Project Charter](project-charter.md) · [SPRINTS.md](SPRINTS.md) |

---

## 1. Stakeholder Analysis

### Stakeholder register

| Stakeholder | Role | Interests / Needs | Influence | Interest | Engagement |
|-------------|------|-------------------|-----------|----------|------------|
| **College students** (primary users) | Use the app to plan study time | Know what to do first, avoid missed deadlines, low effort, free | High | High | Manage closely: user feedback, usability testing |
| **Project team** | Design, build, deploy and present | Ship a working MVP on time, win prize categories | High | High | Manage closely: daily sync, sprint issues |
| **HackUTA judges** | Evaluate submission | Innovation, technical depth, working demo, clear impact | High | Medium | Keep satisfied: clear demo, judge talking points |
| **Sponsors** (Google Gemini, Tiger Data, SpaceXSI) | Prize category owners | Meaningful use of their technology | Medium | Medium | Keep satisfied: highlight integrations in demo |
| **Academic advisors / instructors** | Potential future users or promoters | Student retention, early risk detection | Low | Medium | Keep informed: future roadmap |
| **Student organizations / Discord communities** | Channels for sharing plans | Engagement and accountability among members | Low | Medium | Keep informed: Discord integration |
| **Third-party providers** (Vercel, Render, Gemini API, Tiger Data) | Hosting, AI and data services | Usage within free-tier and terms of service | Medium | Low | Monitor: quotas, uptime |

### Power / Interest grid

```text
            High Interest
                 │
   Keep          │   Manage
   Satisfied     │   Closely
  ───────────────┼───────────────  
  • Judges       │ • Students
  • Sponsors     │ • Project team
                 │
 Low ────────────┼──────────── High Influence
                 │
   Monitor       │   Keep
                 │   Informed
  • Providers    │ • Advisors
                 │ • Discord communities
                 │
            Low Interest
```

### User persona

> **Alex, 20, community college student.** Takes 4 courses and works 20 hours a week. Alex has a Programming Lab due Thursday and a Networking quiz on Friday, and doesn't know where to start. Alex wants a plan in under a minute, on any device, and reminders in the Discord server Alex already uses.

---

## 2. Business Requirements

### Business objectives

| ID | Objective |
|----|-----------|
| BO-1 | Help students prioritize coursework and reduce missed deadlines |
| BO-2 | Surface academic risk early so students can act before it is too late |
| BO-3 | Demonstrate meaningful use of Gemini API and Tiger Data for HackUTA prize categories |
| BO-4 | Deliver a deployed, demo-ready MVP within the hackathon timeline |

### Business requirements

| ID | Requirement | Priority | Objective |
|----|-------------|----------|-----------|
| BR-1 | Students must be able to enter courses, assignments and exam dates | Must | BO-1 |
| BR-2 | The system must generate a weekly study plan from the student's input | Must | BO-1 |
| BR-3 | The system must rank tasks as High / Medium / Low priority | Must | BO-1 |
| BR-4 | The system must break tasks into Pomodoro sessions | Must | BO-1 |
| BR-5 | The system must assess and explain academic risk level | Must | BO-2 |
| BR-6 | The system must use Gemini to generate structured plan output | Must | BO-3 |
| BR-7 | The system must store plans and AI results in Tiger Data | Must | BO-3 |
| BR-8 | Students must be able to view previous plans (history) | Should | BO-1, BO-3 |
| BR-9 | Students should be able to send a plan summary to Discord | Should | BO-1 |
| BR-10 | The system should display a dashboard with KPIs and risk analytics | Should | BO-2 |
| BR-11 | The system could generate a budget-friendly meal plan | Could | BO-1 |
| BR-12 | The application must be publicly accessible via a production URL | Must | BO-4 |

### Functional requirements (high level)

| ID | Requirement | Traces to |
|----|-------------|-----------|
| FR-1 | `POST /api/study-plan` accepts courses, assignments and exams and returns plan JSON | BR-1 – BR-6 |
| FR-2 | Gemini response is validated against a JSON schema before returning | BR-6 |
| FR-3 | Each request and response is saved to the database | BR-7 |
| FR-4 | `GET /api/history` returns previously generated plans | BR-8 |
| FR-5 | `POST /api/discord` sends a formatted summary to a webhook | BR-9 |
| FR-6 | Frontend shows Study Plan, Risk and Pomodoro cards | BR-2 – BR-5 |
| FR-7 | `POST /api/meal-plan` returns a 7-day meal plan and shopping list | BR-11 |

### Non-functional requirements

| ID | Category | Requirement |
|----|----------|-------------|
| NFR-1 | Performance | Plan generation completes in ≤ 10 seconds |
| NFR-2 | Usability | A first-time user can generate a plan in ≤ 3 steps without instructions |
| NFR-3 | Security | API keys and connection strings are stored only in environment variables |
| NFR-4 | Privacy | No login required for MVP; no sensitive personal data collected |
| NFR-5 | Reliability | Graceful error message if Gemini or the database is unavailable |
| NFR-6 | Compatibility | Responsive UI on desktop and mobile browsers |
| NFR-7 | Maintainability | Backend separated into routes, services and models; API documented |

---

## 3. SWOT Analysis

| **Strengths** (internal) | **Weaknesses** (internal) |
|---|---|
| • Solves a real, relatable student problem<br>• AI-generated plans with risk analysis, not just a to-do list<br>• Simple input → actionable output in one step<br>• Modern, low-cost stack (Next.js, FastAPI, Gemini, Tiger Data)<br>• Clear alignment with multiple HackUTA prize categories | • Short hackathon timeline limits features and testing<br>• No user accounts or authentication in MVP<br>• Quality depends on Gemini output and prompt design<br>• No calendar or LMS integration yet<br>• Limited user research before the build |

| **Opportunities** (external) | **Threats** (external) |
|---|---|
| • Large student market facing burnout and time-management issues<br>• Integration with Google Calendar, Canvas or Blackboard<br>• Partnerships with colleges (e.g. Dallas College) and advisors<br>• Growing student use of Discord for study groups<br>• Expand into wellness, meal planning and GPA tracking | • Competing tools (Notion, Todoist, MyStudyLife, ChatGPT)<br>• Gemini API rate limits, cost or policy changes<br>• Free-tier hosting limits (cold starts on Render)<br>• Student data privacy concerns<br>• Students may not keep using a new app after the first week |

### SWOT strategies

| Strategy | Action |
|----------|--------|
| **S-O** (use strengths for opportunities) | Position as the "AI study coach" for colleges; pilot with student organizations via Discord |
| **W-O** (fix weaknesses using opportunities) | Add calendar and LMS import after the MVP to reduce manual input |
| **S-T** (use strengths against threats) | Differentiate from generic chatbots with structured risk scoring and a Pomodoro plan |
| **W-T** (minimize weaknesses and threats) | Validate AI output with a JSON schema; add fallback logic; keep the MVP scope small |

---

## 4. Risk Assessment

**Scale:** Likelihood and Impact are rated 1 (Low) to 3 (High). Score = Likelihood × Impact. Ratings: 1–2 Low · 3–4 Medium · 6–9 High.

| ID | Risk | Category | L | I | Score | Mitigation | Owner | Sprint |
|----|------|----------|---|---|-------|------------|-------|--------|
| R-1 | Gemini returns invalid or inconsistent JSON | Technical | 3 | 3 | **9 High** | Strict prompt with JSON schema, response validation, retry once, fallback to rule-based plan | Backend | 6 |
| R-2 | Not enough time to finish all features | Schedule | 3 | 3 | **9 High** | Keep MVP scope fixed; Meal Planner is stretch; follow sprint order; daily check on progress | Team | All |
| R-3 | Gemini API rate limit or quota exceeded during demo | Technical | 2 | 3 | **6 High** | Cache sample responses; prepare a recorded demo video as backup | Backend | 6, 11 |
| R-4 | Deployment issues (Render cold start, CORS, env vars) | Technical | 2 | 3 | **6 High** | Deploy early (not last minute); health check endpoint; warm up server before demo | Team | 10 |
| R-5 | Database connection failure (Tiger Data) | Technical | 2 | 2 | **4 Medium** | Connection pooling, error handling, app still returns plan if save fails | Backend | 7 |
| R-6 | API keys leaked in public repository | Security | 2 | 3 | **6 High** | `.env` in `.gitignore`, `.env.example` only, review commits before pushing | Team | 3 |
| R-7 | Frontend and backend contract mismatch | Integration | 2 | 2 | **4 Medium** | Single source of truth in `api-design.md`; shared example payloads | Team | 4, 8 |
| R-8 | Inaccurate or unhelpful AI recommendations | Product | 2 | 2 | **4 Medium** | Rule-based risk scoring combined with AI explanation; test with real assignment examples | Backend | 5, 6 |
| R-9 | Discord webhook fails or is misused | Technical | 1 | 1 | **1 Low** | Validate webhook URL; feature is optional and does not block the main flow | Backend | 9 |
| R-10 | Demo fails live in front of judges | Presentation | 2 | 3 | **6 High** | Demo script, rehearsal, backup video, pre-filled sample data | Team | 11 |

### Risk heat map

```text
Impact ▲
  3    │        │ R-3 R-4 R-6 R-10 │ R-1 R-2 │
  2    │        │ R-5 R-7 R-8      │         │
  1    │  R-9   │                  │         │
       └────────┴──────────────────┴─────────┴──▶ Likelihood
           1             2              3
```

### Top risks to monitor

1. **R-1:** Gemini output reliability. This is the core of the product.
2. **R-2:** Scope versus time. Protect the MVP and defer stretch features.
3. **R-10 and R-3:** Demo reliability. Always have a backup video.

---

## Related Documents

- [project-charter.md](project-charter.md): problem, solution, goals, success criteria
- [SPRINTS.md](SPRINTS.md): 12-sprint MVP development workbook
- [architecture.md](architecture.md) · [api-design.md](api-design.md)
