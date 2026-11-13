from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routes import router

load_dotenv()

app = FastAPI(title="Fit & Focus AI API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router, prefix="/api")


@app.get("/")
def root():
    return {"status": "ok", "app": "Fit & Focus AI"}
