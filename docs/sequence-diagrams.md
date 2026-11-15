# Sequence Diagrams — Fit & Focus AI

| | |
|---|---|
| **Sprint** | Sprint 1 - Solution Design (1.4) |
| **Related** | [Architecture](architecture.md) · [API Design](api-design.md) · [Data Flow](data-flow.md) |

---

## Design Decisions

| Question | Decision |
|----------|----------|
| Synchronous or asynchronous? | **Synchronous.** `POST /api/study-plan` returns the finished plan in one request (ADR-004). |
| Timeout threshold | Gemini: **8 s** per call. Whole request target: **≤ 10 s**. |
| Retry strategy | **One retry** only when Gemini returns invalid JSON *and* time remains. No retry after a timeout. |
| Fallback behavior | Return the engine's rule-based schedule with `source: "fallback"` and a generic explanation. The frontend shows a notice. |
| Database failure | Still return the plan with `saved: false`; the frontend shows "not saved to history". |
| Logging | Log Gemini errors, fallbacks and failed saves (no API keys or personal data). |

---

## 1. Generate Study Plan (main scenario)

```mermaid
sequenceDiagram
    autonumber
    actor S as Student
    participant FE as Next.js Frontend
    participant API as FastAPI Route
    participant ENG as Planner Engine
    participant AI as Gemini Service
    participant G as Gemini API
    participant DB as Tiger Data

    S->>FE: Fill assignment form, click Generate Plan
    FE->>FE: Basic form checks, show loading
    FE->>API: POST /api/study-plan
    API->>API: Validate request (Pydantic)
    API->>ENG: Score tasks
    ENG-->>API: Risk scores, priorities, Pomodoro counts
    API->>AI: Request schedule for scored tasks
    AI->>G: Prompt + JSON schema (timeout 8 s)
    G-->>AI: JSON response
    AI->>AI: Validate JSON against rules
    AI-->>API: Daily schedule, risk analysis, tips
    API->>DB: Insert plan and tasks
    DB-->>API: plan id
    API-->>FE: 201 Created, plan (source gemini, saved true)
    FE-->>S: Show Risk, Priority, Study Plan and Pomodoro cards
```

### Failure scenario A — Gemini timeout or invalid output

```mermaid
sequenceDiagram
    autonumber
    participant API as FastAPI Route
    participant ENG as Planner Engine
    participant AI as Gemini Service
    participant G as Gemini API
    participant DB as Tiger Data
    participant FE as Next.js Frontend

    API->>AI: Request schedule
    AI->>G: Prompt (timeout 8 s)
    alt Timeout or API error
        G--xAI: No response / error
        AI->>AI: Log error
    else Invalid JSON
        G-->>AI: Invalid response
        AI->>G: Retry once
        G-->>AI: Still invalid
        AI->>AI: Log error
    end
    AI-->>API: Failed
    API->>ENG: Build fallback schedule
    ENG-->>API: Rule-based schedule + generic explanation
    API->>DB: Insert plan (source fallback)
    API-->>FE: 201 Created, plan (source fallback)
    FE->>FE: Show plan + notice "AI unavailable, basic plan shown"
```

### Failure scenario B — Invalid input

```mermaid
sequenceDiagram
    autonumber
    actor S as Student
    participant FE as Next.js Frontend
    participant API as FastAPI Route

    S->>FE: Submit form (e.g. due date in the past)
    alt Caught by the form
        FE-->>S: Inline field error, no request sent
    else Caught by the API
        FE->>API: POST /api/study-plan
        API->>API: Validation fails
        API-->>FE: 422 Unprocessable Entity, field errors
        FE-->>S: Show validation message next to the field
    end
    Note over API: Nothing is sent to Gemini or saved
```

---

## 2. Save and Review History

Saving happens inside *Generate Study Plan* (step 12 above). This diagram covers the save failure and reading history back.

```mermaid
sequenceDiagram
    autonumber
    actor S as Student
    participant FE as Next.js Frontend
    participant API as FastAPI Route
    participant DB as Tiger Data

    Note over API,DB: Save (during plan generation)
    API->>DB: BEGIN, insert plan, insert tasks, COMMIT
    alt Save succeeds
        DB-->>API: plan id
        API-->>FE: plan (saved true)
    else Database error
        DB--xAPI: Error, ROLLBACK
        API->>API: Log error
        API-->>FE: plan (saved false, id null)
        FE-->>S: Notice "Plan not saved to history"
    end

    Note over S,DB: Review history
    S->>FE: Open Dashboard / History
    FE->>API: GET /api/history?limit=20
    API->>DB: Select latest plans
    DB-->>API: Rows
    API-->>FE: 200 OK, plan summaries
    FE-->>S: History table
    S->>FE: Click a plan
    FE->>API: GET /api/history/{id}
    API->>DB: Select plan and tasks
    alt Found
        API-->>FE: 200 OK, full plan
        FE-->>S: Show result cards
    else Not found
        API-->>FE: 404 Not Found
        FE-->>S: "Plan not found"
    end
```

---

## 3. Send Discord Notification

```mermaid
sequenceDiagram
    autonumber
    actor S as Student
    participant FE as Next.js Frontend
    participant API as FastAPI Route
    participant DB as Tiger Data
    participant DS as Discord Service
    participant D as Discord Webhook

    S->>FE: Click Send to Discord
    FE->>API: POST /api/discord (plan_id)
    API->>DB: Load plan
    alt Plan not found
        API-->>FE: 404 Not Found
    else Plan found
        API->>DS: Format summary (top priorities, Pomodoros, risk)
        DS->>D: POST message (timeout 5 s)
        alt Delivered
            D-->>DS: 204 No Content
            DS->>DB: Insert notification (sent)
            API-->>FE: 200 OK, sent true
            FE-->>S: "Sent to Discord ✓"
        else Discord error or not configured
            D--xDS: Error
            DS->>DB: Insert notification (failed)
            API-->>FE: 502 Bad Gateway, sent false
            FE-->>S: "Could not send, try again"
        end
    end
```
