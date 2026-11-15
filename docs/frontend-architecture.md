# Frontend Architecture

| | |
|---|---|
| **Sprint** | Sprint 3 - Development Environment |
| **Related** | [Architecture](architecture.md) · [Wireframes](wireframes.md) · [API Design](api-design.md) |

The frontend is a Next.js (App Router) + TypeScript app styled with Tailwind CSS and shadcn/ui, deployed on Vercel. It is not initialized yet (see `frontend/README.md`).

## Screens

| Route | Purpose | Main components |
|-------|---------|-----------------|
| `/` | Enter assignments and generate a plan | Hero, AssignmentForm, GenerateButton |
| `/result` | Show the generated plan | RiskCard, PriorityCard, StudyPlanCard, PomodoroCard, AI tips |
| `/dashboard` | History, KPIs and trends | KpiCards, TrendChart, HistoryList |

## Folder structure

```text
frontend/
├── app/            # Routes (pages, layouts): page.tsx, result/, dashboard/
├── components/     # Reusable UI; components/ui/ holds shadcn/ui primitives
├── services/       # API client: the only place that calls the backend
├── hooks/          # Data and state hooks, e.g. useStudyPlan, useHistory
├── types/          # TypeScript types matching the API schemas
└── public/         # Static assets
```

## Layers and data flow

```text
Page (app/) → Hook (hooks/) → Service (services/) → Backend /api/v1
```

- **Pages** compose components and read state from hooks.
- **Hooks** manage loading, error and result state.
- **Services** build requests, attach the `X-Student-Id` header and parse responses.
- **Types** mirror the response bodies in [api-design.md](api-design.md); change both together.

Components never call `fetch` directly.

## Design system

- **UI library:** shadcn/ui (components are copied into `components/ui/`).
- **Styling:** Tailwind CSS utility classes; no separate CSS files except global styles.

## Configuration

| Variable | Purpose |
|----------|---------|
| `NEXT_PUBLIC_API_URL` | Base URL of the backend, e.g. `http://127.0.0.1:8000` |

Use `.env.local` for local development and `.env.production` (or Vercel project settings) for production. Only `NEXT_PUBLIC_*` values reach the browser, so never put secrets here.

## Notes

- The `src/` folder created in the initial scaffold is replaced by the layout above; remove it when the app is initialized.
- Student identity is a UUID kept in `localStorage` (no login), as described in [api-design.md](api-design.md).
