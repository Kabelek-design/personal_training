# app/server.py
from fastapi import FastAPI
from app.db import Base, engine
from app.routers import exercises

# Tworzymy tabele (jeśli nie istnieją)
Base.metadata.create_all(bind=engine)

# Inicjujemy FastAPI
app = FastAPI()

# Prosty endpoint testowy
@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI!"}

# Rejestrujemy router z exercises (prefiks np. '/workouts')
app.include_router(exercises.router, prefix="", tags=["exercises"])
