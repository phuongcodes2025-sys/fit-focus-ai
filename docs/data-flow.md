# Data Flow Diagram — Fit & Focus AI

| | |
|---|---|
| **Sprint** | Sprint 1 - Solution Design (1.3) |
| **Related** | [Architecture](architecture.md) · [Use Cases](use-cases.md) · [Sequence Diagrams](sequence-diagrams.md) |

This document shows **how data moves**, not which technology moves it.

**Notation:** rectangles = external entities · rounded = processes · cylinders = data stores.

---

## 1. Level 0 — Context Diagram

```mermaid
flowchart LR
    student["Student"]
    system(("0<br/>Fit & Focus AI"))
    gemini["Gemini AI"]
    discord["Discord"]

    student -- "assignment details" --> system
    system -- "risk score, priorities,<br/>daily study plan" --> student
    system -- "scored tasks" --> gemini
    gemini -- "schedule, explanation, tips" --> system
    system -- "plan summary" --> discord
```

---

## 2. Level 1 — Main Processes

```mermaid
flowchart TB
    student["Student"]
    gemini["Gemini AI"]
    discord["Discord"]

    P1(["1.0 Validate input"])
    P2(["2.0 Assess risk & priority"])
    P3(["3.0 Generate schedule"])
    P4(["4.0 Save plan"])
    P5(["5.0 Build dashboard & history"])
    P6(["6.0 Send notification"])

    D1[("D1 Plans")]
    D2[("D2 Tasks")]
    D3[("D3 Notifications")]

    student -- "course, title, type, due date,<br/>estimated hours, difficulty" --> P1
    P1 -- "validation errors" --> student
    P1 -- "valid assignments" --> P2
    P2 -- "risk scores, priorities,<br/>Pomodoro counts" --> P3
    P3 -- "scored tasks" --> gemini
    gemini -- "schedule, explanation, tips" --> P3
    P3 -- "complete study plan" --> P4
    P3 -- "complete study plan" --> student
    P4 -- "plan record" --> D1
    P4 -- "task records" --> D2
    D1 -- "past plans" --> P5
    D2 -- "task stats" --> P5
    P5 -- "KPIs, trends, history" --> student
    student -- "completed task" --> D2
    student -- "share request (plan id)" --> P6
    D1 -- "plan details" --> P6
    P6 -- "summary message" --> discord
    P6 -- "delivery status" --> D3
```

### Process summary

| Process | Input | Output |
|---------|-------|--------|
| 1.0 Validate input | Raw assignment details | Valid assignments or validation errors |
| 2.0 Assess risk & priority | Valid assignments, today's date | Risk score, risk level, priority, Pomodoro count per task |
| 3.0 Generate schedule | Scored tasks | Daily schedule, risk explanation, tips (from Gemini or fallback) |
| 4.0 Save plan | Complete study plan | Plan and task records |
| 5.0 Build dashboard & history | Stored plans and tasks | KPIs, trends, history list |
| 6.0 Send notification | Plan id | Discord message, delivery status |

---

## 3. Level 2 — Study Planner Engine (processes 2.0 and 3.0)

```mermaid
flowchart TB
    IN["Valid assignments + today's date"]
    P21(["2.1 Calculate days left"])
    P22(["2.2 Detect deadline overlap"])
    P23(["2.3 Calculate risk score 0–100"])
    P24(["2.4 Assign risk level & priority"])
    P25(["2.5 Calculate Pomodoro count"])
    P31(["3.1 Build Gemini prompt"])
    P32(["3.2 Call Gemini"])
    P33(["3.3 Validate JSON response"])
    P34(["3.4 Build fallback schedule"])
    OUT["Complete study plan<br/>(source: gemini or fallback)"]
    gemini["Gemini AI"]

    IN --> P21 --> P22 --> P23 --> P24
    IN --> P25
    P24 --> P31
    P25 --> P31
    P31 --> P32
    P32 <--> gemini
    P32 --> P33
    P33 -- "valid" --> OUT
    P33 -- "invalid after 1 retry / timeout" --> P34
    P24 --> P34
    P25 --> P34
    P34 --> OUT
```

Formulas for 2.1 – 2.5 are defined in [architecture.md § 4](architecture.md#4-key-design-answers).

---

## 4. Data Entities

### Input data (from the student)

| Field | Type | Rules |
|-------|------|-------|
| `course` | text | Required, ≤ 50 characters |
| `title` | text | Required, ≤ 100 characters |
| `type` | `assignment` \| `exam` | Default `assignment` |
| `due_date` | date | Required, today or later |
| `estimated_hours` | number | 0.5 – 40 |
| `difficulty` | integer | 1 (easy) – 5 (hard) |

### Generated data (by the system)

| Field | Source |
|-------|--------|
| `risk_score`, `risk_level` | Planner engine |
| `priority`, `rank` | Planner engine |
| `pomodoros` | Planner engine |
| `daily_schedule` | Gemini (or fallback) |
| `risk_analysis`, `tips` | Gemini (or fallback text) |
| `source` | `gemini` or `fallback` |
| `warnings` | Planner engine (e.g. overload) |

### System data

| Field | Description |
|-------|-------------|
| `id` | Plan, task and notification identifiers |
| `created_at`, `sent_at` | Timestamps |
| `completed` | Task completion flag |
| Notification `status` | `sent` or `failed` |

---

## 5. ERD Preview (for Sprint 2)

Draft only; Sprint 2 finalizes the schema, data dictionary and `schema.sql`.

```mermaid
erDiagram
    PLANS ||--o{ TASKS : contains
    PLANS ||--o{ NOTIFICATIONS : "is shared by"

    PLANS {
        int id PK
        text plan_type "study or meal"
        text source "gemini or fallback"
        int overall_risk_score
        jsonb input
        jsonb result
        timestamptz created_at
    }
    TASKS {
        int id PK
        int plan_id FK
        text course
        text title
        text task_type "assignment or exam"
        date due_date
        numeric estimated_hours
        int difficulty
        int risk_score
        text risk_level
        text priority
        int pomodoros
        boolean completed
        timestamptz created_at
    }
    NOTIFICATIONS {
        int id PK
        int plan_id FK
        text channel "discord"
        text status "sent or failed"
        text error
        timestamptz sent_at
    }
```
