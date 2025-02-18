# app/routers/exercises.py
from fastapi import APIRouter
from app.db import SessionLocal
from app.models import OneRepMax

router = APIRouter()

@router.post("/populate")
def populate_exercises():
    """
    Dodaje trzy ćwiczenia do bazy danych:
      - Bench_press, one_rep_max=180
      - Squats, one_rep_max=200
      - Dead_lift, one_rep_max=250
    """
    db = SessionLocal()
    try:
        data = [
            ("Bench_press", 180),
            ("Squats", 200),
            ("Dead_lift", 250)
        ]
        for exercise, value in data:
            record = OneRepMax(exercise=exercise, max_value=value)
            db.add(record)
        db.commit()
        return {"status": "ok", "info": "Dodano 3 ćwiczenia"}
    finally:
        db.close()


@router.get("/exercises")
def get_exercises():
    """
    Zwraca listę ćwiczeń z bazy w formie JSON.
    """
    db = SessionLocal()
    try:
        records = db.query(OneRepMax).all()
        return [
            {"id": r.id, "exercise": r.exercise, "max_value": r.max_value}
            for r in records
        ]
    finally:
        db.close()
