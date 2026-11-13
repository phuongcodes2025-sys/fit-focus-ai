from fastapi import APIRouter

router = APIRouter()


@router.post("/study-plan")
def study_plan():
    # TODO: call Gemini service and store result in Tiger Data
    return {"message": "study plan endpoint"}


@router.post("/meal-plan")
def meal_plan():
    return {"message": "meal plan endpoint"}


@router.get("/history")
def history():
    return []


@router.post("/discord")
def discord():
    return {"sent": False}
