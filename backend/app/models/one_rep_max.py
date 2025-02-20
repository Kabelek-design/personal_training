from sqlalchemy import Column, Integer, String
from app.db import Base

class OneRepMax(Base):
    __tablename__ = "one_rep_maxes"

    id = Column(Integer, primary_key=True, index=True)
    exercise = Column(String, nullable=False)
    max_value = Column(Integer, nullable=False)