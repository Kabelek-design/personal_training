from fastapi import FastAPI
from app.db import Base, engine
from fastapi.responses import JSONResponse
from app.routers import one_rep_router, training  # <-- Import training

# Tworzymy tabele (jeśli nie istnieją)
Base.metadata.create_all(bind=engine)

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI!"}

# Rejestracja routera exercises (one_rep_router)
app.include_router(one_rep_router.router, prefix="", tags=["exercises"])

# REJESTRACJA NOWEGO ROUTERA
app.include_router(training.router, prefix="/training", tags=["training"])
