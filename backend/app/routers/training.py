# app/routers/training.py

from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import List
from app.db import SessionLocal
from sqlalchemy.orm import Session

from app.models.training_plan import TrainingExercise, TrainingPlan, TrainingSet, TrainingWeek

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Schemy Pydantic (najprostsza wersja do walidacji danych)
class TrainingSetSchema(BaseModel):
    reps: int
    percentage: float
    isAMRAP: bool = False

class ExerciseSchema(BaseModel):
    name: str
    sets: List[TrainingSetSchema]

class TrainingPlanSchema(BaseModel):
    week: int
    exercises: List[ExerciseSchema]

SAMPLE_PLANS: List[TrainingPlanSchema] = [
    # Tydzień 1
    TrainingPlanSchema(
        week=1,
        exercises=[
            ExerciseSchema(name="squats", sets=[
                TrainingSetSchema(reps=6, percentage=62.5),
                TrainingSetSchema(reps=6, percentage=70),
                TrainingSetSchema(reps=6, percentage=70),
                TrainingSetSchema(reps=6, percentage=70, isAMRAP=True),  # Seria "+"
            ]),
            ExerciseSchema(name="dead_lift", sets=[
                TrainingSetSchema(reps=4, percentage=70),
                TrainingSetSchema(reps=4, percentage=75),
                TrainingSetSchema(reps=4, percentage=80),
                TrainingSetSchema(reps=4, percentage=80),
                TrainingSetSchema(reps=4, percentage=80, isAMRAP=True),  # Seria "+"
            ]),
            ExerciseSchema(name="bench_press", sets=[
                TrainingSetSchema(reps=6, percentage=65),
                TrainingSetSchema(reps=4, percentage=75),
                TrainingSetSchema(reps=2, percentage=85),
                TrainingSetSchema(reps=2, percentage=90),
                TrainingSetSchema(reps=2, percentage=90, isAMRAP=True),  # Seria "+"
                TrainingSetSchema(reps=4, percentage=75),
            ]),
        ],
    ),

    # Tydzień 2
    TrainingPlanSchema(
        week=2,
        exercises=[
            ExerciseSchema(name="squats", sets=[
                TrainingSetSchema(reps=6, percentage=65),
                TrainingSetSchema(reps=4, percentage=75),
                TrainingSetSchema(reps=2, percentage=85),
                TrainingSetSchema(reps=2, percentage=90),
                TrainingSetSchema(reps=2, percentage=90, isAMRAP=True),  # Seria "+"
                TrainingSetSchema(reps=4, percentage=75),
            ]),
            ExerciseSchema(name="dead_lift", sets=[
                TrainingSetSchema(reps=6, percentage=62.5),
                TrainingSetSchema(reps=6, percentage=70),
                TrainingSetSchema(reps=6, percentage=70),
                TrainingSetSchema(reps=6, percentage=70, isAMRAP=True),  # Seria "+"
            ]),
            ExerciseSchema(name="bench_press", sets=[
                TrainingSetSchema(reps=4, percentage=70),
                TrainingSetSchema(reps=4, percentage=75),
                TrainingSetSchema(reps=4, percentage=80),
                TrainingSetSchema(reps=4, percentage=80),
                TrainingSetSchema(reps=4, percentage=80, isAMRAP=True),  # Seria "+"
            ]),
        ],
    ),

    # Tydzień 3
    TrainingPlanSchema(
        week=3,
        exercises=[
            ExerciseSchema(name="squats", sets=[
                TrainingSetSchema(reps=4, percentage=70),
                TrainingSetSchema(reps=4, percentage=75),
                TrainingSetSchema(reps=4, percentage=80),
                TrainingSetSchema(reps=4, percentage=80),
                TrainingSetSchema(reps=4, percentage=80, isAMRAP=True),  # Seria "+"
            ]),
            ExerciseSchema(name="dead_lift", sets=[
                TrainingSetSchema(reps=6, percentage=65),
                TrainingSetSchema(reps=4, percentage=75),
                TrainingSetSchema(reps=2, percentage=85),
                TrainingSetSchema(reps=2, percentage=90),
                TrainingSetSchema(reps=2, percentage=90, isAMRAP=True),  # Seria "+"
                TrainingSetSchema(reps=4, percentage=75),
            ]),
            ExerciseSchema(name="bench_press", sets=[
                TrainingSetSchema(reps=6, percentage=62.5),
                TrainingSetSchema(reps=6, percentage=70),
                TrainingSetSchema(reps=6, percentage=70),
                TrainingSetSchema(reps=6, percentage=70, isAMRAP=True),  # Seria "+"
            ]),
        ],
    ),

    # Tydzień 4 (Powtórka)
    TrainingPlanSchema(
        week=4,
        exercises=[
            ExerciseSchema(name="squats", sets=[
                TrainingSetSchema(reps=6, percentage=65),
                TrainingSetSchema(reps=4, percentage=75),
                TrainingSetSchema(reps=2, percentage=85),
                TrainingSetSchema(reps=2, percentage=90),
                TrainingSetSchema(reps=2, percentage=90, isAMRAP=True),  # Seria "+"
                TrainingSetSchema(reps=4, percentage=75),
            ]),
            ExerciseSchema(name="dead_lift", sets=[
                TrainingSetSchema(reps=6, percentage=65),
                TrainingSetSchema(reps=4, percentage=75),
                TrainingSetSchema(reps=2, percentage=85),
                TrainingSetSchema(reps=2, percentage=90),
                TrainingSetSchema(reps=2, percentage=90, isAMRAP=True),  # Seria "+"
                TrainingSetSchema(reps=4, percentage=75),
            ]),
            ExerciseSchema(name="bench_press", sets=[
                TrainingSetSchema(reps=6, percentage=65),
                TrainingSetSchema(reps=4, percentage=75),
                TrainingSetSchema(reps=2, percentage=85),
                TrainingSetSchema(reps=2, percentage=90),
                TrainingSetSchema(reps=2, percentage=90, isAMRAP=True),  # Seria "+"
                TrainingSetSchema(reps=4, percentage=75),
            ]),
        ],
    ),

    # Tydzień 5 (Deload)
    TrainingPlanSchema(
        week=5,
        exercises=[
            ExerciseSchema(name="squats", sets=[
                TrainingSetSchema(reps=4, percentage=50),
                TrainingSetSchema(reps=3, percentage=65),
                TrainingSetSchema(reps=2, percentage=80),
                TrainingSetSchema(reps=1, percentage=90),
            ]),
            ExerciseSchema(name="dead_lift", sets=[
                TrainingSetSchema(reps=4, percentage=50),
                TrainingSetSchema(reps=3, percentage=65),
                TrainingSetSchema(reps=2, percentage=80),
                TrainingSetSchema(reps=1, percentage=90),
            ]),
            ExerciseSchema(name="bench_press", sets=[
                TrainingSetSchema(reps=4, percentage=50),
                TrainingSetSchema(reps=3, percentage=65),
                TrainingSetSchema(reps=2, percentage=80),
                TrainingSetSchema(reps=1, percentage=90),
            ]),
        ],
    ),

    # Tydzień 6 (Test Max)
    TrainingPlanSchema(
        week=6,
        exercises=[
            ExerciseSchema(name="squats", sets=[
                TrainingSetSchema(reps=5, percentage=50),
                TrainingSetSchema(reps=4, percentage=60),
                TrainingSetSchema(reps=3, percentage=70),
                TrainingSetSchema(reps=2, percentage=80),
                TrainingSetSchema(reps=1, percentage=90),
                TrainingSetSchema(reps=1, percentage=105),
                TrainingSetSchema(reps=1, percentage=110),
            ]),
            ExerciseSchema(name="dead_lift", sets=[
                TrainingSetSchema(reps=5, percentage=50),
                TrainingSetSchema(reps=4, percentage=60),
                TrainingSetSchema(reps=3, percentage=70),
                TrainingSetSchema(reps=2, percentage=80),
                TrainingSetSchema(reps=1, percentage=90),
                TrainingSetSchema(reps=1, percentage=105),
                TrainingSetSchema(reps=1, percentage=110),
            ]),
            ExerciseSchema(name="bench_press", sets=[
                TrainingSetSchema(reps=5, percentage=50),
                TrainingSetSchema(reps=4, percentage=60),
                TrainingSetSchema(reps=3, percentage=70),
                TrainingSetSchema(reps=2, percentage=80),
                TrainingSetSchema(reps=1, percentage=90),
                TrainingSetSchema(reps=1, percentage=105),
                TrainingSetSchema(reps=1, percentage=110),
            ]),
        ],
    ),
]


@router.get("/plans", response_model=List[TrainingPlanSchema])
def get_all_plans():
    """
    Zwraca listę wszystkich tygodni i ćwiczeń.
    """
    return SAMPLE_PLANS

@router.get("/plans/{week_id}", response_model=TrainingPlanSchema)
def get_plan(week_id: int):
    """
    Zwraca trening dla konkretnego tygodnia.
    """
    for plan in SAMPLE_PLANS:
        if plan.week == week_id:
            return plan
    raise HTTPException(status_code=404, detail="Trening o takim tygodniu nie istnieje")


@router.patch("/week/{week_number}/exercise/{exercise_name}/add_weight")
def add_weight(
    week_number: int,
    exercise_name: str,
    actual_reps: int,  # Faktyczna liczba wykonanych powtórzeń
    add_kg: float = 5.0,
    db: Session = Depends(get_db)
):
    """
    Jeśli w serii z isAMRAP faktyczne powtórzenia (actual_reps) przekroczą zalecaną liczbę (reps w planie),
    to dodaj +add_kg w tej i kolejnych tygodniach.
    """
    # Pobierz wszystkie tygodnie, od podanego week_number wzwyż
    weeks_to_update = (
        db.query(TrainingWeek)
        .filter(TrainingWeek.week_number >= week_number)
        .all()
    )

    updated_exercises = []
    for week in weeks_to_update:
        # Znajdź ćwiczenie o danej nazwie w danym tygodniu
        exercise = (
            db.query(TrainingExercise)
            .filter(
                TrainingExercise.week_id == week.id,
                TrainingExercise.name == exercise_name
            )
            .first()
        )
        if exercise:
            # Pobierz serię z flagą is_amrap
            amrap_set = (
                db.query(TrainingSet)
                .filter(
                    TrainingSet.exercise_id == exercise.id,
                    TrainingSet.is_amrap == True
                )
                .first()
            )
            # Jeśli faktyczna liczba powtórzeń przekracza zalecaną, zwiększ increment
            if amrap_set and actual_reps > amrap_set.reps:
                exercise.increment += add_kg
                updated_exercises.append(exercise.id)

    db.commit()
    return {
        "status": "ok",
        "updated_exercises": updated_exercises,
        "added_kg": add_kg,
    }
