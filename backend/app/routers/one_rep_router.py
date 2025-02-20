from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel

from app.db import SessionLocal
from app.models.one_rep_max import OneRepMax

router = APIRouter()

class ExerciseCreate(BaseModel):
    exercise: str
    max_value: int

class ExerciseUpdate(BaseModel):
    max_value: int

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/exercises")
def create_exercise(ex_data: ExerciseCreate, db: Session = Depends(get_db)):
    record = OneRepMax(
        exercise=ex_data.exercise,
        max_value=ex_data.max_value
    )
    db.add(record)
    db.commit()
    db.refresh(record)
    return {
        "status": "ok",
        "new_id": record.id,
        "info": f"Dodano ćwiczenie {record.exercise} z wynikiem {record.max_value}."
    }

@router.get("/exercises")
def get_exercises(db: Session = Depends(get_db)):
    records = db.query(OneRepMax).all()
    return [
        {"id": r.id, "exercise": r.exercise, "max_value": r.max_value}
        for r in records
    ]

@router.patch("/exercises/{exercise_id}")
def update_exercise(exercise_id: int, ex_data: ExerciseUpdate, db: Session = Depends(get_db)):
    """
    Aktualizuje `max_value` ćwiczenia o danym ID.
    
    JSON w body:
    {
      "max_value": 200
    }
    """
    record = db.query(OneRepMax).filter(OneRepMax.id == exercise_id).first()

    if not record:
        raise HTTPException(status_code=404, detail="Ćwiczenie nie istnieje")

    record.max_value = ex_data.max_value  # Zmieniamy tylko to jedno pole
    db.commit()
    db.refresh(record)

    return {
        "status": "ok",
        "updated_id": record.id,
        "info": f"Zaktualizowano max_value ćwiczenia {record.exercise} na {record.max_value}"
    }


@router.delete("/exercises/{exercise_id}")
def delete_exercise(exercise_id: int, db: Session = Depends(get_db)):
    """
    Usuwa ćwiczenie o danym ID z bazy.
    """
    record = db.query(OneRepMax).filter(OneRepMax.id == exercise_id).first()

    if not record:
        raise HTTPException(status_code=404, detail="Ćwiczenie nie istnieje")

    db.delete(record)
    db.commit()

    return {
        "status": "ok",
        "deleted_id": exercise_id,
        "info": f"Usunięto ćwiczenie o ID={exercise_id}"
    }
