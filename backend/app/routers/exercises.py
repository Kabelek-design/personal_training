from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel

from app.db import SessionLocal
from app.models import OneRepMax

router = APIRouter()

class ExerciseCreate(BaseModel):
    exercise: str
    max_value: int

def get_db():
    """Prosta funkcja 'dependencji', zwracająca obiekt Session."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/exercises")
def create_exercise(ex_data: ExerciseCreate, db: Session = Depends(get_db)):
    """
    Tworzy nowe ćwiczenie w bazie na podstawie danych przesłanych w POST.
    
    Przykładowy JSON w body:
    {
      "exercise": "Bench_press",
      "max_value": 180
    }
    """
    record = OneRepMax(
        exercise=ex_data.exercise,
        max_value=ex_data.max_value
    )
    db.add(record)
    db.commit()
    db.refresh(record)  # odświeżenie, aby mieć np. wygenerowane ID

    return {
        "status": "ok",
        "new_id": record.id,
        "info": f"Dodano ćwiczenie {record.exercise} z wynikiem {record.max_value}."
    }



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
