# core/config.py
import os

# Odczytujemy zmienne środowiskowe z systemu (lub z pliku .env)
# W razie braku - ustalamy wartości domyślne
DB_USER = os.getenv("POSTGRES_USER", "postgres")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD", "fastapi")
DB_NAME = os.getenv("POSTGRES_DB", "training_db")
DB_HOST = os.getenv("POSTGRES_HOST", "db")  # zamiast "localhost"
DB_PORT = os.getenv("POSTGRES_PORT", "5432")

ENV = os.getenv("ENV", "local")
DEBUG = os.getenv("DEBUG", "False") == "True"

APP_HOST = os.getenv("APP_HOST", "0.0.0.0")
APP_PORT = int(os.getenv("APP_PORT", "8000"))

# Składamy nasz connection string
DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
