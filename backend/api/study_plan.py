from fastapi import APIRouter

from models.study_plan import StudyPlanRequest, StudyPlanResponse
from services.study_plan_service import generate_study_plan

router = APIRouter()


@router.post("/study-plan", response_model=StudyPlanResponse)
def study_plan(request: StudyPlanRequest):
    return generate_study_plan(request)
