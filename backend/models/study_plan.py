from datetime import date

from pydantic import BaseModel


class StudyPlanRequest(BaseModel):
    course: str
    assignment: str
    deadline: date


class StudyPlanResponse(BaseModel):
    risk: str
    priority: str
    pomodoros: int
