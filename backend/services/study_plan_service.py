from models.study_plan import StudyPlanRequest, StudyPlanResponse


def generate_study_plan(request: StudyPlanRequest) -> StudyPlanResponse:
    # Mock result; the real risk engine and Gemini call replace this in Sprint 5.
    return StudyPlanResponse(risk="High", priority="High", pomodoros=6)
