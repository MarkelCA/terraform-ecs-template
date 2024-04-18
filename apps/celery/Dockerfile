FROM python:3.9-alpine

ENV PYTHONPATH "${PYTHONPATH}:/app/src"

COPY . /app
WORKDIR /app

RUN pip install --no-cache-dir \
    -r requirements.txt \
    pip install "celery[redis]"

RUN mkdir -p /var/run/celery /var/log/celery
RUN chown -R nobody:nogroup /var/run/celery /var/log/celery

VOLUME ["/var/log/celery", "/var/run/celery"]

EXPOSE 5000

CMD celery --app=src.init.celery worker \
    --uid=nobody --gid=nogroup &\
    python3 src/init.py
