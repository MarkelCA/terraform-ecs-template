from flask import Flask, request
from tasks import add,fail,migration

app = Flask(__name__)
app.config.from_mapping(
    CELERY=dict(
        broker_url="redis://redis:6379",
        result_backend="redis://redis:6379",
        task_ignore_result=True,
    ),
)

@app.get("/fail")
def failing_task():
    result = fail.run.delay()
    return {"result_id": result.id}

@app.get("/migration")
def migration_task():
    result = migration.run.delay()
    return {"result_id": result.id}


@app.post("/add")
def start_add() -> dict[str, object]:
    a = request.form.get("a", type=int)
    b = request.form.get("b", type=int)
    result = add.run.delay(a, b)
    return {"result_id": result.id}

