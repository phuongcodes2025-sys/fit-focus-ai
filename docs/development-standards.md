# Development Standards

## Branching

- `main`: stable, demo-ready code only.
- `develop`: daily work branch.
- Feature branches: `feature/<short-name>`, `fix/<short-name>`, `docs/<short-name>`, branched from `develop` and merged back into it.
- Merge `develop` into `main` only when it is tested and stable.

## Commit messages

Use a short imperative summary with a prefix:

```text
feat: add study plan endpoint
fix: handle empty assignment list
docs: update setup guide
chore: update dependencies
```

## Naming

| Area | Convention |
|------|-----------|
| Python files, functions, variables | `snake_case` |
| Python classes | `PascalCase` |
| TypeScript components | `PascalCase` (`StudyPlanForm.tsx`) |
| TypeScript variables, functions | `camelCase` |
| Database tables and columns | `snake_case` |

## Secrets

- Keep API keys, database credentials and webhooks in `.env` only.
- Commit `.env.example` with placeholder values, never real ones.
- If a secret is committed by mistake, rotate it immediately.

## Issues and labels

Every issue gets at least one area label: `frontend`, `backend`, `database` or `ai`. Use `bug`, `enhancement` or `documentation` for the type of work.

## Before merging

- [ ] The app runs locally following `docs/setup-guide.md`
- [ ] No secrets in the diff
- [ ] Related docs updated (`api-design.md`, README, etc.)
- [ ] Commit messages follow the convention above
