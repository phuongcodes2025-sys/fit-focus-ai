# Setup Guide

Goal: run Fit & Focus AI locally in under 15 minutes.

## Prerequisites

- Git
- Node.js 20+ and npm
- Python 3.11+
- A Gemini API key and a Tiger Data (PostgreSQL) connection string

## 1. Clone

```bash
git clone https://github.com/phuongcodes2025-sys/fit-focus-ai.git
cd fit-focus-ai
git checkout develop
```

## 2. Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env            # then fill in real values
uvicorn main:app --reload
```

Verify: open <http://127.0.0.1:8000> and expect `{"status": "ok", "app": "Fit & Focus AI"}`.

## 3. Frontend

The frontend is not initialized yet (see `frontend/README.md`). Once it exists:

```bash
cd frontend
cp .env.example .env.local
npm install
npm run dev
```

Verify: open <http://localhost:3000>.

## Environment variables

| Variable | Used by | Purpose |
|----------|---------|---------|
| `GEMINI_API_KEY` | backend | Gemini API access |
| `DATABASE_URL` | backend | Tiger Data connection string |
| `DISCORD_WEBHOOK_URL` | backend | Discord notifications |
| `ENVIRONMENT` | backend | `local` or `production` |
| `NEXT_PUBLIC_API_URL` | frontend | Base URL of the backend |

Where each environment keeps its values:

| Environment | Backend | Frontend |
|-------------|---------|----------|
| Local | `backend/.env` | `frontend/.env.local` |
| Production | Render dashboard | Vercel project settings (or `.env.production`) |

Copy the `.env.example` file in each folder to get started. Never commit real values.

Never commit `.env`; it is listed in `.gitignore`.

## Troubleshooting

- **`ModuleNotFoundError`**: the virtual environment is not active, or `pip install -r requirements.txt` was skipped.
- **CORS error in the browser**: the frontend must run on `http://localhost:3000`, the origin allowed in `backend/main.py`.
- **Port already in use**: pass another port, e.g. `uvicorn main:app --reload --port 8001`.
