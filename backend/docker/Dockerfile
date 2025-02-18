FROM python:3.10

# 1. Zainstaluj paczki potrzebne do skompilowania psycopg2 (m.in. pg_config)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

COPY docker/startup.sh /docker/startup.sh
RUN chmod +x /docker/startup.sh
CMD ["/docker/startup.sh"]

