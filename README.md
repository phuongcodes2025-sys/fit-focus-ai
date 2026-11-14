# Fit & Focus AI

## Overview

Fit & Focus AI is an AI-powered student success platform designed to help college students stay organized, focused, and healthy throughout the semester.

The application uses Google Gemini to transform course schedules, assignment descriptions, and deadlines into actionable study plans. It also provides meal-planning recommendations and stores activity history using Tiger Data.

Built for HackUTA 2026.

---

## Problem

Many college students struggle to balance:

- Multiple classes
- Assignment deadlines
- Exams
- Part-time jobs
- Personal responsibilities

Students often know what needs to be done but do not know what to prioritize first.

---

## Solution

Fit & Focus AI acts as a personal student success companion.

Students can:

- Paste a syllabus
- Enter assignment deadlines
- Generate study plans
- Receive Pomodoro schedules
- Analyze academic risk levels
- Create budget-friendly meal plans
- View previous study plans and recommendations

---

## Features

### Study Planner

Input:

- Course schedules
- Assignment descriptions
- Exam dates

Output:

- Weekly Study Plan
- Priority Matrix
- Pomodoro Breakdown
- Academic Risk Analysis

---

### Meal Planner

Input:

- Weekly budget
- Dietary preferences

Output:

- 7-Day Meal Plan
- Shopping List
- Healthy Budget-Friendly Recommendations

---

### Activity History

Store previous:

- Study Plans
- AI Responses
- Meal Plans

using Tiger Data.

---

### Discord Notifications

Users can send generated study plans to a Discord channel using webhooks.

Example:

```text
Weekly Focus Plan

High Priority:
- Programming Lab

Medium Priority:
- Networking Quiz

Study Sessions:
- 6 Pomodoros Programming
- 4 Pomodoros Networking
```

---

## Architecture

```text
Student
    │
    ▼
Next.js Frontend
    │
    ▼
FastAPI Backend
    │
 ┌──┴───────────┐
 ▼              ▼
Gemini API   Tiger Data
    │
    ▼
Discord Webhook
```

See [docs/architecture.md](docs/architecture.md) and [docs/api-design.md](docs/api-design.md).

---

## Roadmap

Development is organized into 12 sprints (Sprint 0 → Sprint 11), from discovery to HackUTA submission. See [docs/SPRINTS.md](docs/SPRINTS.md) and the [milestones](https://github.com/phuongcodes2025-sys/fit-focus-ai/milestones).

---

## Tech Stack

### Frontend

- Next.js
- TypeScript
- Tailwind CSS

### Backend

- Python
- FastAPI

### AI

- Google Gemini API

### Database

- Tiger Data (PostgreSQL)

### Notifications

- Discord Webhooks

### Development

- Cursor AI

### Deployment

- Vercel
- Render

---

## Project Structure

```text
fit-focus-ai/
├── frontend/
│   ├── src/
│   ├── components/
│   ├── app/
│   └── public/
│
├── backend/
│   ├── routes/
│   ├── services/
│   ├── models/
│   └── main.py
│
├── docs/
│   ├── architecture.md
│   ├── api-design.md
│   └── SPRINTS.md
│
├── database/
│   └── schema.sql
│
├── LICENSE
├── .gitignore
└── README.md
```

---

## Getting Started

### Clone Repository

```bash
git clone https://github.com/phuongcodes2025-sys/fit-focus-ai.git
cd fit-focus-ai
```

---

## Frontend Setup

```bash
cd frontend

npm install

npm run dev
```

Open:

```text
http://localhost:3000
```

---

## Backend Setup

```bash
cd backend

python -m venv venv
```

Windows:

```bash
venv\Scripts\activate
```

Mac/Linux:

```bash
source venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Run server:

```bash
uvicorn main:app --reload
```

Open:

```text
http://127.0.0.1:8000
```

---

## Environment Variables

Create a `.env` file inside `backend` (see `backend/.env.example`):

```env
GEMINI_API_KEY=your_gemini_key

DATABASE_URL=your_tiger_data_connection_string

DISCORD_WEBHOOK_URL=your_discord_webhook
```

---

## API Endpoints

### Generate Study Plan

```http
POST /api/study-plan
```

### Generate Meal Plan

```http
POST /api/meal-plan
```

### Get History

```http
GET /api/history
```

### Send To Discord

```http
POST /api/discord
```

---

## Example User Workflow

1. User enters assignment deadlines.
2. Backend sends data to Gemini.
3. Gemini generates:
   - Risk Analysis
   - Study Plan
   - Pomodoro Schedule
4. Response is stored in Tiger Data.
5. Results appear on dashboard.
6. User optionally sends summary to Discord.

---

## HackUTA Prize Categories

### Best Use of Gemini API

Gemini powers:

- Study Planning
- Academic Risk Analysis
- Meal Planning
- Student Coaching

### Best Use of Tiger Data

Tiger Data stores:

- User prompts
- Study Plans
- AI Results
- Activity History

### Build with SpaceXSI

Development accelerated using:

- Cursor AI
- AI-assisted coding workflows
- Automated development practices

---

## Future Improvements

- User accounts
- Calendar integration
- Mobile app
- AI-powered GPA tracking
- Assignment reminder system
- Dallas College specific resources
- Learning analytics dashboard

---

## Team

HackUTA 2026

Fit & Focus AI

Helping students stay healthy, focused, and successful.

---

## License

This project is licensed under the [MIT License](LICENSE).
