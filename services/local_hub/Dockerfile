FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ ./app/

RUN mkdir -p /app/data/cubes /app/data/receipts /app/data/agents

EXPOSE 8080

CMD ["gunicorn", "app.main:app", "--bind", "0.0.0.0:8080", "--workers", "2"]
