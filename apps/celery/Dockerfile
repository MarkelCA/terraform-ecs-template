FROM python:3.9-alpine

ENV PYTHONPATH "${PYTHONPATH}:/app/src"

COPY ./src /app
WORKDIR /app

ENTRYPOINT ["python", "-u", "/app/src/main.py"]
