from pydantic import BaseModel

class ExerciseCreate(BaseModel):
    exercise: str
    max_value: int
