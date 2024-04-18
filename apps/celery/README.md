# celery-flask-scaffold
Base structure for projects involving task queues and long-running processes. Uses Flask to trigger the tasks and redis as storage for the task metadata.

## Requirements
- [Docker](https://docs.docker.com/get-docker/)


## Usage
Init the containers
```
docker compose up --build
```
Trigger the tasks
```
curl -X POST localhost:5000/add -d "a=50" -d "b=10"
curl localhost:5000/fail
curl localhost:5000/migration
```

## Inspect task metadata
```
redis-cli -p 6380
get celery-task-meta-<task id>
```

