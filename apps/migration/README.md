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

# Add image to ECR
Retrieve an authentication token and authenticate your Docker client to your registry.
```
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 647017618515.dkr.ecr.eu-west-1.amazonaws.com
```
Remove the key credStore from ~/.docker/config.json, and everything works normal now.

Remove docker-credential-helpers

```
rm -rf ~/.password-store/docker-credential-helpers
```

[Reference](https://stackoverflow.com/questions/71770693/error-saving-credentials-error-storing-credentials-err-exit-status-1-out)

Build the docker image
```
docker build -t celery .
```
Tag the image
```
docker tag celery:latest 647017618515.dkr.ecr.eu-west-1.amazonaws.com/celery:latest
```
Push the image to the repo
```
docker push 647017618515.dkr.ecr.eu-west-1.amazonaws.com/celery:latest
```



