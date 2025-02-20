from sqlalchemy import Column, Integer, String, Float, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.db import Base

class TrainingPlan(Base):
    __tablename__ = "training_plans"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    weeks = relationship("TrainingWeek", back_populates="plan")


class TrainingWeek(Base):
    __tablename__ = "training_weeks"

    id = Column(Integer, primary_key=True, index=True)
    plan_id = Column(Integer, ForeignKey("training_plans.id"))
    week_number = Column(Integer, nullable=False)

    plan = relationship("TrainingPlan", back_populates="weeks")
    exercises = relationship("TrainingExercise", back_populates="week")

class TrainingExercise(Base):
    __tablename__ = "training_exercises"

    id = Column(Integer, primary_key=True, index=True)
    week_id = Column(Integer, ForeignKey("training_weeks.id"))
    name = Column(String(collation="utf8_general_ci"), nullable=False)
    increment = Column(Float, default=0.0)  # <-- kluczowe do modyfikacji ciężaru

    week = relationship("TrainingWeek", back_populates="exercises")
    sets = relationship("TrainingSet", back_populates="exercise")

class TrainingSet(Base):
    __tablename__ = "training_sets"

    id = Column(Integer, primary_key=True, index=True)
    exercise_id = Column(Integer, ForeignKey("training_exercises.id"))
    reps = Column(Integer, nullable=False)
    percentage = Column(Float, nullable=False)
    is_amrap = Column(Boolean, default=False)

    exercise = relationship("TrainingExercise", back_populates="sets")
