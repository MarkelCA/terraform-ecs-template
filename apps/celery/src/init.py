from celery import Celery, Task
from flask import Flask, request
from controller import app
from waitress import serve

def celery_init_app(app: Flask) -> Celery:
    class FlaskTask(Task):
        def __call__(self, *args: object, **kwargs: object) -> object:
            with app.app_context():
                return self.run(*args, **kwargs)

    celery_app = Celery(app.name, task_cls=FlaskTask)
    celery_app.config_from_object(app.config["CELERY"])
    celery_app.set_default()
    app.extensions["celery"] = celery_app
    return celery_app


celery = celery_init_app(app)

if __name__ == '__main__':
    serve(app, host="0.0.0.0", port=5000)
