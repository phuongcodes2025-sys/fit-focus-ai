from fastapi import APIRouter

from .study_plan import router as study_plan_router

router = APIRouter()
router.include_router(study_plan_router)


@router.get("/health")
def health():
    return {"status": "ok", "app": "Fit & Focus AI"}


@router.post("/meal-plan")
def meal_plan():
    return {"message": "meal plan endpoint"}


@router.get("/history")
def history():
    return []


@router.post("/discord")
def discord():
    return {"sent": False}
