from pydantic import BaseModel
from typing import List, Optional

class TrainingSetSchema(BaseModel):
    id: Optional[int]
    reps: int
    percentage: float
    is_amrap: bool = False

    class Config:
        orm_mode = True

class TrainingExerciseSchema(BaseModel):
    id: Optional[int]
    name: str
    increment: float = 0.0
    sets: List[TrainingSetSchema] = []

    class Config:
        orm_mode = True

class TrainingWeekSchema(BaseModel):
    id: Optional[int]
    week_number: int
    exercises: List[TrainingExerciseSchema] = []

    class Config:
        orm_mode = True

class TrainingPlanSchema(BaseModel):
    id: Optional[int]
    name: str
    weeks: List[TrainingWeekSchema] = []

    class Config:
        orm_mode = True
